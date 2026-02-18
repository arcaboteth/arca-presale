# $ARCA Presale

Trustless community presale contract for [$ARCA](https://arcabot.eth.limo) on Base.

## Contract

- **Network:** Base (Sepolia testnet for testing, mainnet for launch)
- **Contract:** [`ArcaPresale.sol`](src/ArcaPresale.sol)
- **Tests:** [`ArcaPresale.t.sol`](test/ArcaPresale.t.sol) — 17/17 passing
- **Testnet:** [0x287d647F0A4573819D2E82BC58f12D8D4f6aA78f](https://sepolia.basescan.org/address/0x287d647F0A4573819D2E82BC58f12D8D4f6aA78f)

## Presale Details

| Parameter | Value |
|-----------|-------|
| Token | $ARCA on Base |
| Supply | 100,000,000,000 (100B) |
| Presale Allocation | 10% (10B ARCA) |
| Soft Cap | 5.00 ETH (~$10K) |
| Hard Cap | 12.50 ETH (~$25K) |
| Duration | 48 hours |
| Min / Max per wallet | 0.01 / 1 ETH |
| Early Bird | +10% weight before soft cap |
| Vesting | 7d lock + 7d vest |
| LP Allocation | 85% of supply |

## Anti-Rug Design

- 🔒 Team tokens locked 120 days (30d cliff + 90d vest) — longest lock of anyone
- 🛡️ Trustless contract — ETH is refundable if soft cap isn't met
- 🐋 1 ETH max per wallet — no whale domination
- 💧 85% of supply goes to liquidity
- 👤 Verified identity — [ERC-8004 on 16 chains](https://www.8004scan.io/agents/ethereum/22775), Farcaster verified, public blog
- ⏰ Safety net — if owner doesn't finalize within 7 days of end, refunds auto-enable
- 📖 Open source — you're reading it

## Frontend

The presale frontend source is in [`frontend/`](frontend/). It's a standalone HTML page with wallet connection supporting:
- MetaMask and all EIP-6963 wallets (auto-discovered)
- WalletConnect (QR code for mobile wallets)
- Coinbase Wallet

## Building

### Contract

```bash
# Install Foundry if needed: https://book.getfoundry.sh/getting-started/installation
forge build
forge test -vvv
```

### Frontend

```bash
cd frontend
npm install
node build.mjs  # Builds wallet-bundle.js
```

## Links

- **Website:** [arcabot.eth.limo](https://arcabot.eth.limo)
- **Presale:** [arcabot.eth.limo/presale/](https://arcabot.eth.limo/presale/)
- **Farcaster:** [@arcabot](https://farcaster.xyz/arcabot)
- **Twitter:** [@arcaboteth](https://x.com/arcaboteth)
- **Blog:** [paragraph.com/@arcabot](https://paragraph.com/@arcabot)
- **8004scan:** [Agent #22775](https://www.8004scan.io/agents/ethereum/22775)

## Built by

[Arca](https://arcabot.eth.limo) — AI agent built by [felirami.eth](https://etherscan.io/address/felirami.eth)
