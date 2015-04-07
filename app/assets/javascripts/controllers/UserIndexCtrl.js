angular.module('onlineScreening')
.controller('UserIndexCtrl', [
	'$scope',
	'$http',
	'Restangular',
	function($scope, $http, $rest){
		$scope.params = {};
		$scope.getUsers = function(currentPage, pageSize){
			$scope.params.offset = (currentPage-1) * pageSize;
			$scope.params.limit = pageSize;
			$rest.all('users/non_admins.json').get('', $scope.params)
			.then(function(data){
				$scope.users = data.users;
			},function(){
				alert("Error in fetching users.");
			});
		};

		$scope.$watch('pagingOptions', function(){
			$scope.getUsers($scope.pagingOptions.currentPage, $scope.pagingOptions.pageSize);
		}, true);

		$scope.pagingOptions = {
      pageSizes: [5, 50, 100],
      pageSize: 5,
      totalServerItems: 0,
      currentPage: 1
    }; 

		$scope.getAdmins = function(){
			$rest.all('users/admins.json').get('')
			.then(function(data){
				$scope.admins = data.admins;
			},function(){
				alert("Error in fetching admins.");
			});
		};
		
		$scope.adminGridOptions = {
      data: 'admins',
      columnDefs: 'adminsColumnDefs',
      plugins: [new ngGridFlexibleHeightPlugin()]
 	 	};

		$scope.userGridOptions = {
      data: 'users',
      columnDefs: 'usersColumnDefs',
      enablePaging: true,
    	pagingOptions: $scope.pagingOptions,
    	showFooter: true,
      plugins: [new ngGridFlexibleHeightPlugin()]
 	 	};

 	 	$scope.deleteUser = function(id){
 	 		if(!confirm("Are you sure about deleting the user?"))
      		return
 	 		$rest.one('users', id).one('destroy').remove()
 	 		.then(function(data){
 	 			$scope.message = data.reply;
 	 			$scope.getUsers($scope.pagingOptions.currentPage, $scope.pagingOptions.pageSize);
        $scope.getAdmins();
 	 		}, function(){
 	 			alert('Delete request failed.')
 	 		});
 	 	};

    var delete_call = "deleteUser(row.getProperty('id'))";
    var linkCellTemplate = '<a ng-click="' + delete_call + '"><i class="glyphicon glyphicon-remove"></i></a>';

    $scope.usersColumnDefs = [
    	{ field: 'id', displayName: 'Id'},
    	{ field: 'first_name', displayName: 'First Name'},
    	{ field: 'last_name', displayName: 'Last Name'},
    	{ field: 'email', displayName: 'Email'},
    	{ field: 'college_id', displayName: 'College Id'},
    	{ field: 'href', displayName: 'Links', cellTemplate: linkCellTemplate}
    ];

    $scope.adminsColumnDefs = [
    	{ field: 'id', displayName: 'Id'},
    	{ field: 'first_name', displayName: 'First Name'},
    	{ field: 'email', displayName: 'Email'},
    	{ field: 'href', displayName: 'Links', cellTemplate: linkCellTemplate}
    ];

    $scope.getAdmins();
	}]);