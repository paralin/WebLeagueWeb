Polymer 'match-result', {
  votedRadiant: (player)->
    return false if !@result.Votes[player.SID]?
    return @result.Votes[player.SID]
  votedDire: (player)->
    return false if !@result.Votes[player.SID]?
    return !@result.Votes[player.SID]
}
