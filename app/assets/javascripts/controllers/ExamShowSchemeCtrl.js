angular.module('onlineScreening')
.controller('ExamShowSchemeCtrl', [
	'$scope',
	'$http',
	'Restangular',
	function($scope, $http, $rest){
		$scope.init = function(id){
			$scope.exam_id = id;
			$scope.getData();
		};
		$scope.getData = function(){
			$rest.all('questions/questions_per_weightage').get('')
			.then(function(data){
				$scope.qpw = data.qpw;
			}, function(){
				alert('Get questions per weightage request failed.');
			});

			$rest.one('exams', $scope.exam_id).one('scheme.json').get()
			.then(function(data){
				$scope.scheme = data.scheme;
			}, function(){
				alert('Get question count per weightage request failed.');
			});
		};
	}]);