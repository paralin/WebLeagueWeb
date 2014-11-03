'use strict'

angular.module 'webleagueApp'
.controller 'NovouchCtrl', ($scope) ->
    window.aswal = swal(
      title: "No vouch"
      text: "You have not been vouched into the league."
      type: "error"
      showCancelButton: false
      confirmButtonColor: "#DD6B55"
      confirmButtonText: "Log Out"
    , ->
      window.location.href = "/auth/logout"
    )
