angular.module('onlineScreening')
.controller('AnswerSheetShowCtrl', [
	'$scope',
	'$http',
	'$timeout',
	'Restangular',
	function($scope, $http, $timeout, $rest){
		$scope.nextEnabled = true;
		$scope.prevEnabled = false;
		$scope.timer = {};

		$scope.countDown = function(){
			$scope.timer.total_secs--;
			$scope.timer.mins = Math.floor($scope.timer.total_secs/60);
			$scope.timer.secs = $scope.timer.total_secs % 60
			if($scope.timer.total_secs > 0)
				$timeout($scope.countDown, 1000);
			else
				window.location.href = "/answer_sheets/time_up"
		};

		$scope.initTimer = function(end_time){
			current_time = new Date();
			end_time = new Date(end_time);
			$scope.timer.total_secs = Math.floor((end_time - current_time)/1000);
			$scope.timer.mins = Math.floor($scope.timer.total_secs/60);
			$scope.timer.secs = $scope.timer.total_secs % 60
			$scope.countDown();
		};

		$scope.init = function(id){
			$rest.setRequestSuffix('.json');
			$rest.one('answer_sheets', id).get()
			.then(function(data){
				$scope.answerSheet = data.answerSheet;
				$scope.initTimer(data.answerSheet.end_time);
				$scope.question_index = 0;
				if($scope.answerSheet.questions.length == 1)
					$scope.nextEnabled = false;
				$scope.getQuestion($scope.question_index);
			}, function(){
				alert("Get answer-sheet request failed.");
			});
			$rest.setRequestSuffix('');
		};

		$scope.initOptions = function(qtype, options, answers){
			$scope.answer = {};
			$scope.answer.checkboxes = [];
			if($scope.question.qtype == 'mcq'){
				$scope.answer.radio = $scope.answerSheet.answers[$scope.question_index][0];
			} else if($scope.question.qtype == 'multi'){
				for(i = 0; i < options.length; i++){
					index = $scope.answerSheet.answers[$scope.question_index].indexOf(i+"");
					if(index > -1)
						$scope.answer.checkboxes[i] = true;
					else
						$scope.answer.checkboxes[i] = false;
				}
			}
		};

		$scope.storeAnswer = function(){
			$scope.answerSheet.answers[$scope.question_index] = [];
			if($scope.question.qtype == 'mcq'){
				$scope.answerSheet.answers[$scope.question_index].push($scope.answer.radio);
			} else if($scope.question.qtype == 'multi'){
				for(i = 0; i < $scope.answer.checkboxes.length; i++){
					if($scope.answer.checkboxes[i])
						$scope.answerSheet.answers[$scope.question_index].push(i+"");
				}
			}
			params = {"answer_sheet": {"answers": $scope.answerSheet.answers}};
			$rest.setRequestSuffix('.json');
			$rest.one('answer_sheets', $scope.answerSheet.id).post('', params)
			.then(function(data){

			}, function(){
				alert("Store answer request failed.");
			});
			$rest.setRequestSuffix('');
		};

		$scope.getQuestion = function(index){
			id = $scope.answerSheet.questions[index];
			$rest.setRequestSuffix('.json');
			$rest.one('questions', id).get()
			.then(function(data){
				$scope.question = data.question;
				$scope.answer = {"options": []};
				$scope.initOptions($scope.question.qtype, $scope.question.options, $scope.question.answers);
			}, function(){
				alert("Get question request failed.");
			});
			$rest.setRequestSuffix('');
		};

		$scope.nextQuestion = function(){
			$scope.storeAnswer();
			$scope.question_index++;
			if($scope.question_index == $scope.answerSheet.questions.length - 1)
				$scope.nextEnabled = false;
			$scope.prevEnabled =  true;
			$scope.getQuestion($scope.question_index);
		};

		$scope.prevQuestion = function(){
			$scope.storeAnswer();
			$scope.question_index--;
			if($scope.question_index == 0)
				$scope.prevEnabled = false;
			$scope.nextEnabled = true;
			$scope.getQuestion($scope.question_index);
		};
	}]);