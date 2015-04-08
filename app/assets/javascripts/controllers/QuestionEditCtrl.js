angular.module('onlineScreening')
.controller('QuestionEditCtrl', [
	'$scope',
	'$http',
	'Restangular',
	function($scope, $http, $rest){
		$scope.init = function(id){
			$rest.setRequestSuffix('.json');
			$rest.one('questions', id).get()
			.then(function(data){
				$scope.question = data.question;
				if($scope.question.qtype == "numerical")
					$scope.question.answers[0] = parseFloat($scope.question.answers[0]);
			}, function(){
				alert("Get question request failed.");
			});
			$rest.all('question_categories.json').get('')
			.then(function(data){
				$scope.questionCategories = data.questionCategories;
			}, function(){
				alert("Get question categories request failed.");
			});
		};

		$scope.$watch('question.qtype', function(newVal){
			if(newVal == "mcq"){
				$scope.options = true;
				$scope.selection_box = "radio";
			} else if(newVal == "multi") {
				$scope.options = true;
				$scope.selection_box = "checkbox";
			} else if(newVal == 'numerical') {
				$scope.options = false;
			}
		});
	}]);