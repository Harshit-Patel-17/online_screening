angular.module('onlineScreening')
.controller('ExamShowSchemeCtrl', [
	'$scope',
	'$http',
	'Restangular',
	function($scope, $http, $rest){
		$scope.init = function(id){
			$scope.exam_id = id;
			$rest.all('question_categories.json').get('')
			.then(function(data){
				$scope.questionCategories = data.questionCategories;
				if($scope.questionCategories[0])
					$scope.question_category = $scope.questionCategories[0];
			},function(){
				alert("Error in fetching question_categories.");
			});
		};

		$scope.$watch('question_category', function(newVal){
			params = {"question_category_id": $scope.question_category.id};
			$rest.all('questions/questions_per_weightage').get('', params)
			.then(function(data){
				$scope.qpw = data.qpw;
			}, function(){
				alert('Get questions per weightage request failed.');
			});

			$rest.one('exams', $scope.exam_id).one('scheme.json').get(params)
			.then(function(data){
				$scope.scheme = data.scheme;
			}, function(){
				alert('Get question count per weightage request failed.');
			});
		}, true);
	}]);