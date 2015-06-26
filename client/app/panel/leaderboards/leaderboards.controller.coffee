'use strict'

angular.module 'webleagueApp'
.controller 'LeaderboardsCtrl', ($scope, Network, $rootScope, $stateParams, $http, Auth, LeagueStore) ->
  $scope.leagues = LeagueStore.leagues
  $scope.page =
    title: 'Leaderboards',
    subtitle: 'All leagues'

  $scope.getRecord = (leagueid)->
    league = LeagueStore.leagues[leagueid]
    return "Unknown" if !league?
    leagueprof = Auth.currentUser.profile.leagues[leagueid+":"+league.CurrentSeason]
    return "No record" if !leagueprof?
    "#{leagueprof.wins}/#{leagueprof.losses} - #{leagueprof.rating}"

  $scope.addIndexes = (league, seasons)->
    league.DashSelectedSeason = seasons[league.CurrentSeason] unless league.DashSelectedSeason?
    i = 0
    for season in seasons
      season.idx = i
      i++
    seasons

.controller 'LeaderboardCtrl', ($scope, LeagueStore, DTOptionsBuilder, DTColumnDefBuilder, Network)->
  $scope.totalPrizepool = (dist)->
    dist.reduce ((pv, cv) ->
      pv + cv
    ), 0
  $scope.calcPrize = (season, idx)->
    return 0 unless season.PrizepoolDist? and season.PrizepoolDist.length>idx
    season.PrizepoolDist[idx]
  $scope.orNum = (n1, n2)->
    return n2 if n1 is 0
    n1

  $scope.leagueMembers = (league, isntdash, idx)->
    return [] if !league?

    # Get season
    season = null
    seasonidx = null
    if isntdash
      season = league.Seasons[idx]
      seasonidx = idx
    else
      season = league.DashSelectedSeason
      seasonidx = season.idx

    id = league._id+":"+seasonidx
    res = []
    for mid, member of Network.members
      continue if !member.LeagueProfiles?
      prof = member.LeagueProfiles[id]
      continue if !prof? or (prof.wins+prof.losses) == 0
      prof.Name = member.Name
      prof.ID = member.ID
      prof.Avatar = member.Avatar
      res.push prof
    _.sortBy res, (member)-> -member.rating
    #res

  $scope.dtOptions =
    autoWidth: true
    paging: false
    searching: false
    info: false

  $scope.dtColumnDefs = [
    {
      title: "Rank"
    }
    {
    }
    {}
    {}
    {}
  ]
