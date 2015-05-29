'use strict'

angular.module 'webleagueApp'
.controller 'DashboardCtrl', ($scope, Network, $rootScope, $stateParams, $http, Auth, LeagueStore) ->
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
  $scope.leagueMembers = (league)->
    # Get season
    season = league.DashSelectedSeason
    id = league._id+":"+season.idx
    res = []
    for mid, member of Network.members
      prof = member.LeagueProfiles[id]
      if prof?
        prof.Name = member.Name
        prof.ID = member.ID
        prof.Avatar = member.Avatar
        res.push prof
    _.sortBy res, (member)-> member.rating
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
