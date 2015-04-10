angular.module('onlineScreening')
.controller('ExamIndexCtrl', [
	'$scope',
	'$http',
	'$timeout',
	'Restangular',
	function($scope, $http, $timeout, $rest){
		$scope.getExams = function(){
			$rest.all('exams.json').get('')
			.then(function(data){
				$scope.exams = data.exams;
				$scope.current_server_time = parseInt(Date.parse(data.current_server_time)/1000);
				$timeout($scope.updateTime, 1000);
				$scope.classifyExams();
				$scope.showCurrentExams();
			},function(){
				alert("Error in fetching exams.");
			});
		};

		$scope.updateTime = function(){
			$scope.current_server_time++;
			$scope.classifyExams();
			$timeout($scope.updateTime, 1000);
		};
		
		$scope.classifyExams = function(){
			$scope.upcoming_exams = [];
			$scope.past_exams = [];
			$scope.current_exams = [];
			for(i = 0; i < $scope.exams.length; i++){
				start_time = parseInt(Date.parse($scope.exams[i].start_window_time)/1000);
				end_time = parseInt(Date.parse($scope.exams[i].end_window_time)/1000);
				if($scope.current_server_time > end_time)
					$scope.past_exams.push($scope.exams[i]);
				else if($scope.current_server_time > start_time)
					$scope.current_exams.push($scope.exams[i]);
				else
					$scope.upcoming_exams.push($scope.exams[i]);
			}
		};

		$scope.showCurrentExams = function(){
			$scope.active_view = "current_exams";
			$scope.gridData = $scope.current_exams;
		};

		$scope.showUpcomingExams = function(){
			$scope.active_view = "upcoming_exams";
			$scope.gridData = $scope.upcoming_exams;
		};

		$scope.showPastExams = function(){
			$scope.active_view = "past_exams";
			$scope.gridData = $scope.past_exams;
		};

		$scope.gridOptions = {
	      data: 'gridData',
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
	    						 + ' | <a data-method="get" href="' + select_question_path + '">Questions</a>';

	    $scope.columnDefs = [
	    	{ field: 'id', displayName: 'Id'},
	    	{ field: 'exam_name', displayName: 'Exam Name'},
	    	{ field: 'duration_mins', displayName: 'Duration (mins)'},
	    	{ field: 'start_window_time', displayName: 'SWT', cellFilter: 'date:\'dd-MMM-yyyy, hh:mm a\''},
	    	{ field: 'end_window_time', displayName: 'EWT', cellFilter: 'date:\'dd-MMM-yyyy, hh:mm a\''},
	    	{ field: 'select', displayName: 'Select', cellTemplate: selectCellTemplate},
	    	{ field: 'href', displayName: 'Links', cellTemplate: linkCellTemplate}
	    ];

	    $scope.getExams();
	}]);