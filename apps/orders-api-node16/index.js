'use strict';

// Orders API (Node.js 16).
// Upgrade traps (what a runtime upgrade must change):
//  - aws-sdk v2: built into nodejs16.x only. nodejs18.x+ ship SDK v3, so `require('aws-sdk')` fails.
//  - callback-style handler: not supported on nodejs24.x. Must become an async handler.
//  - new Buffer(): deprecated (DEP0005).
//  - url.parse(): legacy API; use the WHATWG URL class.
//  - util.isString: removed in Node.js 23; util.isArray: deprecated (see lib/format.js).
const AWS = require('aws-sdk');
const url = require('url');
const querystring = require('querystring');
const { formatOrder } = require('./lib/format');

AWS.config.update({ region: process.env.AWS_REGION || 'us-east-1' });
const sts = new AWS.STS();

exports.handler = function (event, context, callback) {
  const raw = (event && event.rawPath) || '/orders?id=42&currency=usd';
  const parsed = url.parse(raw, true);
  const token = new Buffer(String(parsed.query.id || 'none')).toString('base64');

  sts.getCallerIdentity({}).promise()
    .then((who) => {
      const body = formatOrder({
        id: parsed.query.id,
        currency: parsed.query.currency,
        items: event && event.items ? event.items : ['widget'],
        token,
        account: who.Account,
      });
      callback(null, {
        statusCode: 200,
        headers: { 'content-type': 'application/json' },
        body: JSON.stringify(body),
        next: '/orders?' + querystring.stringify({ after: parsed.query.id }),
      });
    })
    .catch((err) => callback(err));
};
