# $ARCA Presale — Round 1 Final Report

**Contract:** `0x5c8E7c4e9Eb8A417B67AB9C2837Ab9b5E2EF98C2` (Base mainnet, verified)  
**Duration:** March 10–12, 2026 (48 hours)  
**Status:** Ended — Soft cap not met — Refunds enabled

## Results

| Metric | Value |
|--------|-------|
| Total Raised | 2.032 ETH |
| Soft Cap | 5 ETH |
| Hard Cap | 12.5 ETH |
| Contributors | 26 |
| Soft Cap Met | ❌ No |
| Refunds | ✅ Live (automatic, on-chain) |

## Contributors

| # | Address | Contribution (ETH) | Effective (ETH) |
|---|---------|-------------------|-----------------|
| 1 | 0x6B3E...3B3e | 0.023000 | 0.025300 |
| 2 | 0xBEb8...Bd62 | 0.048000 | 0.052800 |
| 3 | 0xD521...aE00 | 0.113000 | 0.124300 |
| 4 | 0xd43F...74eF | 0.010000 | 0.011000 |
| 5 | 0xf199...681b | 0.030000 | 0.033000 |
| 6 | 0xbAba...8f73 | 0.020000 | 0.022000 |
| 7 | 0x03fF...F80C | 0.015000 | 0.016500 |
| 8 | 0x7F63...984D | 0.100000 | 0.110000 |
| 9 | 0x2602...C4E8 | 0.010000 | 0.011000 |
| 10 | 0x0Dd2...413d | 0.440000 | 0.484000 |
| 11 | 0xAe0C...8FEB | 0.100000 | 0.110000 |
| 12 | 0x193B...eB23 | 0.010000 | 0.011000 |
| 13 | 0x2273...8772 | 0.013370 | 0.014707 |
| 14 | 0x2FA0...019B | 0.200000 | 0.220000 |
| 15 | 0xFd37...0C2F | 0.210000 | 0.231000 |
| 16 | 0x7f9F...f284 | 0.020000 | 0.022000 |
| 17 | 0x568d...03FE | 0.020000 | 0.022000 |
| 18 | 0xfd05...1c5c | 0.020000 | 0.022000 |
| 19 | 0xa8e5...e528 | 0.100000 | 0.110000 |
| 20 | 0x8325...F4e2 | 0.050000 | 0.055000 |
| 21 | 0x6A97...BB29 | 0.010000 | 0.011000 |
| 22 | 0xBE53...a186 | 0.100000 | 0.110000 |
| 23 | 0x584B...59fF | 0.030000 | 0.033000 |
| 24 | 0xB3a2...Cfd1 | 0.130000 | 0.143000 |
| 25 | 0x55Af...42A4 | 0.180000 | 0.198000 |
| 26 | 0xB58c...1BF0 | 0.030000 | 0.033000 |

## How to Claim Refund

1. Visit [presale.arcabot.ai](https://presale.arcabot.ai)
2. Connect the same wallet you used to contribute
3. Click "Claim Refund"
4. Confirm the transaction — your ETH is returned in full

Refunds are enabled automatically by the smart contract since the soft cap was not met. No owner action required — it's trustless.

The `refund()` function is callable by any contributor after the presale end time when `totalRaised < softCap`.

## Next Steps

- All 26 contributor wallets will be recognized in the next presale round
- Early supporters will receive benefits for believing early
- Arca continues building — the work doesn't stop

## Contract Verification

- [BaseScan](https://basescan.org/address/0x5c8E7c4e9Eb8A417B67AB9C2837Ab9b5E2EF98C2)
- Source code: `src/ArcaPresale.sol` in this repo
- All tests passed (17/17) before deployment
