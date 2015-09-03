'use strict'

angular.module('webleagueApp').factory 'Decay', ($location, $interval, LeagueStore, Auth) ->
  decay =
    cachedTime: {}
    cachedInfo: {}
    info: (leagueid)->
      now = new Date()
      info = decay.cachedInfo[leagueid]
      return info if info? and decay.cachedTime[leagueid]? and decay.cachedTime[leagueid] > now.getTime()
      delete decay.cachedInfo[leagueid]
      delete decay.cachedTime[leagueid]

      info = {}
      info.now = now.getTime()

      # Locate the league
      league = LeagueStore.leagues[leagueid]
      return null if !league? or !league.Decay?
      info.DecaySettings = league.Decay

      # Season
      season = league.Seasons[league.CurrentSeason]
      return null if !season?

      # Make sure we can play in it
      return null if !league.IsActive or league.Archived or (new Date(season.Start)).getTime() > now.getTime()

      # Check if we have a profile for this league
      return null if !Auth.currentUser? or !Auth.currentUser.profile.leagues?
      leagueprof = Auth.currentUser.profile.leagues[leagueid+":"+league.CurrentSeason]
      return null if !leagueprof? or !leagueprof.lastGame?

      # If we're lower than the decay threshold then skip it
      return null if league.Decay.LowerThreshold? and league.Decay.LowerThreshold isnt 0 and leagueprof.rating <= league.Decay.LowerThreshold

      info.lastGame = leagueprof.lastGame
      lastGame = new Date(leagueprof.lastGame)
      info.decayStartTime = decayStartTime = lastGame.getTime()+(league.Decay.DecayStart*60000)

      # If decay started
      if info.decayStarted = info.now > decayStartTime
        info.decayElapsed = info.now-decayStartTime
        info.decayedPoints = (Math.floor(info.decayElapsed/3600000)+1)*info.DecaySettings.DecayRate
      else
        info.timeToDecay = decayStartTime-info.now

      cacheTill = new Date()
      cacheTill.setSeconds cacheTill.getSeconds()+10
      decay.cachedInfo[leagueid] = info
      decay.cachedTime[leagueid] = cacheTill.getTime()
      info
  window.decay = decay
