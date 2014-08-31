'use strict'

angular.module 'webleagueApp'
.controller 'PanelCtrl', ($scope, Auth, Network) ->
  $scope.auth = Auth
  $scope.network = Network
  $scope.selected = 0
  $scope.chats = Network.chats
  $scope.sendChat = (event)->
    msg = event.detail.message
    console.log "sending #{msg}"
    Network.chat.invoke("sendmessage", {Channel: service.chats[$scope.selected].Id, Text: msg})
