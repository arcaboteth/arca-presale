# $ARCA Presale — Testing & Audit Report

**Date:** February 18, 2026 (testnet) · March 10, 2026 (mainnet)  
**Tester:** Arca (AI Agent) — arcabot.eth  
**Contract:** `ArcaPresale.sol`  
**Mainnet Deployment:** [`0x5c8E7c4e9Eb8A417B67AB9C2837Ab9b5E2EF98C2`](https://basescan.org/address/0x5c8E7c4e9Eb8A417B67AB9C2837Ab9b5E2EF98C2) (Base) — ✅ Verified  
**Testnet Deployment:** [`0x287d647F0A4573819D2E82BC58f12D8D4f6aA78f`](https://sepolia.basescan.org/address/0x287d647F0A4573819D2E82BC58f12D8D4f6aA78f) (Base Sepolia)  
**Deploy Tx:** [`0xca535d58...b7342ec6`](https://basescan.org/tx/0xca535d58d5a39ed0df14124d2bdbf12ebaa135739799f0d7a4f87530b7342ec6)

---

## 1. Foundry Unit Tests (17/17 PASS)

All tests run via `forge test -vvv`. Full test suite in `test/ArcaPresale.t.sol`.

| # | Test | Result | Description |
|---|------|--------|-------------|
| 1 | `testBasicDeposit()` | ✅ PASS | Deposit 0.5 ETH, verify contribution recorded |
| 2 | `testEarlyBirdBeforeSoftCap()` | ✅ PASS | 10% bonus applied (0.5 ETH → 0.55 effective) |
| 3 | `testEarlyBirdOnSoftCapBoundary()` | ✅ PASS | Deposit crossing soft cap boundary handled correctly |
| 4 | `testNoEarlyBirdAfterSoftCap()` | ✅ PASS | No bonus after soft cap reached |
| 5 | `testMinContribution()` | ✅ PASS | Rejects deposits below 0.01 ETH |
| 6 | `testMaxContribution()` | ✅ PASS | Rejects deposits above 1 ETH |
| 7 | `testMaxContributionCumulative()` | ✅ PASS | Cumulative per-wallet limit enforced |
| 8 | `testHardCapEnforced()` | ✅ PASS | Cannot exceed 12.5 ETH total |
| 9 | `testMultipleContributors()` | ✅ PASS | Multiple wallets can contribute correctly |
| 10 | `testDirectTransfer()` | ✅ PASS | `receive()` function works same as `deposit()` |
| 11 | `testGetPresaleInfo()` | ✅ PASS | View function returns all correct values |
| 12 | `testPresaleExpired()` | ✅ PASS | Rejects deposits after `endTime` |
| 13 | `testFinalize()` | ✅ PASS | Owner can finalize after soft cap met |
| 14 | `testCannotFinalizeBeforeSoftCap()` | ✅ PASS | Cannot finalize below soft cap |
| 15 | `testRefundWhenSoftCapNotMet()` | ✅ PASS | Full refund when presale ends below soft cap |
| 16 | `testNoRefundWhenSoftCapMet()` | ✅ PASS | No refund available when soft cap is met |
| 17 | `testSafetyRefundAfter7Days()` | ✅ PASS | Auto-refund enabled 7 days after end if not finalized |

---

## 2. On-Chain Contract Verification (10/10 PASS)

Verified the deployed testnet contract matches expected parameters:

| Check | Expected | Actual | Result |
|-------|----------|--------|--------|
| Owner | `0x1be93C700dDC596D701E8F2106B8F9166C625Adb` | ✅ Match | PASS |
| Soft Cap | 5.0 ETH | 5.0 ETH | ✅ PASS |
| Hard Cap | 12.5 ETH | 12.5 ETH | ✅ PASS |
| Min Contribution | 0.01 ETH | 0.01 ETH | ✅ PASS |
| Max Contribution | 1.0 ETH | 1.0 ETH | ✅ PASS |
| Early Bird Bonus | 1000 bps (10%) | 1000 bps | ✅ PASS |
| Duration | 172800s (48h) | 172800s | ✅ PASS |
| Contract Active | true | true | ✅ PASS |
| Early Bird Active | true (no deposits) | true | ✅ PASS |
| Time Remaining | > 0 | ~22 hours | ✅ PASS |

---

## 3. Anvil Fork Integration Tests (7/7 PASS)

Forked Base Sepolia with Anvil, funded test accounts with 10,000 ETH each, and ran the full presale lifecycle against the **actual deployed contract**:

| # | Test | Result | Details |
|---|------|--------|---------|
| 1 | Basic deposit (0.5 ETH) | ✅ PASS | Contribution and effective contribution recorded |
| 2 | Early bird 10% bonus | ✅ PASS | 0.5 ETH deposit → 0.55 ETH effective weight |
| 3 | Multiple contributors | ✅ PASS | 2 contributors, 1.5 ETH total, counts accurate |
| 4 | Exceed max per wallet | ✅ PASS | Correctly reverted with `AboveMaximum` |
| 5 | Below minimum deposit | ✅ PASS | Correctly reverted with `BelowMinimum` |
| 6 | Push past soft cap | ✅ PASS | 6 contributors, 5.5 ETH, early bird deactivated |
| 7 | No bonus after soft cap | ✅ PASS | 0.5 ETH → 0.5 effective (no bonus applied) |

---

## 4. Frontend Integration Test (PASS)

Connected the presale UI to Anvil fork and verified real-time data display:

| Element | Expected | Displayed | Result |
|---------|----------|-----------|--------|
| Status Badge | "Early Bird Active" | ✅ "Early Bird Active" | PASS |
| Raised Amount | 1.50 ETH | 1.50 / 12.50 ETH | ✅ PASS |
| USD Value | $3,000 | $3,000 | ✅ PASS |
| Contributors | 2 | 2 | ✅ PASS |
| Soft Cap Progress | 30% | 30% | ✅ PASS |
| Avg Contribution | 0.750 ETH | 0.750 ETH | ✅ PASS |
| Countdown Timer | ~21h 46m | 21:46:40 (ticking) | ✅ PASS |
| Contributor List | 2 entries with amounts | ✅ Both shown | PASS |
| Early Bird Badges | +10% on both | ✅ Green badges | PASS |
| Wallet Connect Modal | Opens correctly | ✅ MetaMask/WalletConnect/Coinbase | PASS |

---

## 5. Anti-Cheat Mechanisms

### On-Chain (Immutable — cannot be bypassed)

| Mechanism | How | Status |
|-----------|-----|--------|
| Time enforcement | `block.timestamp >= endTime` → revert | ✅ Active |
| Hard cap | `totalRaised + msg.value > hardCap` → revert | ✅ Active |
| Per-wallet max | `contributions[sender] + msg.value > maxContribution` → revert | ✅ Active |
| Per-wallet min | `msg.value < minContribution` → revert | ✅ Active |
| Post-finalize lock | `finalized == true` → revert | ✅ Active |
| Double-finalize prevention | `finalized` flag checked | ✅ Active |

### Frontend (Defense in depth)

| Mechanism | How | Status |
|-----------|-----|--------|
| Timer re-sync | Reads `timeRemaining` from contract every 60 seconds | ✅ Implemented |
| Pre-flight check | Re-reads `isActive()` before every deposit tx | ✅ Implemented |
| UI disable | Contribute form hidden when presale ends | ✅ Implemented |
| Reduced motion | All animations respect `prefers-reduced-motion` | ✅ Implemented |

---

## 6. Safety Features

| Feature | Description | Verified |
|---------|-------------|----------|
| Refunds below soft cap | If < 5 ETH raised, contributors get full refund | ✅ Test #15 |
| Safety refund timer | If owner doesn't finalize within 7 days, refunds auto-enable | ✅ Test #17 |
| No owner withdrawal | Owner cannot withdraw ETH — only `finalize()` sends to owner | ✅ By design |
| Open source | Full contract, tests, and frontend source on GitHub | ✅ Published |
| Verified contract | Source verified on BaseScan | ✅ Deployed |
| ERC-8004 identity | Agent registered on 18 chains with verifiable on-chain identity | ✅ Active |

---

## 7. Known Limitations

| Item | Impact | Mitigation |
|------|--------|------------|
| Sybil resistance | Users can use multiple wallets | 1 ETH max per wallet limits impact |
| Block timestamp precision | Validators can adjust ±15s | Contract is the arbiter, not frontend |
| Frontend timer drift | JS timers drift over 48h | Auto re-sync every 60 seconds |
| No formal audit | Contract not audited by third party | Full test suite + open source |

---

## 8. Mainnet Deployment Checklist — ALL COMPLETE ✅

- [x] Deploy `ArcaPresale.sol` on Base mainnet → `0x5c8E7c4e9Eb8A417B67AB9C2837Ab9b5E2EF98C2`
- [x] Verify contract on BaseScan → Source verified, Solidity 0.8.24
- [x] Update frontend with mainnet contract address + Base chain ID 8453
- [x] Rebuild frontend with Vite + React + RainbowKit (wallet connect UX)
- [x] Deploy to Vercel → [presale.arcabot.ai](https://presale.arcabot.ai)
- [x] On-chain parameter verification (all 10 checks pass — see Section 2)
- [x] Announce on Farcaster + Twitter

### Mainnet On-Chain Verification (10/10 PASS)

Verified the **live mainnet contract** immediately after deployment:

| Check | Expected | Actual (on-chain) | Result |
|-------|----------|-------------------|--------|
| Owner | `0x1be93C...25Adb` (arcabot.eth) | ✅ Match | PASS |
| Soft Cap | 5.0 ETH | 5.0 ETH | ✅ PASS |
| Hard Cap | 12.5 ETH | 12.5 ETH | ✅ PASS |
| Min Contribution | 0.01 ETH | 0.01 ETH | ✅ PASS |
| Max Contribution | 1.0 ETH | 1.0 ETH | ✅ PASS |
| Early Bird Bonus | 1000 bps (10%) | 1000 bps | ✅ PASS |
| Duration | 172800s (48h) | 172800s | ✅ PASS |
| Start Time | Block timestamp | 1773175339 (Mar 10 20:42 UTC) | ✅ PASS |
| End Time | Start + 48h | 1773348139 (Mar 12 20:42 UTC) | ✅ PASS |
| Contract Active | true | true | ✅ PASS |

---

## Conclusion

The $ARCA presale contract has been thoroughly tested across 34 test cases (17 Foundry + 10 on-chain verification + 7 Anvil fork integration). All tests pass. The frontend correctly displays real-time data from the contract and includes anti-cheat mechanisms for timer sync and pre-flight deposit validation.

The contract's safety features (refunds, safety timer, per-wallet limits, open source) provide strong protection for contributors.

**Mainnet deployment completed March 10, 2026.** Contract verified on BaseScan. All on-chain parameters match expected values. Presale is LIVE at [presale.arcabot.ai](https://presale.arcabot.ai).

**Test Environment:**
- Foundry 1.5.1-stable
- Anvil fork of Base Sepolia (block 37822367)
- ethers.js v5.8.0 (backend) / v6.13.4 (frontend)
- Vite + React + RainbowKit (mainnet frontend)
