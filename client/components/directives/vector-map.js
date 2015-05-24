'use strict';

/**
 * @ngdoc directive
 * @name webleagueApp.directive:vectorMap
 * @description
 * # vectorMap
 */
angular.module('webleagueApp')
  .directive('vectorMap', function () {
    return {
      restrict: 'AE',
      scope: {
        options: '='
      },
      link: function postLink(scope, element) {
        var options = scope.options;
        element.vectorMap(options);
      }
    };
  });
