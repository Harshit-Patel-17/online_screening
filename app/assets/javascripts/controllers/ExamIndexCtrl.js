angular.module('onlineScreening')
.controller('ExamIndexCtrl', [
	'$scope',
	'$http',
	'Restangular',
	function($scope, $http, $rest){
		$rest.all('exams.json').get('')
		.then(function(data){
			$scope.exams = data.exams;
		},function(){
			alert("Error in fetching exams.");
		});
		

		$scope.gridOptions = {
	      data: 'exams',
	      columnDefs: 'columnDefs',
	      showFooter: true,
	      plugins: [new ngGridFlexibleHeightPlugin()]
   	 	};

    var edit_path = "{{'/exams/'+row.getProperty('id')+'/edit'}}";
    var show_path = "{{'/exams/'+row.getProperty('id')}}";
    var linkCellTemplate = '<a href="'+ edit_path +'"><i class="glyphicon glyphicon-cog"></i></a>'
    						+ ' <a href="'+ show_path +'"><i class="glyphicon glyphicon-eye-open"></i></a>';
    
    $scope.columnDefs = [
    	{ field: 'id', displayName: 'Id'},
    	{ field: 'exam_name', displayName: 'Exam Name'},
    	{ field: 'college_name', displayName: 'College Name'},
    	{ field: 'date', displayName: 'Date'},
    	{ field: 'duration_mins', displayName: 'Duration'},
    	{ field: 'start_window_time', displayName: 'SWT'},
    	{ field: 'end_window_time', displayName: 'EWT'},
    	{ field: 'status', displayName: 'Status'},
    	{ field: 'href', displayName: 'Links', enableCellEdit: false, cellTemplate: linkCellTemplate}
    ];
	}]);