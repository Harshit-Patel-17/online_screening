angular.module('onlineScreening')
.controller('ProgrammingExamIndexCtrl', [
	'$scope',
	'$http',
	'$timeout',
	'Restangular',
	function($scope, $http, $timeout, $rest){
		$scope.getProgrammingExams = function(){
			$rest.all('programming_exams.json').get('')
			.then(function(data){
				$scope.programming_exams = data.programming_exams;
				$scope.current_server_time = parseInt(Date.parse(data.current_server_time)/1000);
				$timeout($scope.updateTime, 1000);
				$scope.classifyProgrammingExams();
				$scope.showCurrentProgrammingExams();
			},function(){
				alert("Error in fetching programming exams.");
			});
		};

		$scope.updateTime = function(){
			$scope.current_server_time++;
			$scope.classifyProgrammingExams();
			$timeout($scope.updateTime, 1000);
		};
		
		$scope.classifyProgrammingExams = function(){
			$scope.upcoming_programming_exams = [];
			$scope.past_programming_exams = [];
			$scope.current_programming_exams = [];
			for(i = 0; i < $scope.programming_exams.length; i++){
				start_time = parseInt(Date.parse($scope.programming_exams[i].start_window_time)/1000);
				end_time = parseInt(Date.parse($scope.programming_exams[i].end_window_time)/1000);
				if($scope.current_server_time > end_time)
					$scope.past_programming_exams.push($scope.programming_exams[i]);
				else if($scope.current_server_time > start_time)
					$scope.current_programming_exams.push($scope.programming_exams[i]);
				else
					$scope.upcoming_programming_exams.push($scope.programming_exams[i]);
			}
			$scope.total_current_programming_exams = $scope.current_programming_exams.length;
			$scope.total_upcoming_programming_exams = $scope.upcoming_programming_exams.length;
			$scope.total_past_programming_exams = $scope.past_programming_exams.length;
		};

		$scope.showCurrentProgrammingExams = function(){
			$scope.active_view = "current_programming_exams";
			$scope.gridData = $scope.current_programming_exams;
		};

		$scope.showUpcomingProgrammingExams = function(){
			$scope.active_view = "upcoming_programming_exams";
			$scope.gridData = $scope.upcoming_programming_exams;
		};

		$scope.showPastProgrammingExams = function(){
			$scope.active_view = "past_programming_exams";
			$scope.gridData = $scope.past_programming_exams;
		};

		$scope.gridOptions = {
	      data: 'gridData',
	      columnDefs: 'columnDefs',
	      showFooter: true,
	      plugins: [new ngGridFlexibleHeightPlugin()]
   	 	};


   	 	$scope.deleteProgrammingExam = function(id){
   	 		if(!confirm("Are you sure about deleting the programming exam?"))
        		return
   	 		$rest.one('programming_exams', id).remove()
   	 		.then(function(data){
   	 			$scope.message = data.reply;
   	 			$scope.getProgrammingExams();
   	 		}, function(){
   	 			alert('Delete request failed.')
   	 		});
   	 	};

	    var edit_path = "{{'/programming_exams/'+row.getProperty('id')+'/edit'}}";
	    var show_path = "{{'/programming_exams/'+row.getProperty('id')}}";
	    var delete_call = "deleteProgrammingExam(row.getProperty('id'))";
	    var toggle_exam_status_call = "toggleStatus(row.getProperty('id'), row.getProperty('status'))";
	    var select_college_path = "{{'/programming_exams/'+row.getProperty('id')+'/colleges'}}";
	    var select_programming_task_path = "{{'/programming_exams/'+row.getProperty('id')+'/programming_tasks'}}";
	    var linkCellTemplate = '<a data-method="get" href="'+ edit_path +'"><i class="glyphicon glyphicon-cog"></i></a>'
	    						+ ' <a data-method="get" href="'+ show_path +'"><i class="glyphicon glyphicon-eye-open"></i></a>'
	    						+ ' <a ng-click="' + delete_call + '"><i class="glyphicon glyphicon-remove"></i></a>';
	    var statusCellTemplate = '<span>{{row.getProperty("status")}}</span> <a ng-click="'+ toggle_exam_status_call +'"><i class="glyphicon glyphicon-off"></i></a>';
	    var selectCellTemplate = '<a data-method="get" href="' + select_college_path + '">Colleges</a>'
	    						 + ' | <a data-method="get" href="' + select_programming_task_path + '">Tasks</a>';

	    $scope.columnDefs = [
	    	{ field: 'id', displayName: 'Id'},
	    	{ field: 'exam_name', displayName: 'Exam Name'},
	    	{ field: 'duration_mins', displayName: 'Duration (mins)'},
	    	{ field: 'start_window_time', displayName: 'SWT', cellFilter: 'date:\'dd-MMM-yyyy, hh:mm a\''},
	    	{ field: 'end_window_time', displayName: 'EWT', cellFilter: 'date:\'dd-MMM-yyyy, hh:mm a\''},
	    	{ field: 'select', displayName: 'Select', cellTemplate: selectCellTemplate},
	    	{ field: 'href', displayName: 'Links', cellTemplate: linkCellTemplate}
	    ];

	    $scope.getProgrammingExams();
	}]);