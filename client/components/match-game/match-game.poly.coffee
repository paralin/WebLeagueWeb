Polymer 'match-game', {
  inGame: false
  joinMatch: ->
    @fire 'pressed-join', {match: @match}
  getMe: ->
    console.log @steamid
    _.find @match.Players, {SID: @steamid}
  showCaptainButtons: ->
    me = @getMe()
    me.IsCaptain && @match.Info.CaptainStatus==me.Team
  pickPlayer: (e, d, t)->
    sid = t.attributes["data-player"].value
    @fire "picked-player", {SID: sid}
  toJson: (o)->
    JSON.stringify o
}
