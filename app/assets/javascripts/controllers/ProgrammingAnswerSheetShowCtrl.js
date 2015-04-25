angular.module('onlineScreening')
.controller('ProgrammingAnswerSheetShowCtrl', [
	'$scope',
	'$http',
	'$timeout',
	'$modal',
	'Restangular',
	function($scope, $http, $timeout, $modal, $rest){
		$scope.timer = {};
		$scope.programmingTask = {};
		$scope.language = "c++";
		$scope.message = "No activity";

		$scope.codeOption = {
		    lineNumbers: true,
		    indentWithTabs: true,
		    mode: "text/x-c++src",
		    
		};

		$scope.compilationLogOption = {
		    lineNumbers: true,
		    indentWithTabs: true,
		    lineWrapping: true,
		    readOnly: "nocursor",
		    viewportMargin: Infinity,
		    onLoad: function(_editor){
		    	_editor.setSize(null, "50%");
		    }
		};

		$scope.ioOption = {
		    lineNumbers: true,
		    indentWithTabs: true,
		    readOnly: "nocursor",
		    viewportMargin: Infinity,
		    onLoad: function(_editor){
		    	_editor.setSize(null, "50%");
		    }
		};

		$scope.countDown = function(){
			$scope.timer.total_secs--;
			$scope.timer.mins = Math.floor($scope.timer.total_secs/60);
			$scope.timer.secs = $scope.timer.total_secs % 60
			if($scope.timer.total_secs > 0)
				$timeout($scope.countDown, 1000);
			else
				window.location.href = "/programming_answer_sheets/time_up"
		};

		$scope.initTimer = function(){
			current_time = new Date($scope.programmingAnswerSheet.currentServerTime);
			end_time = new Date($scope.programmingAnswerSheet.end_time);
			$scope.timer.total_secs = Math.floor((end_time - current_time)/1000);
			$scope.timer.mins = Math.floor($scope.timer.total_secs/60);
			$scope.timer.secs = $scope.timer.total_secs % 60
			$scope.countDown();
		};

		$scope.init = function(id){
			$rest.setRequestSuffix('.json');
			$rest.one('programming_answer_sheets', id).get()
			.then(function(data){
				$scope.programmingAnswerSheet = data.programmingAnswerSheet;
				$scope.changeProgram($scope.programmingAnswerSheet.programming_tasks[0]);
				$scope.initTimer();
			}, function(){
				alert("Get answer-sheet request failed.");
			});
			$rest.setRequestSuffix('');
		};

		$scope.changeProgram = function(programming_task_id){
			$rest.setRequestSuffix('.json');
			$rest.one('programming_tasks', programming_task_id).get('')
			.then(function(data){
				$scope.programmingTask = data.programmingTask;
			}, function(){
				alert("Get programming task request failed.");
			});

			var params = {"programming_task_id": programming_task_id, "language": $scope.language};
			$rest.one('programming_answer_sheets', $scope.programmingAnswerSheet.id).one('get_program').get(params)
			.then(function(data){
				$scope.programText = data.programText;
			}, function(){
				alert("Get program text request failed");
			});
		};

		$scope.saveProgram = function(){
			var params = {"programming_task_id": $scope.programmingTask.id, "program_text": $scope.programText, "language": $scope.language};
			$scope.message = "Saving...";
			$rest.setRequestSuffix('.json');
			$rest.one('programming_answer_sheets', $scope.programmingAnswerSheet.id).one('save_program').post('', params)
			.then(function(data){
				$scope.message = "Saved";
			}, function(){
				$scope.message = "Save failed!";
			});
		};

		$scope.checkCppProgram = function(){
			$scope.message = "Submitting...";
			var params = {"programming_task_id": $scope.programmingTask.id, "language": $scope.language};
			$rest.setRequestSuffix('.json');
			$rest.one('programming_answer_sheets', $scope.programmingAnswerSheet.id).one('check_program').post('', params)
			.then(function(data){
				$scope.compilationLog = data.compilation_log;
				$scope.message = "Successfully submitted"
			}, function(){
				$scope.message = "Submit failed!"
			});
		};

		$scope.checkJavaProgram = function(){
			var modalInstance = $modal.open({
	        	templateUrl: 'submit_java_program.html',
	        	controller: 'modalCtrl'
	      	});

	      	modalInstance.result.then(function(input) {
	        	$scope.message = "Submitting...";
				var params = {"programming_task_id": $scope.programmingTask.id, "input": input, "language": $scope.language};
				$rest.setRequestSuffix('.json');
				$rest.one('programming_answer_sheets', $scope.programmingAnswerSheet.id).one('check_program').post('', params)
				.then(function(data){
					$scope.compilationLog = data.compilation_log;
					$scope.message = "Successfully submitted"
				}, function(){
					$scope.message = "Submit failed!"
				});
	      	}, function () {

	      	});
		};

		$scope.checkProgram = function(){
			$scope.saveProgram();
			if($scope.language == "c++")
				$scope.checkCppProgram();
			else if($scope.language == "java")
				$scope.checkJavaProgram();
		};

		$scope.getInput = function() {
			$scope.saveProgram();
			var modalInstance;
			if($scope.language == "c++")
		    	modalInstance = $modal.open({
		        	templateUrl: 'get_cpp_input.html',
		        	controller: 'modalCtrl'
		      	});
		    else if($scope.language == "java")
		    	modalInstance = $modal.open({
		        	templateUrl: 'get_java_input.html',
		        	controller: 'modalCtrl'
		      	});

	      	modalInstance.result.then(function(input) {
	        	$scope.message = "Executing...";
	        	var params = {"programming_task_id": $scope.programmingTask.id, "input": input, "language": $scope.language};
	        	$rest.setRequestSuffix('.json');
				$rest.one('programming_answer_sheets', $scope.programmingAnswerSheet.id).one('run_program').post('', params)
				.then(function(data){
					$scope.stdin = data.stdin;
					$scope.stdout = data.stdout;
					$scope.stderr = data.stderr;
					$scope.compilationLog = data.compilation_log;
					$scope.message = "Execution complete";
				}, function(){
					$scope.message = "Execution failed"
				});
	      	}, function () {

	      	});
	    };

		$scope.changeLanguage = function(lang){
			$scope.language = lang;
			if($scope.language == "c++")
				$scope.codeOption.mode = "text/x-c++src";
			else if($scope.language == "java")
				$scope.codeOption.mode = "text/x-java";
			var params = {"programming_task_id": $scope.programmingTask.id, "language": $scope.language};
			$rest.one('programming_answer_sheets', $scope.programmingAnswerSheet.id).one('get_program').get(params)
			.then(function(data){
				$scope.programText = data.programText;
			}, function(){
				alert("Get program text request failed");
			});
		};

	}]);

angular.module('onlineScreening')
.controller('modalCtrl', [
  	'$scope',
  	'$modalInstance',
  	function($scope,$modalInstance){
  		$scope.input = {};
  		$scope.ok = function () {
     		$modalInstance.close($scope.input);
    	};

	    $scope.cancel = function () {
	      	$modalInstance.dismiss('cancel');
	    };
  }]);