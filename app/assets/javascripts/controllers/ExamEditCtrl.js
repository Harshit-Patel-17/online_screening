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
				$scope.exam.date = new Date($scope.exam.date);
				$scope.exam.start_window_time = new Date($scope.exam.start_window_time);
				$scope.exam.end_window_time = new Date($scope.exam.end_window_time);
			}, function(){
				alert("Get exam request failed.");
			});
			$rest.setRequestSuffix('');
		};
	}]);