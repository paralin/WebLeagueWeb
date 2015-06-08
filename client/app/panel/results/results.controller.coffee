'use strict'

angular.module 'webleagueApp'
.controller 'ResultsCtrl', ($scope, $rootScope, Result, DTColumnDefBuilder, LeagueStore, Network) ->
  clr = []
  $scope.results = []

  loadResults = ->
    Result.list (data)->
      $scope.results = data
  loadResults()

  $scope.leagues = LeagueStore.leagues

  $scope.pendingResultChange = false

  $scope.dtOptions =
    autoWidth: true
    paging: false
    searching: false
    info: false

  $scope.leagueRes = (results, lid)->
    _.filter results, {League: lid}

  $scope.updateResult = (result)->
    $scope.pendingResultChange = true
    Network.admin.do.changematchresult result._id, result.Result, ->
      $scope.pendingResultChange = false
      loadResults()

  $scope.dtColumnDefs = [
    DTColumnDefBuilder.newColumnDef(0)
    DTColumnDefBuilder.newColumnDef(1)
    DTColumnDefBuilder.newColumnDef(2)
    DTColumnDefBuilder.newColumnDef(3).notSortable()
  ]

  $scope.$on 'destroy', ->
    for cl in clr
      cl()
    clr.length = 0
