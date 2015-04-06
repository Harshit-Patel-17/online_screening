angular.module('onlineScreening')
.controller('ExamMyExamsCtrl', [
	'$scope',
	'$http',
	'$timeout',
	'Restangular',
	function($scope, $http, $timeout, $rest){
		$scope.getMyExams = function(){
			$rest.all('my_exams.json').get('')
			.then(function(data){
				$scope.myExams = data.myExams;
				$scope.initStartTime();
			},function(){
				alert("Error in fetching exams.");
			});
		};
		
		$scope.startTime = {};
		$scope.endTime = {};
		$scope.remainingTime = {};
		$scope.remainingSecs = {};
		$scope.windowOver = {};
		$scope.initStartTime = function(){
			var date;
			var time;
			for(i = 0; i < $scope.myExams.length; i++){
				$scope.startTime[$scope.myExams[i].id] = Date.parse($scope.myExams[i].start_window_time);
				$scope.endTime[$scope.myExams[i].id] = Date.parse($scope.myExams[i].end_window_time);
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
				$scope.remainingSecs[key] = $scope.startTime[key] - Date.now();
				$scope.remainingTime[key] = new Date();
				$scope.remainingTime[key] = $scope.secondsToHMS($scope.remainingSecs[key]/1000);
				$scope.windowOver[key] = $scope.endTime[key] - Date.now() < 0;
			}
			$timeout($scope.refreshTime, 1000);
		};

		$scope.startExam = function(exam_id){
			params = {"answer_sheet": {"exam_id": exam_id}};
			$rest.all('answer_sheets.json').post(params)
			.then(function(data){
				window.location.href = "/answer_sheets/" + data.id;
			}, function(){
				alert("Start exam request failed.");
			});
		};

		$scope.gridOptions = {
	      data: 'myExams',
	      columnDefs: 'columnDefs',
	      showFooter: true,
	      plugins: [new ngGridFlexibleHeightPlugin()]
   	 	};

	    var start_exam_call = "startExam(row.getProperty('id'))";
	    var linkCellTemplate = '<a ng-show="remainingSecs[' + "row.getProperty('id')" + '] <= 0 && !windowOver[' + "row.getProperty('id')" + ']" ng-click="'+ start_exam_call +'">start</a>'
	    						+ '<span ng-show="windowOver[' + "row.getProperty('id')" + ']">Window over</span>';
	    var timerCellTemplate = '<span>{{remainingTime[' + 'row.getProperty("id")' + ']}}</span>';

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