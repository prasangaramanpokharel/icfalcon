---
name: thresholdSignaturesStandard
description: >-
  Threshold ECDSA (secp256k1) and Threshold Schnorr (BIP340 & Ed25519) on the Internet Computer
  for multi-chain signing across Bitcoin, Ethereum, Solana, and Ordinals without private keys.
---

# Threshold Signatures Standard — Multi-Chain Signing

Standard for using ICP's **Chain-Key Cryptography** (Threshold ECDSA and Threshold Schnorr) in Motoko canisters to generate public keys and sign transactions for Bitcoin, Ethereum, Solana, and Ordinals natively without private keys.

---

## Purpose

Allow IcFalcon canisters to hold funds and broadcast transactions directly on other blockchains (Ethereum, Bitcoin, Solana, Arbitrum, Base) without trusting centralized custody, centralized oracles, or external private keys.

---

## When to use

- Signing Ethereum or EVM transactions (combined with `evmRpcStandard`)
- Signing Solana transactions using native Ed25519 threshold signatures
- Minting or transferring Bitcoin Ordinals / Runes or signing Taproot transactions using BIP340 Schnorr
- Generating user-specific deposit addresses on external blockchains

---

## 1. Supported Cryptographic Schemes

| Feature | Curve / Algorithm | Target Blockchains | IC System Methods |
|---|---|---|---|
| **Threshold ECDSA** | `secp256k1` | Ethereum, EVM chains, Bitcoin (Legacy & SegWit) | `ecdsa_public_key`, `sign_with_ecdsa` |
| **Threshold Schnorr (BIP340)** | `bip340` | Bitcoin Taproot, Ordinals, Runes | `schnorr_public_key`, `sign_with_schnorr` |
| **Threshold Schnorr (Ed25519)** | `ed25519` | Solana, Near, Polkadot, Cardano | `schnorr_public_key`, `sign_with_schnorr` |

---

## 2. Motoko Implementation Pattern

Canisters call the system management canister (`aaaaa-aa`) and attach cycles to cover threshold signature generation fees:

```motoko
import Principal "mo:core/Principal";
import Blob "mo:core/Blob";
import Cycles "mo:core/Cycles";

module {
  public type SchnorrAlgorithm = { #bip340; #ed25519 };

  public type SchnorrKeyId = {
    algorithm : SchnorrAlgorithm;
    name : Text; // "key_1" on testnet or "key_1" on mainnet
  };

  public type SignWithSchnorrArgs = {
    message : Blob;              // 32-byte message hash
    derivation_path : [Blob];    // Sub-account derivation path
    key_id : SchnorrKeyId;
  };
};

actor {
  let managementCanister = actor("aaaaa-aa") : actor {
    schnorr_public_key : ({
      canister_id : ?Principal;
      derivation_path : [Blob];
      key_id : SchnorrKeyId;
    }) -> async { public_key : Blob; chain_code : Blob };

    sign_with_schnorr : (SignWithSchnorrArgs) -> async { signature : Blob };
  };

  // Derive a Solana (Ed25519) or Bitcoin Taproot (BIP340) public key for a user
  public shared ({ caller }) func getDerivedPublicKey(
    algorithm : SchnorrAlgorithm
  ) : async Result<Blob, Text> {
    if (Principal.isAnonymous(caller)) {
      return #err("Anonymous callers cannot derive keys");
    };

    let derivationPath = [Principal.toBlob(caller)];
    let keyId : SchnorrKeyId = {
      algorithm = algorithm;
      name = "key_1";
    };

    try {
      let res = await managementCanister.schnorr_public_key({
        canister_id = null;
        derivation_path = derivationPath;
        key_id = keyId;
      });
      #ok(res.public_key);
    } catch (e) {
      #err("Failed to retrieve public key: " # Error.message(e));
    };
  };

  // Sign a 32-byte transaction hash
  public shared ({ caller }) func signTransactionHash(
    messageHash : Blob,
    algorithm : SchnorrAlgorithm
  ) : async Result<Blob, Text> {
    // 1. Guard authorization
    if (Principal.isAnonymous(caller)) {
      return #err("Unauthorized caller");
    };

    // 2. Attach cycles required for threshold signature (approx 10-26 Billion cycles)
    Cycles.add<system>(25_000_000_000);

    let keyId : SchnorrKeyId = {
      algorithm = algorithm;
      name = "key_1";
    };

    let args : SignWithSchnorrArgs = {
      message = messageHash;
      derivation_path = [Principal.toBlob(caller)];
      key_id = keyId;
    };

    try {
      let res = await managementCanister.sign_with_schnorr(args);
      #ok(res.signature);
    } catch (e) {
      #err("Threshold signature failed: " # Error.message(e));
    };
  };
};
```

---

## 3. Rules & Safety Constraints

1. **Cycle Reserve**: Threshold signing calls are computationally intensive across the threshold subnet and cost ~10B to 26B cycles per signature. Always ensure your canister has adequate cycle reserves.
2. **Derivation Path Isolation**: Always include the user's authenticated `Principal` in the `derivation_path`. Never allow arbitrary derivation paths from untrusted callers.
3. **Verify Message Length**: Threshold signing expects a 32-byte message hash (e.g. SHA-256 or Keccak-256). Pre-hash messages before calling `sign_with_schnorr` or `sign_with_ecdsa`.

---

## Related

| Topic | Path |
|---|---|
| EVM RPC | [`skills/extensionsStandard/evmRpcStandard/SKILL.md`](../extensionsStandard/evmRpcStandard/SKILL.md) |
| Cycles & Costs | [`skills/motokoStandard/cyclesAndCostStandard/SKILL.md`](../motokoStandard/cyclesAndCostStandard/SKILL.md) |
| Ledger Integration | [`skills/motokoStandard/ledgerIntegrationStandard/SKILL.md`](../motokoStandard/ledgerIntegrationStandard/SKILL.md) |
