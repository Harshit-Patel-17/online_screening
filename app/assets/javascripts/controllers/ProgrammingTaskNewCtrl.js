angular.module('onlineScreening')
.controller('ProgrammingTaskNewCtrl', [
	'$scope',
	'$http',
	'Restangular',
	function($scope, $http, $rest){
		$scope.testCasesCount = 1;
		$scope.testInputs = [];
		$scope.testOutputs = [];
		$scope.testMarks = [];

		$scope.addTestCase = function(){
			$scope.testCasesCount++;
		};

		$scope.removeTestCase = function(index){
			$scope.testCasesCount--;
			$scope.testInputs.splice(index, 1);
			$scope.testOutputs.splice(index, 1);
			$scope.testMarks.splice(index, 1);
		};
	}]);