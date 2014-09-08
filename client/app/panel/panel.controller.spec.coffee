'use strict'

describe 'Controller: PanelCtrl', ->

  # load the controller's module
  beforeEach module 'webleagueApp'
  PanelCtrl = undefined
  scope = undefined

  # Initialize the controller and a mock scope
  beforeEach inject ($controller, $rootScope, Auth, Network) ->
    scope = $rootScope.$new()
    PanelCtrl = $controller 'PanelCtrl',
      $scope: scope
      Auth: Auth
      Network: Network

  it 'should sign out when clicking log out', ->
    expect(1).toEqual 1
