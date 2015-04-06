angular.module('onlineScreening')
.controller('ExamIndexCtrl', [
	'$scope',
	'$http',
	'Restangular',
	function($scope, $http, $rest){
		$scope.getExams = function(){
			$rest.all('exams.json').get('')
			.then(function(data){
				$scope.exams = data.exams;
			},function(){
				alert("Error in fetching exams.");
			});
		};
		

		$scope.gridOptions = {
	      data: 'exams',
	      columnDefs: 'columnDefs',
	      showFooter: true,
	      plugins: [new ngGridFlexibleHeightPlugin()]
   	 	};

   	 	$scope.deleteExam = function(id){
   	 		if(!confirm("Are you sure about deleting the exam?"))
        		return
   	 		$rest.one('exams', id).remove()
   	 		.then(function(data){
   	 			$scope.message = data.reply;
   	 			$scope.getExams();
   	 		}, function(){
   	 			alert('Delete request failed.')
   	 		});
   	 	};

   	 	$scope.toggleStatus = function(id, oldStatus){
   	 		var newStatus;
   	 		if(oldStatus == 'inactive')
   	 			newStatus = 'active';
   	 		else
   	 			newStatus = 'inactive';
   	 		var params = {"exam": {"status": newStatus}};
   	 		$rest.one('exams', id).post('', params)
   	 		.then(function(data){
   	 			$scope.getExams();
   	 		}, function(){
   	 			alert('Status update request failed.')
   	 		});
   	 	};

	    var edit_path = "{{'/exams/'+row.getProperty('id')+'/edit'}}";
	    var show_path = "{{'/exams/'+row.getProperty('id')}}";
	    var delete_call = "deleteExam(row.getProperty('id'))";
	    var toggle_exam_status_call = "toggleStatus(row.getProperty('id'), row.getProperty('status'))";
	    var select_college_path = "{{'/exams/'+row.getProperty('id')+'/colleges'}}";
	    var select_question_path = "{{'/exams/'+row.getProperty('id')+'/scheme'}}";
	    var linkCellTemplate = '<a data-method="get" href="'+ edit_path +'"><i class="glyphicon glyphicon-cog"></i></a>'
	    						+ ' <a data-method="get" href="'+ show_path +'"><i class="glyphicon glyphicon-eye-open"></i></a>'
	    						+ ' <a ng-click="' + delete_call + '"><i class="glyphicon glyphicon-remove"></i></a>';
	    var statusCellTemplate = '<span>{{row.getProperty("status")}}</span> <a ng-click="'+ toggle_exam_status_call +'"><i class="glyphicon glyphicon-off"></i></a>';
	    var selectCellTemplate = '<a data-method="get" href="' + select_college_path + '">Colleges</a>'
	    						 + ' | <a data-method="get" href="' + select_question_path + '">Questions</a>';;
	    var startWindowTimeCellTemplate = '<span ng-bind="' + "row.getProperty('start_window_time') | timeZoneCorrection" + ' "></span>';
	    var endWindowTimeCellTemplate = '<span ng-bind="' + "row.getProperty('end_window_time') | timeZoneCorrection" + ' "></span>';

	    $scope.columnDefs = [
	    	{ field: 'id', displayName: 'Id'},
	    	{ field: 'exam_name', displayName: 'Exam Name'},
	    	{ field: 'duration_mins', displayName: 'Duration (mins)'},
	    	{ field: 'start_window_time', displayName: 'SWT', cellTemplate: startWindowTimeCellTemplate},
	    	{ field: 'end_window_time', displayName: 'EWT', cellTemplate: endWindowTimeCellTemplate},
	    	{ field: 'select', displayName: 'Select', cellTemplate: selectCellTemplate},
	    	{ field: 'href', displayName: 'Links', cellTemplate: linkCellTemplate}
	    ];

	    $scope.getExams();
	}]);