---
name: evmRpcStandard
description: >-
  EVM RPC canister integration on the Internet Computer (Ethereum, Base, Arbitrum, Optimism,
  Polygon) — multi-provider consensus, reading EVM state, and submitting transactions with zero API keys.
---

# EVM RPC Standard — Multi-Chain EVM Integration

Standard for interacting with Ethereum and EVM-compatible blockchains from Motoko canisters using the Internet Computer's system **EVM RPC Canister** (`7hfb6-caaaa-aaaar-qadga-cai`).

---

## Purpose

Allow IcFalcon applications to query smart contracts, inspect ERC-20 balances, and broadcast transactions on Ethereum, Arbitrum, Base, Optimism, and Polygon directly from Motoko with consensus-validated RPC responses and without managing third-party API keys (Alchemy, Infura, etc.).

---

## When to use

- Reading ERC-20 token balances (USDC, USDT, DAI) on Ethereum, Base, Arbitrum, or Polygon
- Reading smart contract state or calling `eth_call` methods on EVM chains
- Verifying deposits or transaction confirmations on external EVM blockchains
- Broadcasting signed raw transactions (`eth_sendRawTransaction`) combined with Threshold ECDSA

---

## 1. Architecture: Multi-Provider Consensus

The EVM RPC canister runs on ICP's 34-node fiduciary subnet. Instead of trusting a single RPC endpoint, it queries multiple independent providers in parallel and evaluates their responses through 2/3 subnet consensus:

```
[ Motoko Canister ]
         │ (ic.call: eth_call)
         ▼
[ EVM RPC Canister (7hfb6-caaaa-aaaar-qadga-cai) ]
    ├──► Alchemy (HTTPS outcall)
    ├──► Infura (HTTPS outcall)
    ├──► Cloudflare (HTTPS outcall)
    └──► BlockPi (HTTPS outcall)
         │ (Subnet 2/3 Consensus Evaluation)
         ▼
[ Consensus Response: Consistent | Inconsistent ]
```

---

## 2. EVM RPC Interface

The mainnet canister ID for EVM RPC is `7hfb6-caaaa-aaaar-qadga-cai`.

```motoko
// Candid types for EVM RPC integration
module {
  public type RpcServices = {
    #EthSepolia : ?[RpcService];
    #EthMainnet : ?[RpcService];
    #BaseMainnet : ?[RpcService];
    #ArbitrumOne : ?[RpcService];
    #OptimismMainnet : ?[RpcService];
    #Custom : { url : Text; headers : ?[(Text, Text)] };
  };

  public type RpcService = {
    #Alchemy;
    #BlockPi;
    #Cloudflare;
    #PublicNode;
    #Ankr;
  };

  public type MultiRpcResult<T> = {
    #Consistent : Result<T, RpcError>;
    #Inconsistent : [(RpcService, Result<T, RpcError>)];
  };

  public type RpcError = {
    #JsonRpcError : { code : Int64; message : Text };
    #ProviderError : Text;
    #ValidationError : Text;
    #HttpOutcallError : { code : Nat32; message : Text };
  };
};
```

---

## 3. Implementation Pattern: Reading ERC-20 Balance

```motoko
import EvmTypes "pkg/evm/types";

actor {
  let evmCanisterId = Principal.fromText("7hfb6-caaaa-aaaar-qadga-cai");

  public func getBaseUsdcBalance(userEthAddress : Text) : async Result<Nat, Text> {
    // 1. Prepare ERC-20 balanceOf(address) ABI call data
    // balanceOf signature hash: 0x70a08231
    let callData = "0x70a08231000000000000000000000000" # strip0x(userEthAddress);

    // USDC contract address on Base Mainnet
    let usdcContract = "0x833589fCD6eDb6E08f4c7C32D4f71b54bdA02913";

    // 2. Query via EVM RPC canister with cycles attached for HTTPS outcalls
    let evmActor : actor {
      request : (EvmTypes.RpcServices, Text, Nat64) -> async EvmTypes.MultiRpcResult<Text>;
    } = actor(Principal.toText(evmCanisterId));

    let result = await evmActor.request(
      #BaseMainnet(null), // null uses default multi-provider quorum
      "{ ... JSON-RPC request for eth_call ... }",
      10_000_000_000 // Cycles attached for outcall execution
    );

    switch (result) {
      case (#Consistent(#ok(hexBalance))) {
        #ok(parseHexToNat(hexBalance));
      };
      case (#Consistent(#err(err))) {
        #err("RPC error: " # debug_show err);
      };
      case (#Inconsistent(_)) {
        #err("RPC providers returned conflicting responses");
      };
    };
  };
};
```

---

## 4. Rules & Safety

1. **Cycle Attachment**: Calls to the EVM RPC canister require cycle payments to cover HTTPS outcall consensus fees. Always maintain sufficient canister cycle reserves.
2. **Handle Inconsistent Quorum**: Always guard against `#Inconsistent` responses. Never execute critical financial logic if RPC providers disagree.
3. **Combine with Threshold ECDSA**: For sending transactions, generate the raw EVM signature using ICP's `sign_with_ecdsa` system API, then submit the signed blob using `eth_sendRawTransaction`.

---

## Related

| Topic | Path |
|---|---|
| Threshold Signatures | [`skills/motokoStandard/thresholdSignaturesStandard/SKILL.md`](../motokoStandard/thresholdSignaturesStandard/SKILL.md) |
| HTTP Outcalls | [`skills/motokoStandard/httpOutcallsStandard/SKILL.md`](../motokoStandard/httpOutcallsStandard/SKILL.md) |
| Cycles & Costs | [`skills/motokoStandard/cyclesAndCostStandard/SKILL.md`](../motokoStandard/cyclesAndCostStandard/SKILL.md) |
