angular.module('onlineScreening')
.controller('QuestionShowCtrl', [
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
		}
	}]);