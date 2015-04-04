angular.module('onlineScreening')
.controller('ExamSelectCollegesCtrl', [
	'$scope',
	'$http',
	'Restangular',
	function($scope, $http, $rest){
		$scope.init = function(id){
			$scope.college_id = id;
			$rest.all('colleges.json').get('')
			.then(function(data){
				$scope.colleges = data.colleges;
			},function(){
				alert("Error in fetching colleges.");
			});
			$scope.selection = [];
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