'use strict'

angular.module 'webleagueApp'
.controller 'LeagueCtrl', ($scope, Network, $stateParams, $timeout, LeagueStore, safeApply) ->
  $scope.message = ""

  $scope.leagues = LeagueStore.leagues
  $scope.leagueid = $stateParams.id

  $scope.network = Network

  $scope.chat = (chats, leagueid)->
    _.findWhere _.values(chats), {Name: leagueid}

  $scope.chatMembers = (chat)->
    return [] if !chat?
    res = []
    for member in chat.Members
      res.push Network.members[member]
    res

  $scope.member = (sid)->
    Network.members[sid]

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
        msg = $scope.message
        chat = $scope.chat(Network.chats, $scope.leagueid)
        if chat?
          Network.chat.invoke "SendMessage", {Channel: chat.Id, Text: msg}
        else
          console.log "Can't find chat to send message to"
        $scope.message = ""
      , 10

  $scope.$watch "message", (newVal, oldVal)->
    match = /\r|\n/.exec(newVal)
    sendMessage() if match

  $scope.$on "$destroy", ->
    for bnd in jqbind
      bnd.unbind()
