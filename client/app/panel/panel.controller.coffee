'use strict'

foundSound = new buzz.sound "/assets/sounds/match_ready.wav"
challengeSound = new buzz.sound "/assets/sounds/ganked_sml_01.mp3"
uiButtonSound = new buzz.sound "/assets/sounds/ui_button_click_01.wav"
findMatchSound = new buzz.sound "/assets/sounds/ui_findmatch_join_01.wav"
window.quitMatchSound = new buzz.sound "/assets/sounds/ui_findmatch_quit_01.wav"
window.lobbyReadySound = new buzz.sound "/assets/sounds/ui_findmatch_search_01.wav"

PNotify.desktop.permission()
angular.module 'webleagueApp'
.controller 'PanelCtrl', ($rootScope, $scope, Auth, Network, safeApply, $state, $translate) ->
  clr = []
  $scope.auth = Auth
  $scope.network = Network
  window.state = $scope.state = state = $state
  $scope.chats = Network.chats
  $scope.liveMatches = Network.liveMatches
  $scope.games = Network.availableGames
  $scope.setLanguage = (ln)->
    $translate.use ln
  $scope.notMe = (member)->
    member.SteamID isnt Auth.currentUser.steam.steamid
  $scope.pickPlayer = (event)->
    Network.matches.do.pickPlayer event.detail.SID
    uiButtonSound.play()
  $scope.selectChat = (name)->
    $state.go("panel.chat", {name: name})
  clr.push $rootScope.$on "chatChannelAdd", ->
    $scope.selectChat Network.chats[Network.chats.length-1].Name
  clr.push $rootScope.$on "challengeSnapshot", ->
    challenge = Network.activeChallenge
    if challenge?
      if challenge.ChallengedSID is Auth.currentUser.steam.steamid
        challengeSound.play()
        window.aswal = swal(
          title: "Incoming challenge"
          text: "You have an incoming challenge from #{challenge.ChallengerName}!"
          type: "success"
          showCancelButton: true
          confirmButtonColor: "#A5DC86"
          confirmButtonText: "Accept"
          cancelButtonText: "Decline"
          cancelButtonColor: "#DD6B55"
        , ->
          safeApply $scope, ->
            Network.matches.do.respondchallenge true
            uiButtonSound.play()
        , ->
          safeApply $scope, ->
            Network.matches.do.respondchallenge false
            uiButtonSound.play()
        )
    else if window.aswal?
      window.aswal()
      window.aswal = null
  $scope.sortedGameModes = ->
    _.keys($rootScope.GameModeN).map(Number)
  $scope.confirmCreateMatch = ->
    console.log $scope.matchName
    name = $scope.matchName
    if name is ""
      $scope.showCreateMatch = true
      new PNotify
        title: "Name Needed"
        text: "Please enter a match name."
        type: "error"
      return
    sel = $scope.selectedGameMode
    if !sel?
      $scope.showCreateMatch = true
      new PNotify
        title: "Game Mode Needed"
        text: "Please select a game mode."
        type: "error"
      return
    gm = parseInt sel
    sorted = _.sortBy(_.keys($rootScope.GameModeN).map(Number))
    gm = sorted[gm]
    Network.matches.do.creatematch
      Name: name
      GameMode: gm
    findMatchSound.play()
  $scope.dismissCreate = ->
    $scope.showCreateMatch = false
  # Is currently controlling a game
  $scope.createStartgame = ->
    $scope.showCreateMatch = true
  $scope.showRightCont = ->
    Network.liveMatches.length>0||$scope.games.length>0||$scope.canStartGames()||$scope.isAdminOfGame()||Network.activeResult?||Network.activeMatch?||Network.activeChallenge?
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
        uiButtonSound.play()
        if err?
          new PNotify
            title: "Join Error"
            text: err
            type: "error"
            desktop:
              desktop: true
          return
    return
  $scope.panelTabs = {
    selected: 0
  }
  $scope.humanizeChatName = (name)->
    Humanize.titleCase name
  $scope.leaveCurrentChat = (cb)->
    chat = $scope.chats[$scope.panelTabs.selected]
    return if !chat?
    if chat.Leavable
      Network.chat.invoke "leave", {Id: chat.Id}
    else
      swal("Can't Leave", "You can't leave this chat.", "error")
  $scope.isInGame = (game)->
    if !game?
      return Network.activeMatch?
    return false if !Auth.currentUser? or !Network.activeMatch?
    (_.findIndex game.Players, {SID: Auth.currentUser.steam.steamid}) != -1
  $scope.gameList = ->
    return $scope.games
  $scope.allAreReady = ->
    return false if !Network.activeMatch?
    for plyr in Network.activeMatch.Players
      return false if !plyr.Ready
    return true
  $scope.joinGame = (game)->
    findMatchSound.play()
    Network.matches.do.joinmatch
      Id: game.Id
  $scope.gameFilter = (game)->
    game.Info.Status==0 || (Network.activeMatch? && Network.activeMatch.Id is game.Id)
  $scope.sendChat = (msg)->
    Network.chat.invoke("sendmessage", {Channel: service.chats[$scope.panelTabs.selected].Id, Text: msg})
  $scope.checkPanelTab = ->
    staticTabCount = 0
    staticTabCount++ if Auth.inRole "vouch"
    staticTabCount++ if Auth.inRole "admin"
    idx = 0
    if state.is "panel.chat"
      return
    else if state.is "panel.leaderboard"
      idx = $scope.chats.length
    else if state.is "panel.vouch"
      idx = $scope.chats.length+1
    else if state.is "panel.admin"
      idx = $scope.chats.length+staticTabCount
    $scope.panelTabs.selected = idx
  clr.push $rootScope.$on '$stateChangeSuccess', (event, toState, toParams, fromState, fromParams) ->
    $scope.checkPanelTab()
  $scope.$on 'destroy', ->
    for cl in clr
      cl()
    clr.length = 0
