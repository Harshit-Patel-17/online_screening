angular.module('onlineScreening')
.controller('CollegeIndexCtrl', [
	'$scope',
	'$http',
	'Restangular',
	function($scope, $http, $rest){
		$scope.getColleges = function(){
			$rest.all('colleges.json').get('')
			.then(function(data){
				$scope.colleges = data.colleges;
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

   	 	$scope.deleteCollege = function(id){
   	 		if(!confirm("Are you sure about deleting the college?"))
        		return
   	 		$rest.one('colleges', id).remove()
   	 		.then(function(data){
   	 			$scope.message = data.reply;
   	 			$scope.getColleges();
   	 		}, function(){
   	 			alert('Delete request failed.')
   	 		});
   	 	};

	    var edit_path = "{{'/colleges/'+row.getProperty('id')+'/edit'}}";
	    var show_path = "{{'/colleges/'+row.getProperty('id')}}";
	    var delete_call = "deleteCollege(row.getProperty('id'))"
	    var linkCellTemplate = '<a href="'+ edit_path +'"><i class="glyphicon glyphicon-cog"></i></a>'
	    						+ ' <a href="'+ show_path +'"><i class="glyphicon glyphicon-eye-open"></i></a>'
	    						+ ' <a ng-click="' + delete_call + '"><i class="glyphicon glyphicon-remove"></i></a>';

	    $scope.columnDefs = [
	    	{ field: 'id', displayName: 'Id'},
	    	{ field: 'institute_name', displayName: 'Institute Name'},
	    	{ field: 'branch_name', displayName: 'Branch Name'},
	    	{ field: 'href', displayName: 'Links', cellTemplate: linkCellTemplate}
	    ];

	    $scope.getColleges();
	}]);