'use strict'

describe 'Controller: PanelCtrl', ->

  # load the controller's module
  beforeEach module 'webleagueApp'
  PanelCtrl = undefined
  scope = undefined

  # Initialize the controller and a mock scope
  beforeEach inject ($controller, $rootScope) ->
    scope = $rootScope.$new()
    PanelCtrl = $controller 'PanelCtrl',
      $scope: scope

  it 'should ...', ->
    expect(1).toEqual 1
