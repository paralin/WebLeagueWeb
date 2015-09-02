'use strict'

angular.module 'webleagueApp'
.controller 'LeagueCtrl', ($rootScope, $scope, Network, $stateParams, $timeout, LeagueStore, safeApply, Auth, $state, Decay) ->
  $scope.message = ""

  $scope.leagues = LeagueStore.leagues
  $scope.leagueid = $stateParams.id

  Auth.getLoginStatus ->
    LeagueStore.getLeagues (leagues)->
      if !leagues[$scope.leagueid]? or !Auth.currentUser? or !Auth.currentUser.vouch? or $scope.leagueid not in Auth.currentUser.vouch.leagues
        swal
          title: "Not Vouched"
          text: "You are not vouched into \"#{$scope.leagueid}\" or it does not exist."
          type: "error"
        $state.go("panel")

  $scope.network = Network
  $scope.showWatchGame = (game)->
    swal
      title: "Watch Game"
      text: "Console command:<br/><code>watch_server \"#{game.Setup.Details.ServerSteamID}\"</code>"
      html: true

  $scope.resultDesc = (res)->
    if res.MatchCounted
      switch res.Result
        when 0 then "Result unknown!"
        when 2 then "Radiant victory!"
        when 3 then "Dire victory!"
        else "Unknown result."
    else
      "Match not counted."

  $scope.decayAlertClass = ->
    info = Decay.info($stateParams.id)
    cl = "alert"
    if info? and info.decayStarted
      cl += " alert-red"
    cl

  $scope.showDecayAlert = ->
    Decay.info($stateParams.id)? and !Network.activeMatch?

  $scope.decayAlertText = ->
    msg = ""
    info = Decay.info($stateParams.id)
    if info?
      if info.decayStarted
        msg = "You have lost "+info.decayedPoints+" pts to decay."
      else
        decayStart = moment(info.decayStartTime)
        msg = "Your rating will decay "+decayStart.fromNow()+"."
    msg

  $scope.games = (avail, league)->
    _.filter avail, (g)->
      g.Info.League is league

  $scope.createGame = (gm)->
    Network.matches.createMatch({MatchType: 0, GameMode: gm, League: $scope.leagueid}).done (err)->
      if err?
        new PNotify
          title: "Can't Create Match"
          text: err
          type: "error"

  $scope.joinGame = (game, spec)->
    Network.matches.joinMatch(game.Id, spec).done (err)->
      if err?
        new PNotify
          title: "Can't Join Match"
          text: err
          type: "error"

  $scope.kickPlayer = (plyr)->
    # Play kicked sound for effect
    $rootScope.playSound "kicked"
    Network.matches.kickPlayer(plyr.SID).done (err)->
      if err?
        new PNotify
          title: "Can't Kick Player"
          text: err
          type: "error"

  $scope.pickPlayer = (plyr)->
    $rootScope.playSound "buttonPress"
    Network.matches.pickPlayer(plyr.SID).done (err)->
      if err?
        new PNotify
          title: "Can't Pick Player"
          text: err
          type: "error"

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
            if game.Setup.Details.SpectatorCount > 0
              game.Setup.Details.SpectatorCount+" spectators."
            else
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

  $scope.canLeave = (game)->
    game.Info.Status == 0

  $scope.msgTime = (date)->
    moment(date).format "h:mm a"

  $scope.allReady = (game)->
    for plyr in game.Players
      return false if plyr.Team < 2 and !plyr.Ready
    true

  $scope.canStart = (game)->
    (game.Info.Status is 0 and $scope.playerCount(game)>=$scope.maxPlayers(game)) or (game.Info.Status is 2 and $scope.allReady(game))

  $scope.playerPercent = (game)->
    num = $scope.playerCount(game)/$scope.maxPlayers(game)
    num*100

  $scope.notMe = (member)->
    Auth.currentUser? and Auth.currentUser.steam.steamid isnt member.SteamID

  $scope.chat = (chats, leagueid)->
    _.findWhere _.values(chats), {Name: leagueid}

  $scope.chatMembers = (chat)->
    return [] if !chat?
    res = []
    for member in chat.Members
      memb = Network.members[member]
      res.push memb if memb?
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

  $scope.$on "chatMessage", (eve, chatid, memberid, text, service, time, chatname)->
    if chatname is $scope.leagueid
      ele = chatContainer()
      return if ele.length is 0
      ele = ele[0]
      scrollChatToBottom() if ele.scrollTop > ele.scrollHeight-(ele.offsetHeight+30)

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
          Network.chat.sendMessage chat.Id, msg
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
