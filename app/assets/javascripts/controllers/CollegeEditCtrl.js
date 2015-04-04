angular.module('onlineScreening')
.controller('CollegeEditCtrl', [
	'$scope',
	'$http',
	'Restangular',
	function($scope, $http, $rest){
		$scope.init = function(id){
			$rest.setRequestSuffix('.json');
			$rest.one('colleges', id).get()
			.then(function(data){
				$scope.college = data.college;
			}, function(){
				alert("Get college request failed.");
			});
			$rest.setRequestSuffix('');
		};
	}]);