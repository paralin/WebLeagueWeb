'use strict';

describe('Main View', function() {
  var page;

  beforeEach(function() {
    browser.get('/');
    page = require('./main.po');
  });

  it('should redirect to the login page on first load', function() {
    browser.waitForAngular();
    expect(browser.getCurrentUrl()).toContain('login');
  });

  it('should have a sign in with steam button', function (){
    browser.waitForAngular();
    expect(page.loginButton.isPresent()).toBe(true);
  });

  it('should go to steam signin when clicking signin', function (){
    browser.waitForAngular();
    page.loginButton.click();
    expect(browser.getCurrentUrl()).toContain("steamcommunity");
  });
});
