angular.module('onlineScreening')
.controller('ProgrammingExamMyExamsCtrl', [
	'$scope',
	'$http',
	'$timeout',
	'Restangular',
	function($scope, $http, $timeout, $rest){
		$scope.getMyExams = function(){
			$rest.all('programming_exams/my_exams.json').get('')
			.then(function(data){
				$scope.myExams = data.myExams;
				$scope.currentServerTime = data.currentServerTime;
				$scope.initTimers();
			},function(){
				alert("Error in fetching exams.");
			});
		};
		
		$scope.startTime = {};
		$scope.endTime = {};
		$scope.remainingTimeToStart = {};
		$scope.remainingSecsToStart = {};
		$scope.remainingSecsToEnd = {};
		$scope.windowOver = {};
		$scope.initTimers = function(){
			var date;
			var time;
			for(i = 0; i < $scope.myExams.length; i++){
				key = $scope.myExams[i].id;
				$scope.startTime[key] = Date.parse($scope.myExams[i].start_window_time);
				$scope.endTime[key] = Date.parse($scope.myExams[i].end_window_time);
				$scope.remainingSecsToStart[key] = parseInt(($scope.startTime[key] - Date.parse($scope.currentServerTime))/1000);
				$scope.remainingSecsToEnd[key] = parseInt(($scope.endTime[key] - Date.parse($scope.currentServerTime))/1000);
			}	
			$timeout($scope.refreshTime, 1000);
		};

		$scope.secondsToHMS = function(d){
			d = Number(d);
			var days = Math.floor(d / 24 / 3600)
			var h = Math.floor(d % (24 * 3600) / 3600);
			var m = Math.floor(d % 3600 / 60);
			var s = Math.floor(d % 3600 % 60);
			return ((days > 0 ? days : '00') + 'd ' + (h > 0 ? h : '00') + 'h ' + (m > 0 ? m : '00') + 'm ' + (s > 0 ? s : '00') + 's');
		}

		$scope.refreshTime = function(){
			for(i = 0; i < $scope.myExams.length; i++){
				key = $scope.myExams[i].id;
				$scope.remainingSecsToStart[key]--;
				$scope.remainingSecsToEnd[key]--;
				$scope.remainingTimeToStart[key] = $scope.secondsToHMS($scope.remainingSecsToStart[key]);
				$scope.windowOver[key] = $scope.remainingSecsToEnd[key] <= 0;
			}
			$timeout($scope.refreshTime, 1000);
		};

		$scope.startExam = function(programming_exam_id){
			params = {"programming_answer_sheet": {"programming_exam_id": programming_exam_id}};
			$rest.all('programming_answer_sheets.json').post(params)
			.then(function(data){
				if(data.id)
					window.location.href = "/programming_answer_sheets/" + data.id;
				else{
					alert(data.reply);
				}
			}, function(){
				alert("Start programming exam request failed.");
			});
		};

		$scope.gridOptions = {
	      data: 'myExams',
	      columnDefs: 'columnDefs',
	      showFooter: true,
	      plugins: [new ngGridFlexibleHeightPlugin()]
   	 	};

	    var start_exam_call = "startExam(row.getProperty('id'))";
	    var linkCellTemplate = '<a ng-show="remainingSecsToStart[' + "row.getProperty('id')" + '] <= 0 && !windowOver[' + "row.getProperty('id')" + ']" ng-click="'+ start_exam_call +'">start</a>'
	    						+ '<span ng-show="windowOver[' + "row.getProperty('id')" + ']">Window over</span>';
	    var timerCellTemplate = '<span>{{remainingTimeToStart[' + 'row.getProperty("id")' + ']}}</span>';

	    $scope.columnDefs = [
	    	{ field: 'id', displayName: 'Id'},
	    	{ field: 'exam_name', displayName: 'Exam Name'},
	    	{ field: 'duration_mins', displayName: 'Duration (mins)'},
	    	{ field: 'start_window_time', displayName: 'SWT', cellFilter: 'date:\'dd-MMM-yyyy, hh:mm a\''},
	    	{ field: 'end_window_time', displayName: 'EWT', cellFilter: 'date:\'dd-MMM-yyyy, hh:mm a\''},
	    	{ field: 'timer', displayName: 'Starts in', cellTemplate: timerCellTemplate},
	    	{ field: 'href', displayName: 'Links', cellTemplate: linkCellTemplate}
	    ];

	    $scope.getMyExams();
	}]);