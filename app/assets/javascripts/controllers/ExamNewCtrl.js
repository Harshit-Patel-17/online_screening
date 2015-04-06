angular.module('onlineScreening')
.controller('ExamNewCtrl', [
	'$scope',
	'$http',
	'Restangular',
	function($scope, $http, $rest){
		$rest.all('exams/timezones.json').get('')
		.then(function(data){
			$scope.timezones = data.timezones;
		}, function(){
			alert('Get timezones request failed');
		});

		$scope.adjustTime = function(){
			$scope.start_window_time = new Date(Date.parse($scope.start_window_time) - $scope.timezone.utc_offset * 1000);
			$scope.end_window_time = new Date(Date.parse($scope.end_window_time) - $scope.timezone.utc_offset * 1000);
		};
	}]);