angular.module('onlineScreening')
.controller('ExamSelectQuestionsCtrl', [
	'$scope',
	'$http',
	'Restangular',
	function($scope, $http, $rest){
		$scope.init = function(id){
			$scope.exam_id = id;

			$rest.setRequestSuffix('.json');
			$rest.one('exams', $scope.exam_id).get()
			.then(function(data){
				$scope.exam = data.exam;
				$scope.exam.start_window_time = (new Date($scope.exam.start_window_time)).toLocaleString();
				$scope.exam.end_window_time =( new Date($scope.exam.end_window_time)).toLocaleString();
			}, function(){
				alert("Get exam request failed.");
			});
			
			$rest.one('exams', $scope.exam_id).one('question_categories.json').get()
			.then(function(data){
				$scope.questionCategories = data.questionCategories;
				if($scope.questionCategories[0]){
					$scope.question_category = $scope.questionCategories[0];
					$scope.getQuestions();
				}
				$scope.$watch('question_category', function(newVal){
					$scope.getQuestions();
				}, true);
			},function(){
				alert("Error in fetching question_categories.");
			});
		};

		$scope.getQuestions = function(){
			params = {"question_category_id": $scope.question_category.id};
			$rest.one('exams', $scope.exam_id).one('questions.json').get(params)
			.then(function(data){
				$scope.questions = data.questions;
				$scope.selected_questions = data.selected_questions
				$scope.scheme = data.scheme;
				$scope.selection = [];
				for(i = 0; i < $scope.selected_questions.length; i++){
					$scope.selection[$scope.selected_questions[i]] = true;
				}
			},function(){
				alert("Error in fetching questions.");
			});
		};

		$scope.getSelectionCountForWeightage = function(weightage){
			var retVal = 0;
			for(i = 0; i < $scope.questions.length; i++){
				if($scope.questions[i].weightage == weightage && $scope.selection[$scope.questions[i].id])
					retVal++;
			}
			return retVal;
		};
		

		$scope.gridOptions = {
	      data: 'questions',
	      columnDefs: 'columnDefs',
	      showFooter: true,
	      plugins: [new ngGridFlexibleHeightPlugin()]
	    };

	    var edit_path = "{{'/questions/'+row.getProperty('id')+'/edit'}}";
	    var show_path = "{{'/questions/'+row.getProperty('id')}}";
	    var linkCellTemplate = '<a href="'+ edit_path +'"><i class="glyphicon glyphicon-cog"></i></a>'
	   							+ ' <a href="'+ show_path +'"><i class="glyphicon glyphicon-eye-open"></i></a>';

	   	var name = "row.getProperty('id')";
	   	var selectionCellTemplate = '<center><input ng-model="selection[' + name + ']" type="checkbox" name="question_ids[]" value="{{' + name + '}}"></input></center>';
	    
	    $scope.columnDefs = [
	    	{ field: 'id', displayName: 'Id', width: "10%"},
	    	{ field: 'selection', displayName: 'Choose', width: "5%", cellTemplate: selectionCellTemplate},
	    	{ field: 'weightage', displayName: 'Weightage', width: "10%"},
	    	{ field: 'question', displayName: 'Question Text', width: "65%"	},
	    	{ field: 'href', displayName: 'Links', enableCellEdit: false, cellTemplate: linkCellTemplate}
	    ];
	}]);