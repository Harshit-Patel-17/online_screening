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
				$scope.getQuestionPerWeightages();
				$scope.getExamScheme();
			},function(){
				alert("Error in fetching question_categories.");
			});
		};

		$scope.getQuestionPerWeightages = function(){
			$rest.all('questions/questions_per_weightage').get('')
			.then(function(data){
				$scope.qpw = data.qpw;
			}, function(){
				alert('Get questions per weightage request failed.');
			});
		};

		$scope.getExamScheme = function(){
			$rest.one('exams', $scope.exam_id).one('scheme.json').get()
			.then(function(data){
				$scope.examScheme = data.examScheme;
				for(i = 0; i < $scope.questionCategories.length; i++){
					if(!$scope.examScheme[$scope.questionCategories[i].id])
						$scope.examScheme[$scope.questionCategories[i].id] = {};
				}
			}, function(){
				alert('Get question count per weightage request failed.');
			});
		};

		$scope.validateAndSubmitExamScheme = function(){
			schemeValid = true;
			angular.forEach($scope.examScheme, function(scheme, category_id){
				allZeros = true;
				angular.forEach(scheme, function(count, weightage){
					if($scope.qpw[category_id][weightage] < count){
						schemeValid = false;
					}
					if(count){
						allZeros = false;
					}
				});
				if(allZeros)
					delete $scope.examScheme[category_id];
			});
			if(schemeValid){
				$scope.submitExamScheme();
			} else {
				alert("Invalid scheme");
			}
		};

		$scope.submitExamScheme = function(){
			params = {'exam_scheme': $scope.examScheme};
			$rest.one('exams', $scope.exam_id).one('scheme.json').post('', params)
			.then(function(data){
				window.location.href = "/exams/" + $scope.exam_id + "/questions";
			}, function(){
				alert('Post exam scheme request failed.');
			});
		};

		$scope.schemeCategoryTotal = function(question_category_id){
			var retVal = 0;
			angular.forEach($scope.examScheme[question_category_id], function(count, weightage){
				retVal = retVal + count;
			});
			return retVal;
		};

		$scope.categoryTotal = function(question_category_id){
			var retVal = 0;
			angular.forEach($scope.qpw[question_category_id], function(count, weightage){
				retVal = retVal + count;
			});
			return retVal;
		};

		$scope.categoryNameFromId = function(question_category_id){
			for(i = 0; i < $scope.questionCategories.length; i++){
				if($scope.questionCategories[i].id == question_category_id){	
					return $scope.questionCategories[i].category_name;
				}
			}
		};

	}]);