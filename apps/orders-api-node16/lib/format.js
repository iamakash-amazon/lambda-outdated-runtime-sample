'use strict';

const util = require('util');

// util.isString was removed in Node.js 23 (TypeError on nodejs24.x); util.isArray is deprecated (DEP0044).
function formatOrder(order) {
  const items = util.isArray(order.items) ? order.items : [order.items];
  const currency = util.isString(order.currency) ? order.currency.toUpperCase() : 'USD';
  return {
    id: order.id,
    currency,
    count: items.length,
    items,
    token: order.token,
    account: order.account,
  };
}

module.exports = { formatOrder };
