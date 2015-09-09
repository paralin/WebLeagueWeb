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
    Network.admin.changeResult(result._id, result.Result).done (err)->
      $scope.pendingResultChange = false
      if !err?
        loadResults()

  $scope.submitNewResult = (e, league)->
    e.preventDefault()
    console.log "submit new to #{league}"
    swal
      title: "Submit Result"
      text: "Enter a match ID to submit to #{league}."
      type: "input"
      showCancelButton: true
      closeOnConfirm: false
      inputPlaceholder: "Enter match ID."
      showLoaderOnConfirm: true
    , (inputVal)->
      if inputVal is "" or !inputVal?
        swal.showInputError "Enter a match ID!"
        return false
      if _.isNaN parseInt(inputVal)
        swal.showInputError "Enter a match ID (number)!"
        return false

      Network.admin.submitMatch(parseInt(inputVal), league).done (err)->
        if err?
          swal.showInputError err
        else
          swal
            title: "Result Submitted"
            text: "Submitted match ID "+inputVal+" to league "+league+"."
            type: "success"

      return

  $scope.recalcResult = (result)->
    Network.admin.recalculateMatch result._id

  $scope.dtColumnDefs = [
    DTColumnDefBuilder.newColumnDef(0)
    DTColumnDefBuilder.newColumnDef(1).notSortable()
    DTColumnDefBuilder.newColumnDef(2).notSortable()
  ]

  $scope.$on 'destroy', ->
    for cl in clr
      cl()
    clr.length = 0
