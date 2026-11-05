---
name: cycleCostStandard
description: "Official Internet Computer cycle cost reference and economic model mapped from docs.internetcomputer.org/references/cycle-costs/ — XDR pegging, computation, storage, Xnet calls, HTTPS outcalls, and threshold cryptography."
---

# Cycle Cost Standard (`cycleCostStandard`)

Authoritative reference for resource execution, storage, and networking costs on the Internet Computer (ICP), mapped directly from the official [ICP Cycle Costs Reference](https://internetcomputer.org/docs/references/cycle-costs/).

---

## Purpose

Cycles represent the fundamental unit of compute, storage, and networking on the Internet Computer. Canisters operate on a "reverse-gas" model where developers pre-fund canisters with cycles. This standard provides the exact cost equations, subnet multipliers, and architectural guidelines to prevent canister freezing and optimize economic efficiency.

---

## When to use

- Calculating execution costs for update calls vs queries
- Budgeting storage costs for heap, stable memory, and on-chain snapshots
- Attaching cycles to HTTPS outcalls or threshold signing (`sign_with_ecdsa`, `sign_with_schnorr`)
- Planning runway, compute allocation, and freezing thresholds
- Sizing inter-canister message calls across micro-canisters in Falcon Universe

---

## 1. The Cycle Economic Model: XDR Pegging

Cycles are pegged to the **IMF SDR (Special Drawing Right / XDR)** to guarantee stable, predictable hosting costs regardless of market volatility:

$$\mathbf{1\text{ Trillion Cycles (1T / }10^{12}\text{)} = 1\text{ XDR} \approx \$1.37\text{ USD}}$$

| Cycle Amount | XDR Value | Approx. USD (at 1 XDR = $1.37) |
|---|---|---|
| **$1\text{ Trillion (1T / }10^{12}\text{)}$** | 1.000 XDR | ~$1.37 |
| **$1\text{ Billion (1B / }10^9\text{)}$** | 0.001 XDR | ~$0.00137 (0.137¢) |
| **$1\text{ Million (1M / }10^6\text{)}$** | 0.000001 XDR | ~$0.00000137 |

---

## 2. Subnet Scaling: 13-Node vs 34-Node Subnets

Costs scale proportionally with subnet replication factor $n$:

$$\text{Subnet Cost Multiplier} = \frac{n}{13}$$

- **Application Subnets ($n = 13$ nodes)**: Baseline rate ($1\times$). Where standard dapps and canisters reside.
- **Fiduciary & System Subnets ($n = 34$ nodes)**: $34 / 13 \approx \mathbf{2.615\times}$ baseline rate. Hosts Bitcoin/EVM threshold signing, NNS, and governance canisters.

---

## 3. Master Cycle Cost Table

| Resource / Operation | Who Pays | 13-Node Cycles | ~USD (13-Node) | 34-Node Cycles | ~USD (34-Node) |
|---|---|---|---|---|---|
| **Query Call** (Single-node read) | N/A | **FREE (0)** | **$0.00** | **FREE (0)** | **$0.00** |
| **Composite Query** (Multi-canister read) | N/A | **FREE (0)** | **$0.00** | **FREE (0)** | **$0.00** |
| **Canister Creation** | Created Canister | 500,000,000,000 (500B) | ~$0.683 | 1,307,692,307,692 | ~$1.787 |
| **Update Execution Base Fee** | Target Canister | 5,000,000 (5M) | ~$0.0000068 | 13,076,923 | ~$0.0000179 |
| **1 Billion Instructions Executed** | Executing Canister | 1,000,000,000 (1B) | ~$0.00137 | 2,615,384,615 | ~$0.00357 |
| **Xnet Call (Request + Response Base)** | Sending Canister | 260,000 | ~$0.00000036 | 680,000 | ~$0.00000093 |
| **Xnet Byte Transmission** (per byte) | Sending Canister | 1,000 | ~$0.00000000137 | 2,615 | ~$0.0000000036 |
| **Ingress Reception Base** | Target Canister | 1,200,000 | ~$0.0000016 | 3,138,461 | ~$0.0000043 |
| **Ingress Byte Reception** (per byte) | Target Canister | 2,000 | ~$0.0000000027 | 5,230 | ~$0.0000000071 |
| **Storage per GiB per Second** | Canister | 127,000 | ~$0.000000174 | 332,153 | ~$0.000000454 |
| **Storage per GiB per Year** | Canister | **~4.005 Trillion (4T)** | **~$5.50 / year** | **~10.47 Trillion** | **~$14.38 / year** |
| **Compute Allocation** (per % / sec) | Canister | 10,000,000 | ~$0.0000137 | 26,153,846 | ~$0.0000357 |

> [!NOTE]
> On a standard 13-node subnet, **1 Wasm instruction = exactly 1 cycle**.

---

## 4. HTTPS Outcalls Pricing

HTTPS outcalls require attaching cycles upfront with call options (`@cycles(...)`):

### Version 2: Pay-As-You-Go (Recommended / Modern)
Charges only for the actual bytes returned:
$$\text{total\_fee} = (\text{base\_fee} + \text{usage\_fee} + \text{delivery\_fee}) \times \text{rpc\_providers}$$

### Version 1: Reservation-Based (Legacy)
$$\text{base\_fee} = (3\_000\_000 + 60\_000 \times n) \times n$$
- 13-Node Subnet: **49,140,000 cycles** base fee
- 34-Node Subnet: **171,360,000 cycles** base fee
- Size Fee: $(400 \times \text{request\_bytes} + 800 \times \text{max\_response\_bytes}) \times n$
  - 13-Node: 5,200 cycles / request byte, 10,400 cycles / reserved response byte.

```motoko
// Motoko HTTPS outcall with attached cycle budget
let cyclesToAttach = 50_000_000 + (10_400 * maxResponseBytes);
let response = await (managementCanister.http_request(request))(@cycles(cyclesToAttach));
```

---

## 5. Threshold Cryptography (Chain-Key ECDSA & Schnorr)

Used for native multi-chain signing (Bitcoin, Ethereum, Solana):

| Call | Subnet | Cycles Cost | Purpose |
|---|---|---|---|
| `ecdsa_public_key` | Any | **FREE (0)** | Derive public key & address |
| `schnorr_public_key` | Any | **FREE (0)** | Derive Solana / Taproot address |
| `sign_with_ecdsa` (Test key) | 13-Node | 10,000,000,000 (10B / ~$0.0137) | Testnet EVM / Bitcoin sign |
| `sign_with_ecdsa` (Production key) | 34-Node | **26,153,846,153 (~26.15B / ~$0.0357)** | Mainnet EVM / Bitcoin sign |
| `sign_with_schnorr` (Production key) | 34-Node | **26,153,846,153 (~26.15B / ~$0.0357)** | Mainnet Solana / Taproot sign |

Unused attached cycles are automatically refunded to the caller canister upon completion.

---

## 6. On-Chain Snapshots & State Storage

- **Snapshot Storage Rate**: Charged at the identical storage fee of **127,000 cycles/GiB/second** (~$5.50/GiB/year).
- **Snapshot Creation Cost**: Charged as standard update execution + Wasm instruction memory chunking fees.
- **Rule**: Retain only necessary snapshots (e.g. latest 2-3) to minimize idle storage burn:
  ```bash
  falcon c:sn:list
  ```

---

## 7. Runway & Freezing Invariant

Canisters do not stop at zero balance; they freeze when reaching the **Freezing Threshold**:

$$\text{Freezing Reserve} = \text{idle\_cycles\_per\_day} \times \text{threshold\_days}$$
$$\text{Usable Runway} = \frac{\text{Current Balance} - \text{Freezing Reserve}}{\text{Daily Idle Burn} + (\text{Daily Updates} \times \text{Average Cost})}$$

Check operational runway and balance via the CLI:
```bash
falcon cycles:balance
# or fast alias:
falcon y:bal
```

---

## Related

| Skill | Path |
|---|---|
| Cycles & Benchmarking | [`motokoStandard/cyclesAndCostStandard/SKILL.md`](../motokoStandard/cyclesAndCostStandard/SKILL.md) |
| HTTP Outcalls | [`motokoStandard/httpOutcallsStandard/SKILL.md`](../motokoStandard/httpOutcallsStandard/SKILL.md) |
| Threshold Signatures | [`motokoStandard/thresholdSignaturesStandard/SKILL.md`](../motokoStandard/thresholdSignaturesStandard/SKILL.md) |
| Multi-Canister Mesh | [`falconUniverseStandard/SKILL.md`](../falconUniverseStandard/SKILL.md) |
| CLI Commands | [`commandStandard/SKILL.md`](../commandStandard/SKILL.md) |
