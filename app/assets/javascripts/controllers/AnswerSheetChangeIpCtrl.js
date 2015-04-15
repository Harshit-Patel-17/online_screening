angular.module('onlineScreening')
.controller('AnswerSheetChangeIpCtrl', [
	'$scope',
	'$http',
  '$modal',
	'Restangular',
	function($scope, $http, $modal, $rest){
		$scope.params = {};
		$scope.getAnswerSheets = function(){
      currentPage = $scope.pagingOptions.currentPage;
      pageSize = $scope.pagingOptions.pageSize;
			$scope.params.offset = (currentPage-1) * pageSize;
			$scope.params.limit = pageSize;
      $scope.params.exam_id = 26;
			$rest.all('answer_sheets/change_ip.json').get('', $scope.params)
			.then(function(data){
				$scope.answerSheets = data.answerSheets;
			},function(){
				alert("Error in fetching answer sheets.");
			});
		};

		$scope.$watch('pagingOptions', function(){
			 $scope.getAnswerSheets();
		}, true);

		$scope.pagingOptions = {
      pageSizes: [5, 50, 100],
      pageSize: 5,
      totalServerItems: 0,
      currentPage: 1
    }; 

		$scope.gridOptions = {
      data: 'answerSheets',
      columnDefs: 'columnDefs',
      enablePaging: true,
    	pagingOptions: $scope.pagingOptions,
    	showFooter: true,
      plugins: [new ngGridFlexibleHeightPlugin()]
 	 	};

    $scope.changeIP = function(answerSheetId){
      $scope.openDialog(answerSheetId);
    };

    $scope.openDialog = function(answerSheetId) {
      var modalInstance = $modal.open({
        templateUrl: 'change_ip.html',
        controller: 'changeIpCtrl'
      });

      modalInstance.result.then(function (ip) {
        var is_ip_valid = /^(25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)\.(25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)\.(25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)\.(25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)$/.test(ip);
        if(!is_ip_valid){
          alert("Invalid IP");
          $scope.openDialog(answerSheetId);
          return;
        }
        var params = {"start_test_ip": ip};
        $rest.one('answer_sheets', answerSheetId).one('change_ip.json').post('', params)
        .then(function(data){
          $scope.getAnswerSheets();
        }, function(){

        });
      }, function () {

      });
    };

    var change_ip_call = "changeIP(row.getProperty('id'))";
    var linkCellTemplate = '<a ng-click="'+ change_ip_call +'">Change IP</a>';

    $scope.columnDefs = [
    	{ field: 'id', displayName: 'Answer Sheet Id'},
      { field: 'college_id', displayName: 'College Id'},
    	{ field: 'first_name', displayName: 'First Name'},
    	{ field: 'email', displayName: 'Email'},
      { field: 'start_test_ip', displayName: 'IP'},
      { field: 'href', displayName: 'Links', enableCellEdit: false, cellTemplate: linkCellTemplate}
    ];
	}]);

angular.module('onlineScreening')
.controller('changeIpCtrl', [
  '$scope',
  '$modalInstance',
  function($scope,$modalInstance){
    $scope.ok = function () {
      $modalInstance.close($scope.ip);
    };

    $scope.cancel = function () {
      $modalInstance.dismiss('cancel');
    };
  }]);

