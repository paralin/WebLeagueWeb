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
    paging: true
    searching: false
    info: true

  $scope.leagueRes = (results, lid)->
    _.filter results, {League: lid}

  $scope.updateResult = (result)->
    $scope.pendingResultChange = true
    Network.admin.do.changematchresult result._id, result.Result, (err)->
      $scope.pendingResultChange = false
      if !err?
        loadResults()

  $scope.recalcResult = (result)->
    Network.admin.invoke("recalculatematch", {Id: result._id})

  $scope.dtColumnDefs = [
    DTColumnDefBuilder.newColumnDef(0)
    DTColumnDefBuilder.newColumnDef(1).notSortable()
    DTColumnDefBuilder.newColumnDef(2).notSortable()
  ]

  $scope.$on 'destroy', ->
    for cl in clr
      cl()
    clr.length = 0
