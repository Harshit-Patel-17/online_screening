angular.module('onlineScreening')
.controller('ProgrammingExamShowCtrl', [
	'$scope',
	'$http',
	'Restangular',
	function($scope, $http, $rest){
		$scope.init = function(id){
			$rest.setRequestSuffix('.json');
			$rest.one('programming_exams', id).get()
			.then(function(data){
				$scope.programming_exam = data.programming_exam;
				$scope.programming_exam.start_window_time = (new Date($scope.programming_exam.start_window_time)).toLocaleString();
				$scope.programming_exam.end_window_time =( new Date($scope.programming_exam.end_window_time)).toLocaleString();
			}, function(){
				alert("Get programming exam request failed.");
			});
		};
	}]);