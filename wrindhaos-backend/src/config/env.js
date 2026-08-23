const path = require('path');
require('dotenv').config({ path: path.resolve(__dirname, '../../.env') });

const config = {
  port: process.env.PORT || 5000,
  env: process.env.NODE_ENV || 'development',

  supabase: {
    url: process.env.SUPABASE_URL || 'https://xyzproductivedb.supabase.co',
    anonKey: process.env.SUPABASE_ANON_KEY || 'mock_anon_key',
    serviceRoleKey: process.env.SUPABASE_SERVICE_ROLE_KEY || 'mock_service_role_key',
  },

  jwt: {
    secret: process.env.JWT_SECRET || 'wrindhaos_super_secret_jwt_key_2026',
    expiresIn: process.env.JWT_EXPIRES_IN || '30d',
  },

  google: {
    clientId: process.env.GOOGLE_CLIENT_ID || '',
    clientSecret: process.env.GOOGLE_CLIENT_SECRET || '',
  },

  msg91: {
    authKey: process.env.MSG91_AUTH_KEY || '',
    emailTemplateId: process.env.MSG91_EMAIL_TEMPLATE_ID || '',
    otpTemplateId: process.env.MSG91_OTP_TEMPLATE_ID || '',
    emailFrom: process.env.MSG91_EMAIL_FROM || 'no-reply@wrindhaos.com',
    domain: process.env.MSG91_DOMAIN || 'wrindhaos.com',
    senderId: process.env.MSG91_SENDER_ID || 'WRNDHA',
  },

  googlePlay: {
    packageName: process.env.GOOGLE_PLAY_PACKAGE_NAME || 'com.wrindhaos.productivity',
    serviceAccountEmail: process.env.GOOGLE_PLAY_SERVICE_ACCOUNT_EMAIL || '',
    privateKey: (process.env.GOOGLE_PLAY_PRIVATE_KEY || '').replace(/\\n/g, '\n'),
    subscriptionProductId: process.env.GOOGLE_PLAY_SUBSCRIPTION_PRODUCT_ID || 'pro_monthly_49',
  },

  otp: {
    provider: process.env.OTP_PROVIDER || 'msg91',
    apiKey: process.env.MSG91_AUTH_KEY || '',
    templateId: process.env.MSG91_EMAIL_TEMPLATE_ID || '',
  },

  fcm: {
    projectId: process.env.FCM_PROJECT_ID || 'wrindhaos',
    clientEmail: process.env.FCM_CLIENT_EMAIL || '',
    privateKey: (process.env.FCM_PRIVATE_KEY || '').replace(/\\n/g, '\n'),
    serviceAccountPath: process.env.FIREBASE_SERVICE_ACCOUNT_PATH || '',
  },

  frontendUrl: process.env.FRONTEND_URL || 'http://localhost:8080',
};

module.exports = config;
