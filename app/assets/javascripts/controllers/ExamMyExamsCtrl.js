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
		$scope.remainingTime = {};
		$scope.initStartTime = function(){
			var date;
			var time;
			for(i = 0; i < $scope.myExams.length; i++){
				date = new Date($scope.myExams[i].date);
				time = new Date($scope.myExams[i].start_window_time);

				year = date.getFullYear();
				month = date.getMonth();
				day = date.getDate();
				hours = time.getHours();
				minutes = time.getMinutes();
				$scope.startTime[$scope.myExams[i].id] = new Date(year, month, day, hours, minutes);
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
				seconds = $scope.startTime[key] - Date.now();
				$scope.remainingTime[key] = new Date();
				$scope.remainingTime[key] = $scope.secondsToHMS(seconds/1000);
			}
			$timeout($scope.refreshTime, 1000);
		};

		$scope.gridOptions = {
	      data: 'myExams',
	      columnDefs: 'columnDefs',
	      showFooter: true,
	      plugins: [new ngGridFlexibleHeightPlugin()]
   	 	};

	    var edit_path = "{{'/exams/'+row.getProperty('id')+'/edit'}}";
	    var linkCellTemplate = '<a data-method="get" href="'+ edit_path +'"><i class="glyphicon glyphicon-cog"></i></a>';
	    var timerCellTemplate = '<span>{{remainingTime[' + 'row.getProperty("id")' + ']}}</span>';

	    $scope.columnDefs = [
	    	{ field: 'id', displayName: 'Id'},
	    	{ field: 'exam_name', displayName: 'Exam Name'},
	    	{ field: 'college_name', displayName: 'College Name'},
	    	{ field: 'date', displayName: 'Date'},
	    	{ field: 'duration_mins', displayName: 'Duration (mins)'},
	    	{ field: 'start_window_time', displayName: 'SWT', cellFilter: 'date:\'hh:mm a\''},
	    	{ field: 'end_window_time', displayName: 'EWT', cellFilter: 'date:\'hh:mm a\''},
	    	{ field: 'status', displayName: 'Status'},
	    	{ field: 'timer', displayName: 'Starts in', cellTemplate: timerCellTemplate},
	    	{ field: 'href', displayName: 'Links', cellTemplate: linkCellTemplate}
	    ];

	    $scope.getMyExams();
	}]);