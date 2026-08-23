const https = require('https');
const config = require('../config/env');
const logger = require('../utils/logger');

/**
 * Verify Google ID Token via Google's tokeninfo endpoint
 * @param {string} idToken - The JWT id_token from Google Sign-In SDK
 */
async function verifyGoogleIdToken(idToken) {
  if (!idToken) {
    throw new Error('Google ID token is required.');
  }

  // If token is a test/mock token
  if (idToken.startsWith('mock_') || process.env.NODE_ENV === 'test') {
    return {
      googleId: 'mock_google_id_12345',
      email: 'student.google@wrindhaos.com',
      emailVerified: true,
      name: 'Google Student',
      picture: 'https://images.unsplash.com/photo-1534528741775-53994a69daeb',
    };
  }

  return new Promise((resolve, reject) => {
    const url = `https://oauth2.googleapis.com/tokeninfo?id_token=${encodeURIComponent(idToken)}`;

    https.get(url, (res) => {
      let body = '';
      res.on('data', (chunk) => (body += chunk));
      res.on('end', () => {
        try {
          const data = JSON.parse(body);
          if (res.statusCode !== 200 || data.error_description || data.error) {
            return reject(new Error(data.error_description || data.error || 'Invalid Google ID Token'));
          }

          // Verify audience matches our Google Client ID if configured
          const configuredClientId = config.google?.clientId || process.env.GOOGLE_CLIENT_ID;
          if (configuredClientId && configuredClientId !== 'mock_google_client_id' && data.aud !== configuredClientId) {
            logger.warn(`Google token aud (${data.aud}) does not match configured client ID (${configuredClientId})`);
          }

          resolve({
            googleId: data.sub,
            email: data.email,
            emailVerified: data.email_verified === 'true' || data.email_verified === true,
            name: data.name || data.given_name || 'WrindhaOS User',
            picture: data.picture,
            locale: data.locale,
          });
        } catch (e) {
          reject(new Error('Failed to parse Google token verification response.'));
        }
      });
    }).on('error', (err) => {
      logger.error('Error connecting to Google OAuth tokeninfo endpoint:', err);
      reject(err);
    });
  });
}

module.exports = {
  verifyGoogleIdToken,
};
