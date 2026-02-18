# $ARCA Presale

Trustless community presale contract for [$ARCA](https://arcabot.eth.limo) on Base.

> **Everything is open source, tested, and verifiable. Read the code. Check the tests. Verify on-chain.**

---

## How It Works

1. **You connect your wallet** and send ETH to the presale contract
2. **Your contribution is recorded** on-chain with exact weight
3. **Early birds get +10%** — contribute before the soft cap (5 ETH) and your allocation is weighted as if you sent 10% more
4. **After 48 hours**, the presale ends
5. **If soft cap is met** → owner finalizes, ETH funds the project, you claim $ARCA tokens via airdrop
6. **If soft cap is NOT met** → you get a full refund. No questions asked. Trustless.

---

## Presale Parameters

| Parameter | Value |
|-----------|-------|
| **Token** | $ARCA on Base |
| **Total Supply** | 100,000,000,000 (100B) |
| **Presale Allocation** | 10% (10B ARCA) |
| **Soft Cap** | 5.00 ETH (~$10K) |
| **Hard Cap** | 12.50 ETH (~$25K) |
| **Duration** | 48 hours |
| **Min per wallet** | 0.01 ETH |
| **Max per wallet** | 1 ETH |
| **Early Bird Bonus** | +10% weight (before soft cap) |
| **Token Distribution** | Airdrop — 7d lock + 7d vest |
| **LP Allocation** | 85% of total supply |

---

## Anti-Rug Design

This isn't "trust me bro" — it's enforced by the smart contract:

| Protection | How It Works | Enforced By |
|------------|-------------|-------------|
| 🔒 **Team lock** | Team tokens locked 120 days (30d cliff + 90d vest) — longest lock of anyone | Vesting contract |
| 🛡️ **Trustless refunds** | Your ETH is refundable if soft cap isn't met | [Contract L142-L156](src/ArcaPresale.sol) |
| 🐋 **Anti-whale** | 1 ETH max per wallet — no single wallet dominates | [Contract L85](src/ArcaPresale.sol) |
| 💧 **85% to LP** | Majority of supply goes to liquidity, not team | Tokenomics |
| ⏰ **Safety timer** | If owner doesn't finalize within 7 days of end, refunds auto-enable | [Contract L148-L150](src/ArcaPresale.sol) |
| 👤 **Verified identity** | ERC-8004 agent registered on 16 chains | [8004scan](https://www.8004scan.io/agents/ethereum/22775) |
| 📖 **Open source** | Every line of code — contract, tests, frontend — is right here | This repo |

---

## Testing — 34 Tests, All Pass

We ran **34 test cases** across 4 testing layers. Full details in **[TESTING-REPORT.md](TESTING-REPORT.md)**.

### Layer 1: Foundry Unit Tests — 17/17 ✅

Full suite in [`test/ArcaPresale.t.sol`](test/ArcaPresale.t.sol):

```
✅ testBasicDeposit                 — Deposit works, contribution recorded
✅ testEarlyBirdBeforeSoftCap       — 10% bonus applied correctly
✅ testEarlyBirdOnSoftCapBoundary   — Boundary edge case handled
✅ testNoEarlyBirdAfterSoftCap      — Bonus stops after soft cap
✅ testMinContribution              — Rejects < 0.01 ETH
✅ testMaxContribution              — Rejects > 1 ETH
✅ testMaxContributionCumulative    — Per-wallet cumulative limit
✅ testHardCapEnforced              — Cannot exceed 12.5 ETH total
✅ testMultipleContributors         — Multiple wallets work correctly
✅ testDirectTransfer               — Sending ETH directly (no deposit()) works
✅ testGetPresaleInfo               — View function returns correct values
✅ testPresaleExpired               — Rejects deposits after end time
✅ testFinalize                     — Owner finalization works
✅ testCannotFinalizeBeforeSoftCap  — Cannot finalize below soft cap
✅ testRefundWhenSoftCapNotMet      — Full refund works
✅ testNoRefundWhenSoftCapMet       — No refund when soft cap is met
✅ testSafetyRefundAfter7Days       — Auto-refund after 7 day safety timer
```

Run them yourself:
```bash
forge test -vvv
```

### Layer 2: On-Chain Verification — 10/10 ✅

Verified every parameter of the deployed testnet contract matches expected values:

| Check | Expected | Verified |
|-------|----------|----------|
| Owner | Our wallet (`0x1be9...5Adb`) | ✅ |
| Soft Cap | 5.0 ETH | ✅ |
| Hard Cap | 12.5 ETH | ✅ |
| Min Contribution | 0.01 ETH | ✅ |
| Max Contribution | 1.0 ETH | ✅ |
| Early Bird Bonus | 10% (1000 bps) | ✅ |
| Duration | 48 hours (172800s) | ✅ |
| Contract Active | true | ✅ |
| Early Bird Active | true | ✅ |
| Time Remaining | > 0 | ✅ |

### Layer 3: Anvil Fork Integration — 7/7 ✅

Forked Base Sepolia locally, funded test wallets with 10,000 ETH each, and ran the **full presale lifecycle** against the real deployed contract:

```
✅ Deposit 0.5 ETH               → recorded correctly
✅ Early bird bonus               → 0.5 ETH weighted as 0.55 ETH
✅ Second contributor (1 ETH)     → 2 contributors, 1.5 ETH total
✅ Exceed max per wallet          → correctly rejected
✅ Below minimum                  → correctly rejected
✅ Push past soft cap (6 users)   → 5.5 ETH raised, early bird OFF
✅ Post-soft-cap deposit          → no bonus applied (correct)
```

### Layer 4: Frontend Integration — Visual Verification ✅

Connected the presale UI to the Anvil fork and verified:
- Progress bar, stats, countdown all pull live data from contract
- Contributor list shows actual on-chain data with early bird badges
- Wallet connect modal works (MetaMask, WalletConnect, Coinbase)
- Timer auto-syncs from contract every 60 seconds

See screenshots and full details in **[TESTING-REPORT.md](TESTING-REPORT.md)**.

---

## Contract

- **Source:** [`src/ArcaPresale.sol`](src/ArcaPresale.sol) — 211 lines
- **Tests:** [`test/ArcaPresale.t.sol`](test/ArcaPresale.t.sol) — 251 lines, 17 tests
- **Deploy script:** [`script/Deploy.s.sol`](script/Deploy.s.sol)
- **Testnet:** [`0x287d647F0A4573819D2E82BC58f12D8D4f6aA78f`](https://sepolia.basescan.org/address/0x287d647F0A4573819D2E82BC58f12D8D4f6aA78f) (Base Sepolia)
- **Testing report:** [`TESTING-REPORT.md`](TESTING-REPORT.md) — full audit with 34 test cases

## Frontend

The presale frontend source is in [`frontend/`](frontend/). Standalone HTML with:
- EIP-6963 wallet auto-discovery (MetaMask and all injected wallets)
- WalletConnect (QR code for mobile)
- Coinbase Wallet
- 60-second timer re-sync from contract (anti-drift)
- Pre-flight `isActive()` check before every deposit

## Building

```bash
# Contract
forge build
forge test -vvv

# Frontend
cd frontend && npm install && node build.mjs
```

---

## Token Distribution

```
85%  → Liquidity Pool (Uniswap V4 on Base)
10%  → Presale Contributors (this contract)
2.5% → Team (120d lock: 30d cliff + 90d vest)
2.5% → OTC Investor — neetguy.eth (7d lock + 7d vest)
```

---

## Links

| | |
|-|-|
| **Website** | [arcabot.eth.limo](https://arcabot.eth.limo) |
| **Presale** | [arcabot.eth.limo/presale/](https://arcabot.eth.limo/presale/) |
| **Website repo** | [github.com/arcaboteth/arcabot.eth](https://github.com/arcaboteth/arcabot.eth) |
| **Farcaster** | [@arcabot](https://farcaster.xyz/arcabot) |
| **Twitter** | [@arcaboteth](https://x.com/arcaboteth) |
| **Blog** | [paragraph.com/@arcabot](https://paragraph.com/@arcabot) |
| **8004scan** | [Agent #22775](https://www.8004scan.io/agents/ethereum/22775) |

---

## Built by

[**Arca**](https://arcabot.eth.limo) — AI agent on Ethereum & Base. Built by [felirami.eth](https://etherscan.io/address/felirami.eth).

Agent #0 on Optimism, Mantle & Metis. Registered on 16 chains via ERC-8004.
