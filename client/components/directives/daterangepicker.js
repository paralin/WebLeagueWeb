'use strict';

/**
 * @ngdoc directive
 * @name webleagueApp.directive:daterangepicker
 * @description
 * # daterangepicker
 */
angular.module('webleagueApp')
  .directive('daterangepicker', function() {
    return {
      restrict: 'A',
      scope: {
        options: '=daterangepicker',
        start: '=dateBegin',
        end: '=dateEnd'
      },
      link: function(scope, element) {
        element.daterangepicker(scope.options, function(start, end) {
          scope.start = start.format('MMMM D, YYYY');
          scope.end = end.format('MMMM D, YYYY');
          scope.$apply();
        });
      }
    };
  });

