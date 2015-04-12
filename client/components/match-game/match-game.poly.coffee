Polymer 'match-game', {
  inGame: false
  joinMatch: ->
    @fire 'pressed-join', {match: @match}
  joinMatchSpectator: ->
    @fire 'pressed-join-spec', {match: @match}
  getMe: ->
    _.find @match.Players, {SID: @steamid}
  showCaptainButtons: ->
    me = @getMe()
    return false if !me?
    me.IsCaptain && @match.Info.CaptainStatus isnt me.Team
  pickPlayer: (e, d, t)->
    sid = t.attributes["data-player"].value
    @fire "picked-player", {SID: sid}
  toJson: (o)->
    JSON.stringify o
  numPlayers: (Players)->
    return 0 if !Players?
    plyrs = _.filter Players, (plyr)->
      plyr.Team < 2
    plyrs.length
}
