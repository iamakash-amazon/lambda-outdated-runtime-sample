'use strict';

// util.isString was removed in Node.js 23 and util.isArray is deprecated (DEP0044);
// use Array.isArray and typeof instead.
function formatOrder(order) {
  const items = Array.isArray(order.items) ? order.items : [order.items];
  const currency = typeof order.currency === 'string' ? order.currency.toUpperCase() : 'USD';
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
