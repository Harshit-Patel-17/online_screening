angular.module('onlineScreening')
.controller('ExamSelectQuestionsCtrl', [
	'$scope',
	'$http',
	'Restangular',
	function($scope, $http, $rest){
		$scope.init = function(id){
			$scope.exam_id = id;
			$rest.one('exams', $scope.exam_id).one('questions.json').get()
			.then(function(data){
				$scope.questions = data.questions;
				$scope.selected_questions = data.selected_questions
				$scope.selection = [];
				for(i = 0; i < $scope.selected_questions.length; i++){
					$scope.selection[$scope.selected_questions[i]] = true;
				}
			},function(){
				alert("Error in fetching questions.");
			});
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