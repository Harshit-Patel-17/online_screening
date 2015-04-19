angular.module('onlineScreening')
.controller('ProgrammingAnswerSheetReviewCtrl', [
	'$scope',
	'$http',
	'$timeout',
	'Restangular',
	function($scope, $http, $timeout, $rest){
		$scope.getProgramText = function(programming_task_id){
			$scope.programmingTaskId = programming_task_id
			var params = {"programming_task_id": programming_task_id};
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
				$scope.getProgramText($scope.programmingAnswerSheet.programming_tasks[0]);
				$scope.getUser();
			}, function(){
				alert("Get programming answer-sheet request failed.");
			});
			$rest.setRequestSuffix('');
		};

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
	}]);