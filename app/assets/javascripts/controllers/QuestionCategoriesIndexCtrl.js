angular.module('onlineScreening')
.controller('QuestionCategoriesIndexCtrl', [
	'$scope',
	'$http',
	'Restangular',
	function($scope, $http, $rest){
		$scope.getQuestionCategories = function(){
			$rest.all('question_categories.json').get('')
			.then(function(data){
				$scope.questionCategories = data.questionCategories;
			},function(){
				alert("Error in fetching question_categories.");
			});
		};
		

		$scope.gridOptions = {
	      data: 'questionCategories',
	      columnDefs: 'columnDefs',
	      showFooter: true,
	      plugins: [new ngGridFlexibleHeightPlugin()]
   	 	};

   	 	$scope.deleteQuestioncategory = function(id){
   	 		if(!confirm("Are you sure about deleting the category?"))
        		return
   	 		$rest.one('question_categories', id).remove()
   	 		.then(function(data){
   	 			$scope.message = data.reply;
   	 			$scope.getQuestionCategories();
   	 		}, function(){
   	 			alert('Delete request failed.')
   	 		});
   	 	};

	    var edit_path = "{{'/question_categories/'+row.getProperty('id')+'/edit'}}";
	    var show_path = "{{'/question_categories/'+row.getProperty('id')}}";
	    var delete_call = "deleteQuestioncategory(row.getProperty('id'))";
	    var linkCellTemplate = '<a data-method="get" href="'+ edit_path +'"><i class="glyphicon glyphicon-cog"></i></a>'
	    						+ ' <a data-method="get" href="'+ show_path +'"><i class="glyphicon glyphicon-eye-open"></i></a>'
	    						+ ' <a ng-click="' + delete_call + '"><i class="glyphicon glyphicon-remove"></i></a>';

	    $scope.columnDefs = [
	    	{ field: 'id', displayName: 'Id'},
	    	{ field: 'category_name', displayName: 'Category Name'},
	    	{ field: 'href', displayName: 'Links', cellTemplate: linkCellTemplate}
	    ];

	    $scope.getQuestionCategories();
	}]);