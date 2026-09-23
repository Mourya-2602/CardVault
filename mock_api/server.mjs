import http from 'node:http';
import { randomUUID } from 'node:crypto';

const PORT = Number.parseInt(process.env.PORT ?? '3000', 10);

const users = [
  { email: 'demo@cardvault.local', password: 'cardvault', name: 'Mourya' },
];

const tokens = new Map();
const idempotency = new Map();
let paymentDebits = 0;

function seed() {
  return {
    cards: [
      {
        id: 'card-debit-1',
        type: 'debit',
        network: 'rupay',
        maskedNumber: '**** 4410',
        expiry: '08/28',
        status: 'active',
        pan: '6083820012344410',
        cvv: '142',
      },
      {
        id: 'card-credit-1',
        type: 'credit',
        network: 'visa',
        maskedNumber: '**** 2291',
        expiry: '11/27',
        status: 'active',
        pan: '4111111111112291',
        cvv: '331',
      },
      {
        id: 'card-frozen-1',
        type: 'credit',
        network: 'mastercard',
        maskedNumber: '**** 8802',
        expiry: '03/29',
        status: 'frozen',
        pan: '5555555555558802',
        cvv: '204',
      },
    ],
    controls: {
      'card-debit-1': {
        online: true,
        contactless: true,
        atm: true,
        international: false,
        internationalUntil: null,
      },
      'card-credit-1': {
        online: true,
        contactless: true,
        atm: false,
        international: true,
        internationalUntil: '2026-12-31T00:00:00Z',
      },
      'card-frozen-1': {
        online: false,
        contactless: false,
        atm: false,
        international: false,
        internationalUntil: null,
      },
    },
    limits: {
      'card-debit-1': {
        atmDailyPaise: 2000000,
        posDailyPaise: 5000000,
        onlineDailyPaise: 3000000,
        maxPaise: 10000000,
      },
      'card-credit-1': {
        atmDailyPaise: 1000000,
        posDailyPaise: 8000000,
        onlineDailyPaise: 6000000,
        maxPaise: 15000000,
      },
      'card-frozen-1': {
        atmDailyPaise: 500000,
        posDailyPaise: 500000,
        onlineDailyPaise: 500000,
        maxPaise: 2000000,
      },
    },
    credit: {
      'card-credit-1': {
        limitPaise: 20000000,
        availablePaise: 12500000,
        outstandingPaise: 7500000,
        minDuePaise: 375000,
        dueDate: new Date(Date.now() + 2 * 24 * 60 * 60 * 1000).toISOString(),
      },
      'card-frozen-1': {
        limitPaise: 10000000,
        availablePaise: 8200000,
        outstandingPaise: 1800000,
        minDuePaise: 90000,
        dueDate: new Date(Date.now() + 12 * 24 * 60 * 60 * 1000).toISOString(),
      },
    },
    statements: {
      'card-credit-1': {
        '2026-08': {
          month: '2026-08',
          openingPaise: 1200000,
          closingPaise: 2100000,
          transactions: [
            txn('txn-aug-1', '2026-08-04T08:12:00Z', 'Big Bazaar', 84500, 'Groceries'),
            txn('txn-aug-2', '2026-08-18T14:40:00Z', 'Indian Oil', 210000, 'Fuel'),
          ],
        },
        '2026-09': {
          month: '2026-09',
          openingPaise: 2100000,
          closingPaise: 7500000,
          transactions: [
            txn('txn-sep-1', '2026-09-02T11:03:00Z', 'Cafe Coffee Day', 42000, 'Food'),
            txn('txn-sep-2', '2026-09-08T19:21:00Z', 'Amazon', 259900, 'Shopping'),
            txn('txn-sep-3', '2026-09-14T07:45:00Z', 'Uber', 31800, 'Travel'),
            txn('txn-sep-4', '2026-09-20T16:10:00Z', 'Apollo Pharmacy', 15600, 'Health'),
          ],
        },
      },
    },
    replacements: {},
    alerts: [
      {
        id: 'alert-1',
        cardId: 'card-credit-1',
        merchant: 'Amazon',
        location: 'Bengaluru, IN',
        amountPaise: 259900,
        at: '2026-09-08T19:21:00Z',
      },
      {
        id: 'alert-2',
        cardId: 'card-credit-1',
        merchant: 'Cafe Coffee Day',
        location: 'Hyderabad, IN',
        amountPaise: 42000,
        at: '2026-09-02T11:03:00Z',
      },
    ],
  };
}

function txn(id, date, merchant, amountPaise, category) {
  return { id, date, merchant, amountPaise, category };
}

let db = seed();

function publicCard(card) {
  return {
    id: card.id,
    type: card.type,
    network: card.network,
    maskedNumber: card.maskedNumber,
    expiry: card.expiry,
    status: card.status,
  };
}

function send(res, status, body) {
  const payload = JSON.stringify(body);
  res.writeHead(status, {
    'Content-Type': 'application/json',
    'Access-Control-Allow-Origin': '*',
    'Access-Control-Allow-Headers':
      'Content-Type, Authorization, Idempotency-Key, X-CardVault-Simulate',
    'Access-Control-Allow-Methods': 'GET,POST,PUT,PATCH,OPTIONS',
  });
  res.end(payload);
}

