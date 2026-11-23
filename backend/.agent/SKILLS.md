# Backend Agent Skills

Router for work under `backend/`. Master ICP architecture standard: [`skills/internetComputer/SKILL.md`](skills/internetComputer/SKILL.md).

---

## Task → Skill

| Task | Skill / Reference |
|---|---|
| **Internet Computer Master Guide** | [`skills/internetComputer/SKILL.md`](skills/internetComputer/SKILL.md) |
| **Motoko Language Specification** | [`skills/internetComputer/assets/languages/motoko/index.md`](skills/internetComputer/assets/languages/motoko/index.md) |
| **Developer Tools (`icp-cli`, `moc`, `ic-wasm`)** | [`skills/internetComputer/assets/developer-tools/index.md`](skills/internetComputer/assets/developer-tools/index.md) |
| **Canister Security Guardrails** | [`skills/internetComputer/references/canisterSecurityGuardrails.md`](skills/internetComputer/references/canisterSecurityGuardrails.md) |
| **Motoko Canister Patterns** | [`skills/internetComputer/references/motokoCanisterPatterns.md`](skills/internetComputer/references/motokoCanisterPatterns.md) |
| **PocketIC Deterministic Testing** | [`skills/internetComputer/references/pocketicTestingStrategies.md`](skills/internetComputer/references/pocketicTestingStrategies.md) |
| **Chain Fusion (ckBTC, EVM, Solana)** | [`skills/internetComputer/references/chainFusionArchitecture.md`](skills/internetComputer/references/chainFusionArchitecture.md) |
| **Orthogonal Persistence & Memory** | [`skills/internetComputer/references/stableMemoryAndPersistence.md`](skills/internetComputer/references/stableMemoryAndPersistence.md) |
| **Candid Interface Design** | [`skills/internetComputer/references/candidInterfaceDesign.md`](skills/internetComputer/references/candidInterfaceDesign.md) |

---

## Root Architecture Standards

| Standard | Scope | Path |
|---|---|---|
| **Motoko Coding Standard** | Pure `mo:core`, naming, style | [`../../.agent/skills/codingStandard/SKILL.md`](../../.agent/skills/codingStandard/SKILL.md) |
| **4-Tier Layering Standard** | `api → services → repositories → storage` | [`../../.agent/skills/layeringStandard/SKILL.md`](../../.agent/skills/layeringStandard/SKILL.md) |
| **FalconORM Standard** | 3NF models, BTreeMap secondary indices | [`../../.agent/skills/ormStandard/SKILL.md`](../../.agent/skills/ormStandard/SKILL.md) |
| **Falcon Universe Standard** | Event mesh, outbox pattern | [`../../.agent/skills/falconUniverseStandard/SKILL.md`](../../.agent/skills/falconUniverseStandard/SKILL.md) |
| **Error Handling Standard** | `ApiResult`, early exits, no trap | [`../../.agent/skills/errorHandlingStandard/SKILL.md`](../../.agent/skills/errorHandlingStandard/SKILL.md) |
| **Feature Integration** | End-to-end feature checklist | [`../../.agent/skills/integrationStandard/SKILL.md`](../../.agent/skills/integrationStandard/SKILL.md) |
| **Testing Standard** | Unit tests & upgrade tests | [`../../.agent/skills/testingStandard/SKILL.md`](../../.agent/skills/testingStandard/SKILL.md) |
| **Cycles & Costs Standard** | ICP cycle costs & economic model | [`../../.agent/skills/cycleCostStandard/SKILL.md`](../../.agent/skills/cycleCostStandard/SKILL.md) |
| **Version Standard** | Dependency versions & pairing rules | [`../../.agent/skills/versionStandard/SKILL.md`](../../.agent/skills/versionStandard/SKILL.md) |

---

## Toolchain & Commands

- **Build Canisters (Modern `icp-cli`)**: `icp build app`
- **Deploy Canisters**: `falcon b:deploy --local` / `icp deploy`
- **Audit Code & Security**: `falcon a:c:m` && `python3 backend/.agent/skills/internetComputer/scripts/auditCanisterSecurity.py --path backend/src`
- **Run Unit Tests**: `falcon b:test --local`
