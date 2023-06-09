'use strict';

const { queueDeploy } = require('../lib/queue.deploy.js');
const config = require('../queue.config.js');

const settings = { ...config, phase: config.options.env };

// Deploys the queue image
queueDeploy(settings);
