angular.module('onlineScreening')
.controller('ExamSelectCollegesCtrl', [
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

			$rest.one('exams', $scope.exam_id).one('colleges.json').get()
			.then(function(data){
				$scope.colleges = data.colleges;
				$scope.selected_colleges = data.selected_colleges
				$scope.selection = [];
				for(i = 0; i < $scope.selected_colleges.length; i++){
					$scope.selection[$scope.selected_colleges[i]] = true;
				}
			},function(){
				alert("Error in fetching colleges.");
			});
		};
		

		$scope.gridOptions = {
	      data: 'colleges',
	      columnDefs: 'columnDefs',
	      showFooter: true,
	      plugins: [new ngGridFlexibleHeightPlugin()]
	    };

	    var edit_path = "{{'/colleges/'+row.getProperty('id')+'/edit'}}";
	    var show_path = "{{'/colleges/'+row.getProperty('id')}}";
	    var linkCellTemplate = '<a data-method="get" href="'+ edit_path +'"><i class="glyphicon glyphicon-cog"></i></a>'
	   							+ ' <a data-method="get" href="'+ show_path +'"><i class="glyphicon glyphicon-eye-open"></i></a>';

	   	var name = "row.getProperty('id')";
	   	var selectionCellTemplate = '<center><input ng-model="selection[' + name + ']" type="checkbox" name="college_ids[]" value="{{' + name + '}}"></input></center>';
	    
	    $scope.columnDefs = [
	    	{ field: 'id', displayName: 'Id'},
	    	{ field: 'selection', displayName: 'Choose', width: "5%", cellTemplate: selectionCellTemplate},
	    	{ field: 'institute_name', displayName: 'Institute'},
	    	{ field: 'branch_name', displayName: 'Branch'},
	    	{ field: 'href', displayName: 'Links', enableCellEdit: false, cellTemplate: linkCellTemplate}
	    ];
	}]);