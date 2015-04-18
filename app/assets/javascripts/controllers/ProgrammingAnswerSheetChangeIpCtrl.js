angular.module('onlineScreening')
.controller('ProgrammingAnswerSheetChangeIpCtrl', [
	'$scope',
	'$http',
  '$modal',
	'Restangular',
	function($scope, $http, $modal, $rest){
		$scope.params = {};
    $scope.programming_exam = {};
		$scope.getProgrammingAnswerSheets = function(){
      currentPage = $scope.pagingOptions.currentPage;
      pageSize = $scope.pagingOptions.pageSize;
			$scope.params.offset = (currentPage-1) * pageSize;
			$scope.params.limit = pageSize;
      $scope.params.programming_exam_id = $scope.programming_exam.id;
			$rest.all('programming_answer_sheets/change_ip.json').get('', $scope.params)
			.then(function(data){
				$scope.programmingAnswerSheets = data.programmingAnswerSheets;
			},function(){
				alert("Error in fetching programming answer sheets.");
			});
		};

    $scope.getProgrammingExams = function(){
      $rest.all('programming_exams.json').get('')
      .then(function(data){
        $scope.programming_exams = data.programming_exams;
      },function(){
        alert("Error in fetching programming_exams.");
      });
    };

		$scope.$watch('pagingOptions', function(){
			 $scope.getProgrammingAnswerSheets();
		}, true);

		$scope.pagingOptions = {
      pageSizes: [5, 50, 100],
      pageSize: 5,
      totalServerItems: 0,
      currentPage: 1
    }; 

		$scope.gridOptions = {
      data: 'programmingAnswerSheets',
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
        $rest.one('programming_answer_sheets', answerSheetId).one('change_ip.json').post('', params)
        .then(function(data){
          $scope.getProgrammingAnswerSheets();
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

    $scope.getProgrammingExams();
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

