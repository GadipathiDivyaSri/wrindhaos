const https = require('https');
const config = require('../config/env');
const logger = require('../utils/logger');

/**
 * Make HTTPS request helper
 */
function makeHttpRequest(options, postData = null) {
  return new Promise((resolve, reject) => {
    const req = https.request(options, (res) => {
      let body = '';
      res.on('data', (chunk) => (body += chunk));
      res.on('end', () => {
        try {
          const parsed = JSON.parse(body);
          resolve({ statusCode: res.statusCode, data: parsed });
        } catch (e) {
          resolve({ statusCode: res.statusCode, data: { message: body } });
        }
      });
    });

    req.on('error', (err) => reject(err));

    if (postData) {
      req.write(typeof postData === 'string' ? postData : JSON.stringify(postData));
    }
    req.end();
  });
}

/**
 * Send Email OTP via MSG91 Email API
 * @param {string} email - Target recipient email address
 * @param {string} otpCode - 6-digit numeric OTP
 * @param {string} templateId - MSG91 template ID (optional override)
 */
async function sendEmailOTP(email, otpCode, templateId = null) {
  const authKey = config.msg91?.authKey || process.env.MSG91_AUTH_KEY;
  const tId = templateId || config.msg91?.emailTemplateId || process.env.MSG91_EMAIL_TEMPLATE_ID;

  logger.info(`[MSG91 EMAIL OTP] Sending OTP to ${email}`, { templateId: tId });

  if (!authKey) {
    logger.warn('[MSG91] MSG91_AUTH_KEY not configured. Running in DEV simulation mode.', {
      email,
      otpCode,
    });
    return {
      success: true,
      simulated: true,
      message: `[DEV] MSG91 Email OTP simulated for ${email}`,
      otpCode,
    };
  }

  try {
    const payload = {
      recipients: [
        {
          to: [{ email: email }],
          variables: {
            OTP: otpCode,
            APP_NAME: 'WrindhaOS',
            EXPIRY_MINS: '5',
          },
        },
      ],
      from: {
        name: 'WrindhaOS',
        email: config.msg91?.emailFrom || process.env.MSG91_EMAIL_FROM || 'no-reply@wrindhaos.com',
      },
      domain: config.msg91?.domain || process.env.MSG91_DOMAIN || 'wrindhaos.com',
      template_id: tId,
    };

    const options = {
      hostname: 'control.msg91.com',
      port: 443,
      path: '/api/v5/email/send',
      method: 'POST',
      headers: {
        'Content-Type': 'application/json',
        authkey: authKey,
      },
    };

    const response = await makeHttpRequest(options, payload);

    if (response.statusCode >= 200 && response.statusCode < 300) {
      logger.info(`[MSG91] Email OTP successfully sent to ${email}`, response.data);
      return {
        success: true,
        data: response.data,
      };
    } else {
      logger.error(`[MSG91] Email OTP dispatch failed`, response.data);
      return {
        success: false,
        error: response.data,
      };
    }
  } catch (err) {
    logger.error(`[MSG91] Exception while dispatching Email OTP: ${err.message}`, err);
    return {
      success: false,
      error: err.message,
    };
  }
}

/**
 * Send SMS OTP via MSG91 OTP API (Optional/Mobile Verification)
 * @param {string} mobileNumber - 10-12 digit mobile number with country code
 * @param {string} otpCode - 6-digit numeric OTP
 */
async function sendSmsOTP(mobileNumber, otpCode) {
  const authKey = config.msg91?.authKey || process.env.MSG91_AUTH_KEY;
  const templateId = config.msg91?.otpTemplateId || process.env.MSG91_OTP_TEMPLATE_ID;

  if (!authKey) {
    logger.warn('[MSG91 SMS] MSG91_AUTH_KEY not configured. Running in DEV simulation mode.', {
      mobileNumber,
      otpCode,
    });
    return {
      success: true,
      simulated: true,
      message: `[DEV] MSG91 SMS OTP simulated for ${mobileNumber}`,
      otpCode,
    };
  }

  try {
    const formattedMobile = mobileNumber.replace(/\D/g, '');
    const path = `/api/v5/otp?template_id=${templateId}&mobile=${formattedMobile}&authkey=${authKey}&otp=${otpCode}`;

    const options = {
      hostname: 'control.msg91.com',
      port: 443,
      path: path,
      method: 'POST',
      headers: {
        'Content-Type': 'application/json',
      },
    };

    const response = await makeHttpRequest(options);
    return {
      success: response.statusCode === 200,
      data: response.data,
    };
  } catch (err) {
    logger.error(`[MSG91 SMS] Error sending SMS OTP: ${err.message}`, err);
    return { success: false, error: err.message };
  }
}

module.exports = {
  sendEmailOTP,
  sendSmsOTP,
};
