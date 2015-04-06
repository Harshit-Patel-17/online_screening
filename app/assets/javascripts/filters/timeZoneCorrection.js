angular.module('onlineScreening')
.filter('timeZoneCorrection', function() {
  return function(input) {
    tz_offset = (new Date()).getTimezoneOffset() * 60 * 1000;
    input = Date.parse(input) + tz_offset;
    input = new Date(input);
    return input.toLocaleString();
  };
});