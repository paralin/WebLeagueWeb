Polymer 'match-game', {
  inGame: false
  joinMatch: ->
    @fire 'pressed-join', {match: @match}
}
