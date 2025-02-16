/**
 * Main application routes
 */

'use strict';

var errors = require('./components/errors');

module.exports = function(app) {

  // Insert routes below
  app.use('/api/vouches', require('./api/vouch'));
  app.use('/api/results', require('./api/result'));
  app.use('/api/leagues', require('./api/league'));
  app.use('/api/profiles', require('./api/profile'));
  app.use('/api/users', require('./api/user'));
  app.use('/api/heros', require('./api/hero'));
  app.use('/api/activematches', require('./api/activematch'));

  app.use('/auth', require('./auth'));

  // All undefined asset or api routes should return a 404
  app.route('/:url(api|auth|components|app|bower_components|assets)/*')
   .get(errors[404]);

  // All other routes should redirect to the index.html
  app.route('/*')
    .get(function(req, res) {
      res.sendfile(app.get('appPath') + '/index.html');
    });
};
