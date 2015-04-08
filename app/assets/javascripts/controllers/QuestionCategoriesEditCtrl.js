angular.module('onlineScreening')
.controller('QuestionCategoriesEditCtrl', [
	'$scope',
	'$http',
	'Restangular',
	function($scope, $http, $rest){
		$scope.init = function(id){
			$rest.setRequestSuffix('.json');
			$rest.one('question_categories', id).get()
			.then(function(data){
				$scope.questionCategories = data.questionCategories;
			}, function(){
				alert("Get question category request failed.");
			});
			$rest.setRequestSuffix('');
		};
	}]);