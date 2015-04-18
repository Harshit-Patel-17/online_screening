angular.module('onlineScreening')
.controller('ProgrammingExamEditCtrl', [
	'$scope',
	'$http',
	'Restangular',
	function($scope, $http, $rest){
		$scope.init = function(id){
			$rest.setRequestSuffix('.json');
			$rest.one('programming_exams', id).get()
			.then(function(data){
				$scope.programming_exam = data.programming_exam;
				$rest.all('programming_exams/timezones.json').get('')
				.then(function(data){
					$scope.timezones = data.timezones;
					for(i = 0; i < $scope.timezones.length; i++){
						if($scope.timezones[i].timezone == $scope.programming_exam.timezone){
							$scope.programming_exam.timezone = $scope.timezones[i];
							break;
						}
					}
				}, function(){
					alert('Get timezones request failed');
				});
				$scope.programming_exam.start_window_time = new Date($scope.programming_exam.start_window_time);
				$scope.programming_exam.end_window_time = new Date($scope.programming_exam.end_window_time);
			}, function(){
				alert("Get programming exam request failed.");
			});
			$rest.setRequestSuffix('');
		};

		$scope.adjustTime = function(){
			$scope.programming_exam.start_window_time = new Date(Date.parse($scope.programming_exam.start_window_time) - $scope.programming_exam.timezone.utc_offset * 1000);
			$scope.programming_exam.end_window_time = new Date(Date.parse($scope.programming_exam.end_window_time) - $scope.programming_exam.timezone.utc_offset * 1000);
		};
	}]);