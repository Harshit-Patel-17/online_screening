angular.module('onlineScreening')
.controller('AnswerSheetReviewCtrl', [
	'$scope',
	'$http',
	'$timeout',
	'Restangular',
	function($scope, $http, $timeout, $rest){
		$scope.getQuestions = function(){
			$scope.questions = {};
			angular.forEach($scope.answerSheet.questions, function(question_ids, category){
				for(i = 0; i < question_ids.length; i++){
					$rest.setRequestSuffix('.json');
					$rest.one('questions', question_ids[i]).one('without_answers').get()
					.then(function(data){
						$scope.questions[data.question.id] = data.question;
					}, function(){
						alert("Get question request failed.");
					});
				}
			});
		};

		$scope.setAnswers = function(){
			$scope.answers = {};
			angular.forEach($scope.answerSheet.questions, function(question_ids, category){
				for(i = 0; i < question_ids.length; i++){
					$scope.answers[question_ids[i]] = $scope.answerSheet.answers[category][i];
				}
			});
		};

		$scope.getUser = function(){
			$rest.setRequestSuffix('.json');
			$rest.one('users', $scope.answerSheet.user_id).get()
			.then(function(data){
				$scope.user = data.user;
			}, function(){
				alert("Get question request failed.");
			});
		};

		$scope.init = function(id){
			$rest.setRequestSuffix('.json');
			$rest.one('answer_sheets', id).get()
			.then(function(data){
				$scope.answerSheet = data.answerSheet;
				$scope.getQuestions();
				$scope.setAnswers();
				$scope.getUser();
			}, function(){
				alert("Get answer-sheet request failed.");
			});
			$rest.setRequestSuffix('');
		};
	}]);