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
				$rest.all('exams/timezones.json').get('')
				.then(function(data){
					$scope.timezones = data.timezones;
					for(i = 0; i < $scope.timezones.length; i++){
						if($scope.timezones[i].timezone == $scope.exam.timezone){
							$scope.exam.timezone = $scope.timezones[i];
							break;
						}
					}
				}, function(){
					alert('Get timezones request failed');
				});
				$scope.exam.start_window_time = new Date($scope.exam.start_window_time);
				$scope.exam.end_window_time = new Date($scope.exam.end_window_time);
			}, function(){
				alert("Get exam request failed.");
			});
			$rest.setRequestSuffix('');
		};

		$scope.adjustTime = function(){
			$scope.exam.start_window_time = new Date(Date.parse($scope.exam.start_window_time) - $scope.exam.timezone.utc_offset * 1000);
			$scope.exam.end_window_time = new Date(Date.parse($scope.exam.end_window_time) - $scope.exam.timezone.utc_offset * 1000);
		};
	}]);