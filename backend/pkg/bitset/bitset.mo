import Nat64 "mo:core/Nat64";
import Nat "mo:core/Nat";
import VarArray "mo:core/VarArray";
import Bool "mo:core/Bool";

module {
  public class BitSet(initialCapacityBits : Nat) {
    private let numWords : Nat = if (initialCapacityBits == 0) 1 else ((initialCapacityBits + 63) / 64);
    private let words : [var Nat64] = VarArray.repeat<Nat64>(0, numWords);

    public func set(bitIndex : Nat) : () {
      let wordIdx = bitIndex / 64;
      if (wordIdx < words.size()) {
        let bitInWord : Nat = bitIndex % 64;
        let mask = (1 : Nat64) << Nat.toNat64(bitInWord);
        words[wordIdx] := words[wordIdx] | mask;
      };
    };

    public func clear(bitIndex : Nat) : () {
      let wordIdx = bitIndex / 64;
      if (wordIdx < words.size()) {
        let bitInWord : Nat = bitIndex % 64;
        let mask = ^((1 : Nat64) << Nat.toNat64(bitInWord));
        words[wordIdx] := words[wordIdx] & mask;
      };
    };

    public func test(bitIndex : Nat) : Bool {
      let wordIdx = bitIndex / 64;
      if (wordIdx >= words.size()) {
        false;
      } else {
        let bitInWord : Nat = bitIndex % 64;
        let mask = (1 : Nat64) << Nat.toNat64(bitInWord);
        (words[wordIdx] & mask) != 0;
      };
    };

    public func toggle(bitIndex : Nat) : () {
      let wordIdx = bitIndex / 64;
      if (wordIdx < words.size()) {
        let bitInWord : Nat = bitIndex % 64;
        let mask = (1 : Nat64) << Nat.toNat64(bitInWord);
        words[wordIdx] := words[wordIdx] ^ mask;
      };
    };

    public func count() : Nat {
      var total : Nat = 0;
      for (w in words.values()) {
        var val = w;
        while (val > 0) {
          total += Nat64.toNat(val & 1);
          val := val >> 1;
        };
      };
      total;
    };

    public func clearAll() : () {
      var i : Nat = 0;
      while (i < words.size()) {
        words[i] := 0;
        i += 1;
      };
    };
  };
};
