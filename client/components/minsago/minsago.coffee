angular.module("webleagueApp").directive "minsAgo", ($timeout)->
  restrict: 'E'
  template: "<span>{{mins}}</span>"
  link: (scope, ele, attrs)->
    if !attrs["datetime"]?
      console.log "mins-ago defined with no datetime param!"

    date = new Date(attrs["datetime"])

    ntime = null

    updateTime = ->
      now = new Date()
      # n is difference in seconds
      n = ((now-date)/1000)
      scope.mins = Math.floor(n/60)
      $timeout.cancel(ntime) if ntime?
      ntime = $timeout ->
        ntime = null
        updateTime()
      , ((60-(Math.floor(n)%60))+1)*1000

    #updateTime()

    attrs.$observe "datetime", (val)->
      date = new Date(val)
      updateTime()
