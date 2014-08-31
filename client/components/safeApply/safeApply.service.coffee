'use strict'

angular.module('webleagueApp').factory 'safeApply', ->
  ($scope, fn)->
    phase = $scope.$root.$$phase
    if phase is "$apply" or phase is "$digest"
      $scope.$eval fn  if fn
    else
      if fn
        $scope.$apply fn
      else
        $scope.$apply()
    return
