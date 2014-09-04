'use strict'

angular.module 'webleagueApp'
.controller 'PanelCtrl', ($scope, Auth, Network) ->
  $scope.auth = Auth
  $scope.network = Network
  $scope.selected = 0
  $scope.chats = Network.chats
  $scope.showJoinDialog = ->
    bootbox.prompt "What is the chat name?", (cb)->
      return if !cb? || cb is ""
      Network.chat.invoke("joinorcreate", {Name: cb})
  $scope.leaveCurrentChat = (cb)->
    chat = $scope.chats[$scope.selected]
    return if !chat?
    if chat.Leavable
      Network.chat.invoke "leave", {Id: chat.Id}
    else
      bootbox.alert "You can't leave this chat."
  $scope.sendChat = (event)->
    msg = event.detail.message
    console.log "sending #{msg}"
    Network.chat.invoke("sendmessage", {Channel: service.chats[$scope.selected].Id, Text: msg})
  $scope.$watch 'chats', (newValue, oldValue)->
    $scope.selected = newValue.length-1 if $scope.selected > newValue.length
      
