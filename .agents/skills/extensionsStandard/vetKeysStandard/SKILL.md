---
name: vetKeysStandard
description: >-
  Verifiably Encrypted Threshold Key Derivation (vetKeys / vetKD) on the Internet Computer
  for on-chain end-to-end user encryption, private data storage, and zero-knowledge secret sharing.
---

# vetKeys (vetKD) Standard — On-Chain Privacy & Encryption

Standard for integrating **vetKeys** (Verifiably Encrypted Threshold Key Derivation) in IcFalcon applications to enable zero-knowledge, client-encrypted data storage and privacy on the Internet Computer.

---

## Purpose

Allow IcFalcon applications to store encrypted user data (private messages, files, documents, credentials) on-chain where **only the authenticated user's client can decrypt the data**. Neither node operators nor the canister itself ever see the user's plaintext secrets.

---

## When to use

- Building private user data vaults, confidential notes, or decentralized password managers
- End-to-end encrypted messaging or user-to-user private sharing
- Encrypted file storage in object stores (`objectStorageStandard`)
- Client-side credential encryption without exposing private keys to the backend

---

## 1. Architecture: Threshold Key Derivation

```
[ User Browser Client ]
        │ 1. Generates ephemeral transport keypair (tpk, tsk)
        │ 2. Authenticates via Internet Identity (Caller Principal)
        ▼
[ Motoko Canister ]
        │ 3. Forwards request to IC Management Canister
        ▼
[ IC System Subnet (vetKD API) ]
        │ 4. Verifies caller derivation path
        │ 5. Derives symmetric key encrypted with user's transport public key (tpk)
        ▼
[ User Browser Client ]
        │ 6. Decrypts derived key using transport secret key (tsk)
        │ 7. Encrypts / Decrypts sensitive data locally with AES-GCM
```

---

## 2. Motoko Integration Pattern

Canisters interact with the system `vetkd_system_api` via asynchronous management canister calls:

```motoko
import Types "types";

module {
  public type VetkdDerivationArgs = {
    derivation_id : Blob;        // Unique user identity or resource ID
    key_id : { name : Text };    // e.g. "test_key_1" or "production_key_1"
    encryption_public_key : Blob;// Client's ephemeral transport public key
  };

  public type VetkdEncryptedKeyResult = {
    encrypted_key : Blob;
  };
};

actor {
  let managementCanister = actor("aaaaa-aa") : actor {
    vetkd_encrypted_key : (VetkdDerivationArgs) -> async VetkdEncryptedKeyResult;
    vetkd_public_key : ({ key_id : { name : Text }; derivation_path : [Blob] }) -> async { public_key : Blob };
  };

  public shared ({ caller }) func getEncryptedKeyForUser(
    transportPublicKey : Blob
  ) : async Result<Blob, Text> {
    // 1. Guard against anonymous callers
    if (Principal.isAnonymous(caller)) {
      return #err("Anonymous callers cannot request encryption keys");
    };

    // 2. Derive key bound exclusively to the authenticated caller Principal
    let callerBlob = Principal.toBlob(caller);
    let args : VetkdDerivationArgs = {
      derivation_id = callerBlob;
      key_id = { name = "test_key_1" };
      encryption_public_key = transportPublicKey;
    };

    try {
      let res = await managementCanister.vetkd_encrypted_key(args);
      #ok(res.encrypted_key);
    } catch (e) {
      #err("Failed to derive threshold key: " # Error.message(e));
    };
  };
};
```

---

## 3. Rules & Privacy Constraints

1. **Client-Side Encryption Only**: The canister must **never receive plaintext secrets**. The browser client encrypts data locally using AES-GCM or ChaCha20 before uploading, and decrypts locally after downloading.
2. **Bind to Principal**: Always include the authenticated `caller` Principal in the `derivation_id`. If `derivation_id` is user-controlled, any caller could request another user's decryption key.
3. **Never Log Key Blobs**: Do not log raw encrypted key payloads or transport public keys in debug logs.

---

## Related

| Topic | Path |
|---|---|
| Object Storage | [`skills/extensionsStandard/objectStorageStandard/SKILL.md`](../extensionsStandard/objectStorageStandard/SKILL.md) |
| Internet Identity | [`skills/motokoStandard/internetIdentityAuthStandard/SKILL.md`](../motokoStandard/internetIdentityAuthStandard/SKILL.md) |
| Authorization | [`skills/motokoStandard/authorizationStandard/SKILL.md`](../motokoStandard/authorizationStandard/SKILL.md) |
