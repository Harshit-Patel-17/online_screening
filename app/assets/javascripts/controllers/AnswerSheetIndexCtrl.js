angular.module('onlineScreening')
.controller('AnswerSheetIndexCtrl', [
	'$scope',
	'$http',
	'Restangular',
	function($scope, $http, $rest){
		$scope.getAnswerSheets = function(){
			params = {"exam_id": $scope.exam.id, "cut_off": $scope.cut_off}
			$rest.all('answer_sheets.json').get('', params)
			.then(function(data){
				$scope.answerSheets = data.answerSheets;
			},function(){
				alert("Error in fetching answer sheets.");
			});
		};
		
		$scope.getExams = function(){
			$rest.all('exams.json').get('')
			.then(function(data){
				$scope.exams = data.exams;
			},function(){
				alert("Error in fetching exams.");
			});
		};

		$scope.gridOptions = {
	      data: 'answerSheets',
	      columnDefs: 'columnDefs',
	      showFooter: true,
	      plugins: [new ngGridFlexibleHeightPlugin()]
   	 	};

   	 	$scope.deleteAnswerSheet = function(id){
   	 		if(!confirm("Are you sure about deleting the answer sheet?"))
        		return
   	 		$rest.one('answer_sheets', id).remove()
   	 		.then(function(data){
   	 			$scope.message = data.reply;
   	 			$scope.getAnswerSheets();
   	 		}, function(){
   	 			alert('Delete request failed.')
   	 		});
   	 	};

	    var show_path = "{{'/answer_sheets/'+row.getProperty('id')}}";
	    var delete_call = "deleteAnswerSheet(row.getProperty('id'))";
	    var linkCellTemplate = '<a data-method="get" href="'+ show_path +'"><i class="glyphicon glyphicon-eye-open"></i></a>'
	    						+ ' <a ng-click="' + delete_call + '"><i class="glyphicon glyphicon-remove"></i></a>';

	    $scope.columnDefs = [
	    	{ field: 'id', displayName: 'Id'},
	    	{ field: 'user_name', displayName: 'Candidate'},
	    	{ field: 'score', displayName: 'Score'},
	    	{ field: 'href', displayName: 'Links', cellTemplate: linkCellTemplate}
	    ];

	    $scope.getExams();
	}]);