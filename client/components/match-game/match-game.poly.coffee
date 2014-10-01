Polymer 'match-game', {
  inGame: false
  joinMatch: ->
    @fire 'pressed-join', {match: @match}
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
}
