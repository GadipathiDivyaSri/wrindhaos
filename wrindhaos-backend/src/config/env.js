const path = require('path');
require('dotenv').config({ path: path.resolve(__dirname, '../../.env') });

const config = {
  port: process.env.PORT || 5000,
  env: process.env.NODE_ENV || 'development',

  jwt: {
    secret: process.env.JWT_SECRET || 'wrindhaos_super_secret_jwt_key_2026',
    expiresIn: process.env.JWT_EXPIRES_IN || '30d',
  },

  frontendUrl: process.env.FRONTEND_URL || 'http://localhost:8080',
};

module.exports = config;