function error(res, status, code, message, details) {
  send(res, status, {
    error: {
      code,
      message,
      details: details ?? null,
      traceId: `trc_${randomUUID()}`,
    },
  });
}

function readBody(req) {
  return new Promise((resolve, reject) => {
    const chunks = [];
    req.on('data', (chunk) => chunks.push(chunk));
    req.on('end', () => {
      if (chunks.length === 0) {
        resolve({});
        return;
      }
      try {
        resolve(JSON.parse(Buffer.concat(chunks).toString('utf8')));
      } catch (err) {
        reject(err);
      }
    });
    req.on('error', reject);
  });
}

function authenticate(req) {
  const header = req.headers.authorization ?? '';
  const token = header.replace('Bearer ', '');
  return tokens.get(token) ?? null;
}

function findCard(id) {
  return db.cards.find((card) => card.id === id);
}

const server = http.createServer(async (req, res) => {
  if (req.method === 'OPTIONS') {
    send(res, 204, {});
    return;
  }

  const url = new URL(req.url, `http://127.0.0.1:${PORT}`);
  const simulate = req.headers['x-cardvault-simulate'];
  if (simulate === 'timeout') {
    return;
  }
  if (simulate === '500') {
    error(res, 500, 'SERVER', 'The service is unavailable. Try again shortly.');
    return;
  }
  if (simulate === '401') {
    error(res, 401, 'UNAUTHORIZED', 'Your session has expired.');
    return;
  }

  try {
    if (req.method === 'GET' && url.pathname === '/health') {
      send(res, 200, { ok: true });
      return;
    }

    if (req.method === 'POST' && url.pathname === '/auth/login') {
      const body = await readBody(req);
      const user = users.find(
        (entry) =>
          entry.email === String(body.email ?? '').trim().toLowerCase() &&
          entry.password === body.password,
      );
      if (!user) {
        error(res, 401, 'INVALID_CREDENTIALS', 'The email or password is incorrect.');
        return;
      }
      const token = `tok_${randomUUID()}`;
      tokens.set(token, user.email);
      send(res, 200, { token, email: user.email });
      return;
    }

    if (req.method === 'GET' && url.pathname === '/alerts') {
      const user = authenticate(req);
      if (!user) {
        error(res, 401, 'UNAUTHORIZED', 'Your session has expired.');
        return;
      }
      send(res, 200, { alerts: db.alerts });
      return;
    }

    const user = authenticate(req);
    if (!user) {
      error(res, 401, 'UNAUTHORIZED', 'Your session has expired.');
      return;
    }

    if (simulate === '403') {
      error(res, 403, 'FORBIDDEN', 'You are not allowed to do that.');
      return;
    }
    if (simulate === '404') {
      error(res, 404, 'NOT_FOUND', 'We could not find that information.');
      return;
    }
    if (simulate === '409') {
      error(res, 409, 'CONFLICT', 'That information changed. Refresh and try again.');
      return;
    }
    if (simulate === '422') {
      error(res, 422, 'VALIDATION', 'Check the information and try again.');
      return;
    }

    if (req.method === 'GET' && url.pathname === '/cards') {
      send(res, 200, { cards: db.cards.map(publicCard) });
      return;
    }

    const cardMatch = url.pathname.match(/^\/cards\/([^/]+)(?:\/(.*))?$/);
    if (!cardMatch) {
      error(res, 404, 'NOT_FOUND', 'We could not find that information.');
      return;
    }

    const cardId = cardMatch[1];
    const rest = cardMatch[2] ?? '';
    const card = findCard(cardId);
    if (!card) {
      error(res, 404, 'NOT_FOUND', 'We could not find that card.');
      return;
    }

    if (req.method === 'GET' && rest === '') {
      send(res, 200, publicCard(card));
      return;
    }

    if (req.method === 'PATCH' && rest === 'status') {
      if (card.status === 'blocked') {
        error(res, 409, 'BLOCKED', 'This card is permanently blocked.');
        return;
      }
      const body = await readBody(req);
      const next = String(body.status ?? '').toLowerCase();
      if (next !== 'frozen' && next !== 'active') {
        error(res, 422, 'VALIDATION', 'Choose freeze or unfreeze.');
        return;
      }
      card.status = next;
      send(res, 200, publicCard(card));
      return;
    }

    if (req.method === 'GET' && rest === 'controls') {
      send(res, 200, db.controls[cardId]);
      return;
    }

    if (req.method === 'PUT' && rest === 'controls') {
      if (card.status === 'blocked') {
        error(res, 409, 'BLOCKED', 'This card is permanently blocked.');
        return;
      }
      const body = await readBody(req);
      if (body.international && body.internationalUntil) {
        const until = new Date(body.internationalUntil);
        const today = new Date();
        today.setHours(0, 0, 0, 0);
        if (until < today) {
          error(res, 422, 'PAST_DATE', 'Choose today or a future date.');
          return;
        }
      }
      db.controls[cardId] = {
        online: Boolean(body.online),
        contactless: Boolean(body.contactless),
        atm: Boolean(body.atm),
        international: Boolean(body.international),
        internationalUntil: body.internationalUntil ?? null,
      };
      send(res, 200, db.controls[cardId]);
      return;
    }

    if (req.method === 'GET' && rest === 'limits') {
      send(res, 200, db.limits[cardId]);
      return;
    }

    if (req.method === 'PUT' && rest === 'limits') {
      const body = await readBody(req);
      const maxPaise = db.limits[cardId].maxPaise;
      for (const field of ['atmDailyPaise', 'posDailyPaise', 'onlineDailyPaise']) {
        if (!Number.isInteger(body[field]) || body[field] < 0) {
          error(res, 422, 'VALIDATION', 'Enter a valid limit.');
          return;
        }
        if (body[field] > maxPaise) {
          error(res, 422, 'ABOVE_MAX', 'That amount is above the bank maximum.');
          return;
        }
      }
      db.limits[cardId] = {
        ...db.limits[cardId],
        atmDailyPaise: body.atmDailyPaise,
        posDailyPaise: body.posDailyPaise,
        onlineDailyPaise: body.onlineDailyPaise,
      };
      send(res, 200, db.limits[cardId]);
      return;
    }

    if (req.method === 'POST' && rest === 'reveal') {
      if (card.status === 'blocked') {
        error(res, 403, 'FORBIDDEN', 'Blocked cards cannot reveal details.');
        return;
      }
      send(res, 200, {
        pan: card.pan,
        expiry: card.expiry,
        cvv: card.cvv,
        expiresInSeconds: 30,
      });
      return;
    }

    if (req.method === 'GET' && rest === 'credit-summary') {
      const summary = db.credit[cardId];
      if (!summary) {
        error(res, 404, 'NOT_FOUND', 'Credit summary is available for credit cards only.');
        return;
      }
      send(res, 200, summary);
      return;
    }

    if (req.method === 'GET' && rest === 'statements') {
      const months = Object.values(db.statements[cardId] ?? {}).map((item) => ({
        month: item.month,
        openingPaise: item.openingPaise,
        closingPaise: item.closingPaise,
      }));
      send(res, 200, { statements: months });
      return;
    }

    const statementMatch = rest.match(/^statements\/([^/]+)$/);
    if (req.method === 'GET' && statementMatch) {
      const month = statementMatch[1];
      const statement = db.statements[cardId]?.[month];
      if (!statement) {
        error(res, 404, 'NOT_FOUND', 'No statement exists for that month.');
        return;
      }
      send(res, 200, statement);
      return;
    }

    if (req.method === 'POST' && rest === 'payments') {
      const key = req.headers['idempotency-key'];
      if (!key) {
        error(res, 422, 'IDEMPOTENCY', 'A payment confirmation key is required.');
        return;
      }
      if (idempotency.has(key)) {
        send(res, 200, idempotency.get(key));
        return;
      }
      const body = await readBody(req);
      const amountPaise = body.amountPaise;
      const summary = db.credit[cardId];
      if (!summary) {
        error(res, 422, 'VALIDATION', 'Bill payment is available for credit cards only.');
        return;
      }
      if (!Number.isInteger(amountPaise) || amountPaise <= 0) {
        error(res, 422, 'VALIDATION', 'Enter a valid payment amount.');
        return;
      }
      if (amountPaise > summary.outstandingPaise) {
        error(res, 422, 'VALIDATION', 'You cannot pay more than the outstanding amount.');
        return;
      }
      paymentDebits += 1;
      summary.outstandingPaise -= amountPaise;
      summary.availablePaise += amountPaise;
      const result = {
        paymentId: `pay_${randomUUID()}`,
        amountPaise,
        outstandingPaise: summary.outstandingPaise,
        debitCount: paymentDebits,
        status: 'success',
      };
      idempotency.set(key, result);
      send(res, 200, result);
      return;
    }

    if (req.method === 'POST' && rest === 'block') {
      if (card.status === 'blocked') {
        error(res, 409, 'ALREADY_BLOCKED', 'This card is already blocked.');
        return;
      }
      const body = await readBody(req);
      if (!body.reason) {
        error(res, 422, 'VALIDATION', 'Choose a reason to block this card.');
        return;
      }
      card.status = 'blocked';
      db.replacements[cardId] = {
        requested: Boolean(body.requestReplacement),
        status: body.requestReplacement ? 'replacement_in_progress' : 'not_requested',
      };
      send(res, 200, {
        ...publicCard(card),
        replacement: db.replacements[cardId],
      });
      return;
    }

    error(res, 404, 'NOT_FOUND', 'We could not find that information.');
  } catch (err) {
    error(res, 500, 'SERVER', 'The service is unavailable. Try again shortly.');
  }
});

server.listen(PORT, () => {
  process.stdout.write(`CardVault mock API listening on http://127.0.0.1:${PORT}\n`);
});
