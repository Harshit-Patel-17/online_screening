angular.module('onlineScreening')
.controller('ExamEditCtrl', [
	'$scope',
	'$http',
	'Restangular',
	function($scope, $http, $rest){
		$scope.init = function(id){
			$rest.setRequestSuffix('.json');
			$rest.one('exams', id).get()
			.then(function(data){
				$scope.exam = data.exam;
				$scope.tz_offset = (new Date()).getTimezoneOffset() * 60 * 1000;
				$scope.exam.start_window_time = new Date(Date.parse($scope.exam.start_window_time) + $scope.tz_offset);
				$scope.exam.end_window_time = new Date(Date.parse($scope.exam.end_window_time) + $scope.tz_offset);
			}, function(){
				alert("Get exam request failed.");
			});
			$rest.setRequestSuffix('');
		};
	}]);