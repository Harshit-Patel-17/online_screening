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
			}, function(){
				alert("Get question request failed.");
			});
			$rest.setRequestSuffix('');
		};

		$scope.$watch('question.qtype', function(newVal){
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