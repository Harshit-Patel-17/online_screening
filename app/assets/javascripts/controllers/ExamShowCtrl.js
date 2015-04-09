angular.module('onlineScreening')
.controller('ExamShowCtrl', [
	'$scope',
	'$http',
	'Restangular',
	function($scope, $http, $rest){
		$scope.init = function(id){
			$rest.setRequestSuffix('.json');
			$rest.one('exams', id).get()
			.then(function(data){
				$scope.exam = data.exam;
				$scope.exam.start_window_time = (new Date($scope.exam.start_window_time)).toLocaleString();
				$scope.exam.end_window_time =( new Date($scope.exam.end_window_time)).toLocaleString();
			}, function(){
				alert("Get exam request failed.");
			});
			$rest.setRequestSuffix('');
		};
	}]);