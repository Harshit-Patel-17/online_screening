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
		$scope.reviewMarkers = [];

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

		$scope.initDataStructures = function(){
			$scope.question_categories = [];
			$scope.question_ids = [];
			$scope.question_counts = [];
			$scope.scanned_question_counts = [];
			angular.forEach($scope.answerSheet.questions, function(value, key){
				$scope.question_categories.push(key);
				$scope.question_counts.push(value.length);
				for(i = 0; i < value.length; i++)
					$scope.question_ids.push(value[i]);
			});
			for(i = 0; i < $scope.question_counts.length; i++){
				if(i == 0)
					$scope.scanned_question_counts[i] = 0;
				else
					$scope.scanned_question_counts[i] = $scope.scanned_question_counts[i-1] + $scope.question_counts[i-1];
			}
			$scope.question_ids_index = 0;
			$scope.question_index = 0;
			$scope.question_id = $scope.question_ids[0];
			$scope.question_category = $scope.question_categories[0];
			$scope.getQuestion();
			$scope.$watch('question_ids_index', function(qid){
				for(i = 0; i < $scope.scanned_question_counts.length; i++)
					if($scope.question_ids_index < $scope.scanned_question_counts[i])
						break;
				i--;
				$scope.question_index = $scope.question_ids_index - $scope.scanned_question_counts[i];
				$scope.question_category = $scope.question_categories[i];
				$scope.question_id = $scope.question_ids[$scope.question_ids_index];
				$scope.getQuestion();
			}, true);
		};

		$scope.nextQuestion = function(){
			$scope.storeAnswer();
			$scope.question_ids_index++;
			if($scope.question_ids_index == $scope.question_ids.length - 1)
				$scope.nextEnabled = false;
			$scope.prevEnabled =  true;
		};

		$scope.prevQuestion = function(){
			$scope.storeAnswer();
			$scope.question_ids_index--;
			if($scope.question_ids_index == 0)
				$scope.prevEnabled = false;
			$scope.nextEnabled = true;
		};

		$scope.init = function(id){
			$rest.setRequestSuffix('.json');
			$rest.one('answer_sheets', id).get()
			.then(function(data){
				$scope.answerSheet = data.answerSheet;
				$scope.initTimer(data.answerSheet.end_time);
				$scope.initDataStructures();
			}, function(){
				alert("Get answer-sheet request failed.");
			});
			$rest.setRequestSuffix('');
		};

		$scope.initOptions = function(){
			$scope.answer = {};
			$scope.answer.checkboxes = [];
			if($scope.question.qtype == 'mcq'){
				$scope.answer.radio = $scope.answerSheet.answers[$scope.question_category][$scope.question_index][0];
			} else if($scope.question.qtype == 'multi'){
				for(i = 0; i < $scope.question.options.length; i++){
					index = $scope.answerSheet.answers[$scope.question_category][$scope.question_index].indexOf(i+"");
					if(index > -1)
						$scope.answer.checkboxes[i] = true;
					else
						$scope.answer.checkboxes[i] = false;
				}
			} else if($scope.question.qtype == 'numerical'){
				$scope.answer.number = parseFloat($scope.answerSheet.answers[$scope.question_category][$scope.question_index][0]);
			}
		};

		$scope.storeAnswer = function(){
			$scope.answerSheet.answers[$scope.question_category][$scope.question_index] = [];
			if($scope.question.qtype == 'mcq'){
				if($scope.answer.radio != null)
					$scope.answerSheet.answers[$scope.question_category][$scope.question_index].push($scope.answer.radio);
			} else if($scope.question.qtype == 'multi'){
				for(i = 0; i < $scope.answer.checkboxes.length; i++){
					if($scope.answer.checkboxes[i])
						$scope.answerSheet.answers[$scope.question_category][$scope.question_index].push(i+"");
				}
			} else if($scope.question.qtype == 'numerical') {
				if(!isNaN($scope.answer.number))
					$scope.answerSheet.answers[$scope.question_category][$scope.question_index].push($scope.answer.number+"");
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

		$scope.getQuestion = function(){
			$rest.setRequestSuffix('.json');
			$rest.one('questions', $scope.question_id).one('without_answers').get()
			.then(function(data){
				$scope.question = data.question;
				$scope.answer = {"options": []};
				$scope.initOptions();
			}, function(){
				alert("Get question request failed.");
			});
			$rest.setRequestSuffix('');
		};

		$scope.gotoQuestion = function(category, index){
			$scope.question_category = category;
			$scope.question_index = index;
			$scope.question_ids_index = $scope.scanned_question_counts[$scope.question_categories.indexOf(category)] + index;
		};

		$scope.markForReview = function(index){
			$scope.reviewMarkers[index] = true;
		};

		$scope.unmarkForReview = function(index){
			$scope.reviewMarkers[index] = false;
		};
	}]);