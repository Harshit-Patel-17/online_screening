angular.module('onlineScreening')
.controller('QuestionIndexCtrl', [
	'$scope',
	'$http',
	'Restangular',
	function($scope, $http, $rest){
		$scope.getPagedQuestions = function(currentPage, pageSize){
			offset = (currentPage-1) * pageSize;
			limit = pageSize;
			params = {'offset': offset, 'limit': limit};
			$rest.all('questions.json').get('', params)
			.then(function(data){
				$scope.questions = data.questions;
			},function(){
				alert("Error in fetching questions.");
			});
		};

		$scope.$watch('pagingOptions', function(){
			$scope.getPagedQuestions($scope.pagingOptions.currentPage, $scope.pagingOptions.pageSize);
		}, true);

		$scope.pagingOptions = {
      pageSizes: [10, 50, 100],
      pageSize: 10,
      totalServerItems: 0,
      currentPage: 1
    }; 

		$scope.gridOptions = {
      data: 'questions',
      columnDefs: 'columnDefs',
      enablePaging: true,
      pagingOptions: $scope.pagingOptions,
      showFooter: true,
      plugins: [new ngGridFlexibleHeightPlugin()]
    };

    var edit_path = "{{'/questions/'+row.getProperty('id')+'/edit'}}";
    var show_path = "{{'/questions/'+row.getProperty('id')}}";
    var linkCellTemplate = '<a href="'+ edit_path +'"><i class="glyphicon glyphicon-cog"></i></a>'
   							+ ' <a href="'+ show_path +'"><i class="glyphicon glyphicon-eye-open"></i></a>';
    
    $scope.columnDefs = [
    	{ field: 'id', displayName: 'Id', width: "10%"},
    	{ field: 'weightage', displayName: 'Weightage', width: "10%"},
    	{ field: 'question', displayName: 'Question Text', width: "70%"	},
    	{ field: 'href', displayName: 'Links', enableCellEdit: false, cellTemplate: linkCellTemplate}
    ];
	}]);