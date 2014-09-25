'use strict'

PNotify.desktop.permission()
angular.module 'webleagueApp'
.controller 'PanelCtrl', ($rootScope, $scope, Auth, Network) ->
  clr = []
  $scope.auth = Auth
  $scope.network = Network
  $scope.selected = 0
  $scope.chats = Network.chats
  $scope.liveMatches = Network.liveMatches
  $scope.games = Network.availableGames
  $scope.chatMembers = []
  updChatMembers = (members)->
    arr = $scope.chatMembers
    nMembers = _.keys members
    for mem in nMembers
      arr[arr.length] = mem if !_.contains(arr, mem)
    i=0
    for mem in arr
      arr.splice i, 1 if !_.contains(nMembers, mem)
      i+=1
  clr.push $scope.$watch "selected", (selected)->
    chat = $scope.chats[selected]
    if !chat?
      $scope.chatMembers.length = 0
    else
      updChatMembers chat.Members
  clr.push $rootScope.$on "chatMembersUpd", ->
    chat = $scope.chats[$scope.selected]
    if !chat?
      $scope.chatMembers.length = 0
    else
      updChatMembers chat.Members
  $scope.getMembersArr = (chat)->
    return [] if !chat?
    arr = $scope.chatMemberArrs[chat.Id]
    if !arr?
      arr = $scope.chatMemberArrs[chat.Id] = _.keys chat.Members
    else
    return arr
  $scope.confirmCreateMatch = ->
    nameInput = $("#matchNameInput")[0]
    name = nameInput.inputValue
    if name is ""
      $("paper-dialog")[0].opened = true
      new PNotify
        title: "Name Needed"
        text: "Please enter a match name."
        type: "error"
      return
    drp = $("#gameModeInput")[0]
    sel = drp.selectedItem
    if !sel?
      $("paper-dialog")[0].opened = true
      new PNotify
        title: "Game Mode Needed"
        text: "Please select a game mode."
        type: "error"
      return
    gm = parseInt $(drp.selectedItem).attr "value"
    console.log "Selected: #{$rootScope.GameModeN[gm]}"
    console.log "Mode ID is #{gm}"
    Network.matches.do.creatematch
      MatchType: 0
      Name: name
      GameMode: gm
    
  $scope.dismissCreate = ->
    $("paper-dialog")[0].opened = false
  # Is currently controlling a game
  $scope.createStartgame = ->
    $("paper-dialog")[0].toggle()
    $("#matchNameInput")[0].inputValue = ""
  $scope.showRightCont = ->
    Network.liveMatches.length>0||$scope.games.length>0||$scope.canStartGames()||$scope.isAdminOfGame()
  $scope.isAdminOfGame = ->
    return false if !Auth.currentUser? or !Network.activeMatch?
    Network.activeMatch.Info.Owner is Auth.currentUser.steam.steamid
  $scope.canStartGames = ->
    if Auth.currentUser? && !Network.activeMatch?
      _.contains Auth.currentUser.authItems, 'startGames'
    else
      false
  $scope.showJoinDialog = ->
    bootbox.prompt "What is the chat name?", (cb)->
      return if !cb? || cb is ""
      Network.chat.invoke("joinorcreate", {Name: cb}).then (err)->
        if err?
          new PNotify
            title: "Join Error"
            text: err
            type: "error"
            desktop:
              desktop: true
          return
    return
  $scope.leaveCurrentChat = (cb)->
    chat = $scope.chats[$scope.selected]
    return if !chat?
    if chat.Leavable
      Network.chat.invoke "leave", {Id: chat.Id}
    else
      bootbox.alert "You can't leave this chat."
  $scope.isInGame = (game)->
    if !game?
      return Network.activeMatch?
    return false if !Auth.currentUser? or !Network.activeMatch?
    (_.findIndex game.Players, {SID: Auth.currentUser.steam.steamid}) != -1
  $scope.gameList = ->
    return [Network.activeMatch] if Network.activeMatch?
    return $scope.games
  $scope.joinGame = (game)->
    Network.matches.do.joinmatch
      Id: game.Id
  $scope.sendChat = (event)->
    msg = event.detail.message
    console.log "sending #{msg}"
    Network.chat.invoke("sendmessage", {Channel: service.chats[$scope.selected].Id, Text: msg})
  $scope.$on 'destroy', ->
    for cl in clr
      cl()
    clr.length = 0
