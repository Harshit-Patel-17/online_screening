angular.module('onlineScreening')
.controller('ProgrammingTaskIndexCtrl', [
	'$scope',
	'$http',
	'$timeout',
	'Restangular',
	function($scope, $http, $timeout, $rest){
		$scope.getProgrammingTasks = function(){
			$rest.all('programming_tasks.json').get('')
			.then(function(data){
				$scope.programmingTasks = data.programmingTasks;
			},function(){
				alert("Error in fetching programming tasks.");
			});
		};

		$scope.gridOptions = {
	      data: 'programmingTasks',
	      columnDefs: 'columnDefs',
	      showFooter: true,
	      plugins: [new ngGridFlexibleHeightPlugin()]
   	 	};


   	 	$scope.deleteProgrammingTask = function(id){
   	 		if(!confirm("Are you sure about deleting the programming task?"))
        		return
   	 		$rest.one('programming_tasks', id).remove()
   	 		.then(function(data){
   	 			$scope.message = data.reply;
   	 			$scope.getProgrammingTasks();
   	 		}, function(){
   	 			alert('Delete request failed.')
   	 		});
   	 	};

	    var edit_path = "{{'/programming_tasks/'+row.getProperty('id')+'/edit'}}";
	    var show_path = "{{'/programming_tasks/'+row.getProperty('id')}}";
	    var delete_call = "deleteProgrammingTask(row.getProperty('id'))";
	    var linkCellTemplate = '<a data-method="get" href="'+ edit_path +'"><i class="glyphicon glyphicon-cog"></i></a>'
	    						+ ' <a data-method="get" href="'+ show_path +'"><i class="glyphicon glyphicon-eye-open"></i></a>'
	    						+ ' <a ng-click="' + delete_call + '"><i class="glyphicon glyphicon-remove"></i></a>';

	    $scope.columnDefs = [
	    	{ field: 'id', displayName: 'Id', width: '5%'},
	    	{ field: 'task_name', displayName: 'Task Name', width: '15%'},
	    	{ field: 'task', displayName: 'Task'},
	    	{ field: 'hint', displayName: 'Hint', width: '10%'},
	    	{ field: 'href', displayName: 'Links', width: '5%', cellTemplate: linkCellTemplate}
	    ];

	    $scope.getProgrammingTasks();
	}]);