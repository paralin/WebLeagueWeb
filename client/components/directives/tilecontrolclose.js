'use strict';

/**
 * @ngdoc directive
 * @name webleagueApp.directive:TileControlClose
 * @description
 * # TileControlClose
 */
angular.module('webleagueApp')
  .directive('tileControlClose', function () {
    return {
      restrict: 'A',
      link: function postLink(scope, element) {
        var tile = element.parents('.tile');

        element.on('click', function() {
          tile.addClass('closed').fadeOut();
        });
      }
    };
  });
