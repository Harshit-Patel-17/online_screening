angular.module('onlineScreening')
.controller('ProgrammingAnswerSheetReviewCtrl', [
	'$scope',
	'$http',
	'$timeout',
	'Restangular',
	function($scope, $http, $timeout, $rest){
		$scope.language = "c++";

		$scope.codeOption = {
		    lineNumbers: true,
		    indentWithTabs: true,
		    readOnly: "nocursor",
		    viewportMargin: Infinity,
		    mode: "text/x-c++src",
		    onLoad: function(_editor){
		    	_editor.setSize(null, "50%");
		    }
		};

		$scope.getProgramText = function(){
			var params = {"programming_task_id": $scope.programming_task_id, "language": $scope.language};
			$rest.setRequestSuffix('.json');
			$rest.one('programming_answer_sheets', $scope.programmingAnswerSheet.id).one('get_program').get(params)
			.then(function(data){
				$scope.programText = data.programText;
			}, function(){
				alert("Get program text request failed");
			});
		};

		$scope.getUser = function(){
			$rest.setRequestSuffix('.json');
			$rest.one('users', $scope.programmingAnswerSheet.user_id).get()
			.then(function(data){
				$scope.user = data.user;
			}, function(){
				alert("Get user request failed.");
			});
		};

		$scope.init = function(id){
			$rest.setRequestSuffix('.json');
			$rest.one('programming_answer_sheets', id).get()
			.then(function(data){
				$scope.programmingAnswerSheet = data.programmingAnswerSheet;
				$scope.programming_task_id = $scope.programmingAnswerSheet.programming_tasks[0];
				$scope.getProgramText();
				$scope.getUser();
			}, function(){
				alert("Get programming answer-sheet request failed.");
			});
			$rest.setRequestSuffix('');
		};

		$scope.changeProgram = function(programming_task_id){
			$scope.programming_task_id = programming_task_id;
			$scope.getProgramText();
		};

		$scope.changeLanguage = function(lang){
			$scope.language = lang;
			if($scope.language == "c++")
				$scope.codeOption.mode = "text/x-c++src";
			else if($scope.language == "java")
				$scope.codeOption.mode = "text/x-java";
			$scope.getProgramText();
		};
	}]);