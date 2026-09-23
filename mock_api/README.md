# CardVault mock API

Node HTTP server for the capstone. No npm packages required.

```text
node mock_api/server.mjs
```

Listens on `http://127.0.0.1:3000`.

## Demo user

- Email: `demo@cardvault.local`
- Password: `cardvault`

## Failure simulation

Send header `X-CardVault-Simulate` with one of:

`401`, `403`, `404`, `409`, `422`, `500`, `timeout`
