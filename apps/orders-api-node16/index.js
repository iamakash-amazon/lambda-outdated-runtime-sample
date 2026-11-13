'use strict';

// Orders API (Node.js 24).
// Upgraded from Node.js 16:
//  - aws-sdk v2 -> @aws-sdk/client-sts v3 (STSClient + GetCallerIdentityCommand).
//  - callback-style handler -> async handler (callbacks are not supported on nodejs24.x).
//  - new Buffer() -> Buffer.from() (DEP0005).
//  - url.parse() / querystring -> WHATWG URL / URLSearchParams.
//  - util.isString / util.isArray -> typeof / Array.isArray (see lib/format.js).
const { STSClient, GetCallerIdentityCommand } = require('@aws-sdk/client-sts');
const { formatOrder } = require('./lib/format');

const sts = new STSClient({ region: process.env.AWS_REGION || 'us-east-1' });

exports.handler = async function (event) {
  const raw = (event && event.rawPath) || '/orders?id=42&currency=usd';
  const parsed = new URL(raw, 'http://localhost');
  const id = parsed.searchParams.get('id') ?? undefined;
  const currency = parsed.searchParams.get('currency') ?? undefined;
  const token = Buffer.from(String(id || 'none')).toString('base64');

  const who = await sts.send(new GetCallerIdentityCommand({}));
  const body = formatOrder({
    id,
    currency,
    items: event && event.items ? event.items : ['widget'],
    token,
    account: who.Account,
  });
  return {
    statusCode: 200,
    headers: { 'content-type': 'application/json' },
    body: JSON.stringify(body),
    next: '/orders?' + new URLSearchParams({ after: id ?? '' }).toString(),
  };
};
