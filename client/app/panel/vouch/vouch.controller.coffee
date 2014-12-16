'use strict'

angular.module 'webleagueApp'
.controller 'VouchCtrl', ($scope, Profile, $state, $http, $filter, SteamID) ->
  clr = [] 
  $scope.profiles = Profile.list()
  $scope.steamIdValid = false
  currentId = ""
  $scope.loadVouch = (id)->
    console.log id
    currentId = ""
    $scope.steamID = id
    $scope.steamIDC = id
  $scope.deleteVouch = ->
    $scope.vouch = null
    $scope.vouchEmpty = false
    $scope.loadingVouch = true
    $http.post "/api/vouches/delete/#{currentId}"
      .success (data)->
        $scope.vouch = null
        $scope.vouchEmpty = false
        $scope.loadingVouch = false
        $scope.steamID = ""
        $scope.steamIDC = ""
        Profile.list (data)->
          if data?
            $scope.profiles = data
      .error (err, stat)->
        swal
          title: "Can't Delete Vouch"
          text: "The server for some reason refuses to unvouch that person. [#{stat}]"
          type: "error"
  $scope.saveVouch = ->
    $http.post "/api/vouches/update/#{currentId}", {data: $scope.vouch}
      .success (data)->
        swal
          title: "Vouch Updated"
          text: "Your changes will take effect when they refresh/sign in."
          type: "success"
        Profile.list (data)->
          if data?
            $scope.profiles = data
      .error (err, stat)->
        swal
          title: "Can't Update"
          text: "The server for some reason refuses to update that vouch. Sorry!"
          type: "error"
  $scope.createVouch = ->
    $scope.loadingVouch = true
    $scope.vouch = null
    $scope.vouchEmpty = false
    $http.post "/api/vouches/#{currentId}"
      .success (data)->
        $scope.loadingVouch = false
        $scope.vouch = data
        Profile.list (data)->
          if data?
            $scope.profiles = data
      .error (err, stat)->
        swal
          title: "Can't Create Vouch"
          text: "The server for some reason refuses to vouch that person. Sorry :( [#{stat}]"
          type: "error"
  clr.push $scope.$watch "steamID", (newVal, oldVal)->
    steam = new SteamID
    $scope.steamIdValid = steam.IsCommunityID(newVal) or steam.IsSteam2(newVal)
    unless $scope.steamIdValid
      $scope.loadingVouch = false
      $scope.vouch = null
  clr.push $scope.$watch "steamIDC", (newVal, oldVal)->
    return if newVal is currentId
    steam = new SteamID
    $scope.vouch = null
    $scope.loadingVouch = false
    $scope.vouchEmpty = false
    if steam.IsCommunityID newVal
      steam.SetCommunityID newVal
      currentId = steam.GetCommunityID()
    else if steam.IsSteam2 newVal
      steam.SetSteam2 newVal
      currentId = steam.GetCommunityID()
    else
      currentId = ""
      return
    $scope.steamID = currentId
    $scope.steamIDC = currentId
    $scope.loadingVouch = true
    $http.get "/api/vouches/get/#{currentId}"
      .success (data)->
        console.log data
        $scope.loadingVouch = false
        if !data?
          $scope.vouchEmpty = true
          $scope.vouch = null
        else
          $scope.vouch = data
      .error (err, stat)->
        if stat is 404
          $scope.loadingVouch = false
          $scope.vouchEmpty = true
          $scope.vouch = null
        else
          $scope.vouch = null
          $scope.vouchEmpty = false
          $scope.loadingVouch = false
          new PNotify
            title: "Server Error"
            text: "Problem fetching vouch information [#{stat}]."
            type: "error"
