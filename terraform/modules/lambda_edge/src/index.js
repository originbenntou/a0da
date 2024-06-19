const jwt = require('jsonwebtoken');
const jwksClient = require('jwks-rsa');
const util = require('util');
const verify = util.promisify(jwt.verify);

const client = jwksClient({
  jwksUri: 'https://gray-crab-515.cic-demo-platform.auth0app.com/.well-known/jwks.json'
});

function getKey(header, callback) {
  client.getSigningKey(header.kid, function (err, key) {
    const signingKey = key.publicKey || key.rsaPublicKey;
    callback(null, signingKey);
  });
}

exports.handler = async (event) => {
  const request = event.Records[0].cf.request;
  const headers = request.headers;
  
  if (request.method === 'OPTIONS') {
    return handleOptionsRequest();
  }
  
  if (!headers.authorization) {
    return unauthorizedResponse();
  }
  
  const token = headers.authorization[0].value.split(' ')[1];
  
  try {
    const decoded = await verify(token, getKey);
    console.log('User authenticated:', decoded);
    return {
      status: '200',
      statusDescription: 'OK',
      headers: request.headers,
      body: JSON.stringify(request.body)
    };
  } catch (err) {
    console.log('Authentication failed:', err);
    return unauthorizedResponse();
  }
};

function handleOptionsRequest() {
  return {
    status: '200',
    statusDescription: 'OK',
    headers: {
      'access-control-allow-origin': [{ key: 'Access-Control-Allow-Origin', value: '*' }],
      'access-control-allow-methods': [{ key: 'Access-Control-Allow-Methods', value: 'GET, HEAD, OPTIONS' }],
      'access-control-allow-headers': [{ key: 'Access-Control-Allow-Headers', value: 'Authorization' }],
    },
  };
}

function unauthorizedResponse() {
  return {
    status: '401',
    statusDescription: 'Unauthorized',
    headers: {
      'access-control-allow-origin': [{ key: 'Access-Control-Allow-Origin', value: '*' }],
    },
  };
}
