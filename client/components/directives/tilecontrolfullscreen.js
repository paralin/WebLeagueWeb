'use strict';

/**
 * @ngdoc directive
 * @name webleagueApp.directive:tileControlFullscreen
 * @description
 * # tileControlFullscreen
 */
angular.module('webleagueApp')
  .directive('tileControlFullscreen', function () {
    return {
      restrict: 'A',
      link: function postLink(scope, element) {
        var dropdown = element.parents('.dropdown');

        element.on('click', function(){
          dropdown.trigger('click');
        });

      }
    };
  });
