angular.module('onlineScreening')
.controller('QuestionNewCtrl', [
	'$scope',
	'$http',
	'Restangular',
	function($scope, $http, $rest){
		$scope.qtype = "mcq";
		$scope.no_of_options = 1;
		$scope.options = true;
		$scope.selection_box = "radio";

		$rest.all('question_categories.json').get('')
		.then(function(data){
			$scope.questionCategories = data.questionCategories;
		}, function(){
			alert("Get question categories request failed.");
		});

		$scope.$watch('qtype', function(newVal){
			if(newVal == "mcq"){
				$scope.options = true;
				$scope.selection_box = "radio";
			} else if(newVal == "multi") {
				$scope.options = true;
				$scope.selection_box = "checkbox";
			} else
				$scope.options = false;
		});
	}]);