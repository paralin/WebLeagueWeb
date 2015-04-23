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
  isOwner: ->
    me = @getMe()
    return false if !me?
    me.SID == @match.Info.Owner
  pickPlayer: (e, d, t)->
    sid = t.attributes["data-player"].value
    @fire "picked-player", {SID: sid}
  kickPlayer: (e, d, t)->
    sid = t.attributes["data-player"].value
    @fire "kicked-player", {SID: sid}
  toJson: (o)->
    JSON.stringify o
  numPlayers: (Players)->
    return 0 if !Players?
    plyrs = _.filter Players, (plyr)->
      plyr.Team < 2
    plyrs.length
  msubstr: (str, i, x)->
    str.substring i, x
}
