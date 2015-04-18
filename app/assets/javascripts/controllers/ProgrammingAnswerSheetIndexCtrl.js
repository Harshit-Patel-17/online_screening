angular.module('onlineScreening')
.controller('ProgrammingAnswerSheetIndexCtrl', [
	'$scope',
	'$http',
	'Restangular',
	function($scope, $http, $rest){
		$scope.getProgrammingAnswerSheets = function(){
			params = {"programming_exam_id": $scope.programming_exam.id, "cut_off": $scope.cut_off}
			$rest.all('programming_answer_sheets.json').get('', params)
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
				alert("Error in fetching programming exams.");
			});
		};

		$scope.gridOptions = {
	      data: 'programmingAnswerSheets',
	      columnDefs: 'columnDefs',
	      showFooter: true,
	      plugins: [new ngGridFlexibleHeightPlugin()]
   	 	};

   	 	$scope.deleteProgrammingAnswerSheet = function(id){
   	 		if(!confirm("Are you sure about deleting the programming answer sheet?"))
        		return
   	 		$rest.one('programming_answer_sheets', id).remove()
   	 		.then(function(data){
   	 			$scope.message = data.reply;
   	 			$scope.getProgrammingAnswerSheets();
   	 		}, function(){
   	 			alert('Delete request failed.')
   	 		});
   	 	};

	    var show_path = "{{'/programming_answer_sheets/'+row.getProperty('id') + '/review'}}";
	    var delete_call = "deleteProgrammingAnswerSheet(row.getProperty('id'))";
	    var linkCellTemplate = '<a data-method="get" href="'+ show_path +'"><i class="glyphicon glyphicon-eye-open"></i></a>'
	    						+ ' <a ng-click="' + delete_call + '"><i class="glyphicon glyphicon-remove"></i></a>';

	    $scope.columnDefs = [
	    	{ field: 'id', displayName: 'Id'},
	    	{ field: 'user_name', displayName: 'Candidate'},
	    	{ field: 'score', displayName: 'Score'},
	    	{ field: 'href', displayName: 'Links', cellTemplate: linkCellTemplate}
	    ];

	    $scope.getProgrammingExams();
	}]);