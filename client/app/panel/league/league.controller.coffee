'use strict'

angular.module 'webleagueApp'
.controller 'LeagueCtrl', ($rootScope, $scope, Network, $stateParams, $timeout, LeagueStore, safeApply, Auth) ->
  $scope.message = ""

  $scope.leagues = LeagueStore.leagues
  $scope.leagueid = $stateParams.id

  $scope.network = Network

  $scope.games = (avail, league)->
    _.filter avail, (g)->
      g.Info.League is league

  $scope.createGame = (gm)->
    Network.matches.do.creatematch({MatchType: 0, GameMode: gm, League: $scope.leagueid})

  $scope.joinGame = (game, spec)->
    Network.matches.do.joinmatch({Id: game.Id, Spec: spec})

  $scope.kickPlayer = (plyr)->
    # Play kicked sound for effect
    $rootScope.playSound "kicked"
    Network.matches.do.kickPlayer(plyr.SID)

  $scope.pickPlayer = (plyr)->
    $rootScope.playSound "buttonPress"
    Network.matches.do.pickPlayer(plyr.SID)

  $scope.gameStatus = (game)->
    switch game.Info.Status
      when 0
        if game.Setup? and game.Setup.Details?
          $rootScope.SetupStatusN[game.Setup.Details.Status]
        else
          "Waiting for players..."
      when 1
        "Team selection..."
      when 2
        if game.Setup?
          if game.Setup.Details.Status is 3
            if $scope.inGame(game) then "Password: "+game.Setup.Details.Password else "Joining the lobby..."
          else
            $rootScope.SetupStatusN[game.Setup.Details.Status]
        else
          "Waiting for setup..."
      when 3
        if game.Setup?
          stat = game.Setup.Details.Status
          if stat is 4
            $rootScope.MatchStateN[game.Setup.Details.State]
          else
            $rootScope.SetupStatusN[stat]
        else
          "Waiting for start..."


  $scope.playerCount = (game)->
    plyrs = _.filter game.Players, (plyr)->
      # Not spectator
      plyr.Team isnt 2
    plyrs.length

  $scope.maxPlayers = (game)->
    10

  $scope.canCancel = (game)->
    game.Info.Status < 3

  $scope.allReady = (game)->
    for plyr in game.Players
      return false if plyr.Team < 2 and !plyr.Ready
    true

  $scope.canStart = (game)->
    (game.Info.Status is 0 and $scope.playerCount(game)>=$scope.maxPlayers(game)) or (game.Info.Status is 2 and $scope.allReady(game))

  $scope.playerPercent = (game)->
    num = $scope.playerCount(game)/$scope.maxPlayers(game)
    num*100


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
    vh = $(window).height()-180
    chatContainer().css("height": vh)

  chatContainer = -> $(".chatMessageCont")

  scrollChatToBottom = ->
    $timeout ->
      ele = chatContainer()[0]
      ele.scrollTop = ele.scrollHeight+ele.offsetHeight+50
    , 10, false

  $scope.$on "chatMessage", (eve, upd, chat)->
    if chat.Name is $scope.leagueid
      ele = chatContainer()
      return if ele.length is 0
      ele = ele[0]
      if ele.scrollTop > ele.scrollHeight-(ele.offsetHeight+30)
        scrollChatToBottom()

  jqbind = []
  $scope.hasLoadedOnce = false
  $scope.$on "$viewContentLoaded", ->
    return if $scope.hasLoadedOnce
    $scope.hasLoadedOnce = true

    jqbind.push $(window).resize ->
      adjustInputLocation()

    jqbind.push $(".chatInput").keypress (e)->
      if e.which is 13
        sendMessage()
        return false

    adjustInputLocation()
    scrollChatToBottom()

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
