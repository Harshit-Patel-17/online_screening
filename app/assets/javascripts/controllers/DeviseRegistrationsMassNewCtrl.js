angular.module('onlineScreening')
.controller('DeviseRegistrationsMassNewCtrl', [
	'$scope',
	'$http',
	'Restangular',
	function($scope, $http, $rest){
		$scope.registeredUsersGridOptions = {
	      data: 'usersRegistered',
	      columnDefs: 'registeredUserscolumnDefs',
	      plugins: [new ngGridFlexibleHeightPlugin()]
   	 	};

   	 	$scope.unregisteredUsersGridOptions = {
	      data: 'usersNotRegistered',
	      columnDefs: 'unregisteredUserscolumnDefs',
	      plugins: [new ngGridFlexibleHeightPlugin()]
   	 	};

	    $scope.registeredUserscolumnDefs = [
	    	{ field: 'student_id', displayName: 'Student Id'},
	    	{ field: 'first_name', displayName: 'First Name'},
	    	{ field: 'last_name', displayName: 'Last Name'},
	    	{ field: 'email', displayName: 'Email'},
	    	{ field: 'password', displayName: 'Password'},
	    	{ field: 'college_id', displayName: 'College Id'}
	    ];

	    $scope.unregisteredUserscolumnDefs = [
	    	{ field: 'student_id', displayName: 'Student Id'},
	    	{ field: 'first_name', displayName: 'First Name'},
	    	{ field: 'last_name', displayName: 'Last Name'},
	    	{ field: 'email', displayName: 'Email'},
	    	{ field: 'reason', displayName: 'Reason of Failure'},
	    	{ field: 'college_id', displayName: 'College Id'}
	    ];

	    $scope.uploadSheet = function(){
	    	var formData = new FormData();
	    	formData.append('users', $scope.users);

	    	$rest.all('users/mass_create')
	    	.withHttpConfig({transformRequest: angular.identity}).
	    	customPOST(formData, '', undefined, {'Content-Type': undefined})
	    	.then(function(data){
	    		$scope.usersRegistered = data.usersRegistered;
	    		$scope.usersNotRegistered = data.usersNotRegistered;
	    		$scope.showResults = true;
	    	}, function(){
	    		alert("Mass user creation request failed.");
	    	});
	    };
	}]);