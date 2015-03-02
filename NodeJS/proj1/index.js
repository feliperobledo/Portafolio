var cfg = require('_/config')
require('_/app').listen(cfg.port)

//Sometimes, the main app setup isn’t just listening on a port – you may also
//want to schedule some cron tasks, log that the server has started, etc. You
//can do that all in index.js.
