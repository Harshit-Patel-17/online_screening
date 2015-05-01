angular.module('onlineScreening')
.controller('ProgrammingExamSelectProgrammingTasksCtrl', [
	'$scope',
	'$http',
	'Restangular',
	function($scope, $http, $rest){
		$scope.init = function(id){
			$scope.programming_exam_id = id;

			$rest.setRequestSuffix('.json');
			$rest.one('programming_exams', $scope.programming_exam_id).get()
			.then(function(data){
				$scope.programming_exam = data.programming_exam;
				$scope.programming_exam.start_window_time = (new Date($scope.programming_exam.start_window_time)).toLocaleString();
				$scope.programming_exam.end_window_time =( new Date($scope.programming_exam.end_window_time)).toLocaleString();
			}, function(){
				alert("Get programming exam request failed.");
			});
			
			$rest.one('programming_exams', $scope.programming_exam_id).one('programming_tasks.json').get()
			.then(function(data){
				$scope.programming_tasks = data.programming_tasks;
				$scope.selected_programming_tasks = data.selected_programming_tasks
				$scope.selection = [];
				for(i = 0; i < $scope.selected_programming_tasks.length; i++){
					$scope.selection[$scope.selected_programming_tasks[i]] = true;
				}
			},function(){
				alert("Error in fetching programming tasks.");
			});
		};
		

		$scope.gridOptions = {
	      data: 'programming_tasks',
	      columnDefs: 'columnDefs',
	      showFooter: true,
	      plugins: [new ngGridFlexibleHeightPlugin()]
	    };

	    var edit_path = "{{'/programming_tasks/'+row.getProperty('id')+'/edit'}}";
	    var show_path = "{{'/programming_tasks/'+row.getProperty('id')}}";
	    var linkCellTemplate = '<a data-method="get" href="'+ edit_path +'"><i class="glyphicon glyphicon-cog"></i></a>'
	   							+ ' <a data-method="get" href="'+ show_path +'"><i class="glyphicon glyphicon-eye-open"></i></a>';

	   	var name = "row.getProperty('id')";
	   	var selectionCellTemplate = '<center><input ng-model="selection[' + name + ']" type="checkbox" name="programming_task_ids[]" value="{{' + name + '}}"></input></center>';
	    
	    $scope.columnDefs = [
	    	{ field: 'id', displayName: 'Id', width: "5%"},
	    	{ field: 'selection', displayName: 'Choose', width: "5%", cellTemplate: selectionCellTemplate},
	    	{ field: 'task', displayName: 'Task', width: "15%"},
	    	{ field: 'task', displayName: 'Task'},
	    	{ field: 'href', displayName: 'Links', enableCellEdit: false, cellTemplate: linkCellTemplate, width: "5%"}
	    ];
	}]);