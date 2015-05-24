'use strict'

angular.module 'webleagueApp'
.controller 'LeagueCtrl', ($scope, Network, $rootScope, $stateParams, $http, safeApply, $timeout) ->
  $scope.message = ""
  $scope.page =
    title: 'League',
    subtitle: 'A league'

  adjustInputLocation = ->
    th = $(".chatBox").width()
    $(".newMessage").css("width", "#{th-30}px")

  jqbind = []
  $scope.$on "$viewContentLoaded", ->
    jqbind.push $(window).resize ->
      adjustInputLocation()

    jqbind.push $(".chatInput").keypress (e)->
      if e.which is 13
        sendMessage()
        return false

    adjustInputLocation()

  sendMessage = ->
    safeApply $scope, ->
      $timeout ->
        return if $scope.message.length is 0
        $scope.message = ""
      , 10

  $scope.$watch "message", (newVal, oldVal)->
    match = /\r|\n/.exec(newVal)
    sendMessage() if match

  $scope.$on "$destroy", ->
    for bnd in jqbind
      bnd.unbind()
