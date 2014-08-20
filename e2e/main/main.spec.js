'use strict';

describe('Main View', function() {
  var page;

  beforeEach(function() {
    browser.get('/');
    page = require('./main.po');
  });

  it('should redirect to the login page on first load', function() {
    browser.waitForAngular();
    expect(page.getCurrentUrl()).toContain('login');
  });
});
