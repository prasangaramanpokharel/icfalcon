import Text "mo:core/Text";
import VarArray "mo:core/VarArray";
import Nat "mo:core/Nat";
import Nat32 "mo:core/Nat32";
import Bool "mo:core/Bool";
import Char "mo:core/Char";

module {
  public class BloomFilter(numBits : Nat) {
    private let m : Nat = if (numBits == 0) 1024 else numBits;
    private let bits : [var Bool] = VarArray.repeat<Bool>(false, m);
    private var itemCount : Nat = 0;

    // Hash 1: djb2
    private func hashDjb2(key : Text) : Nat {
      var h : Nat32 = 5381;
      for (c in Text.toIter(key)) {
        let code = Char.toNat32(c);
        h := (h * 33) + code;
      };
      Nat32.toNat(h) % m;
    };

    // Hash 2: sdbm
    private func hashSdbm(key : Text) : Nat {
      var h : Nat32 = 0;
      for (c in Text.toIter(key)) {
        let code = Char.toNat32(c);
        h := code + (h * 65599);
      };
      Nat32.toNat(h) % m;
    };

    // Hash 3: fnv-like
    private func hashFnv(key : Text) : Nat {
      var h : Nat32 = 2166136261;
      for (c in Text.toIter(key)) {
        let code = Char.toNat32(c);
        h := (h ^ code) * 16777619;
      };
      Nat32.toNat(h) % m;
    };

    public func add(key : Text) : () {
      let h1 = hashDjb2(key);
      let h2 = hashSdbm(key);
      let h3 = hashFnv(key);
      bits[h1] := true;
      bits[h2] := true;
      bits[h3] := true;
      itemCount += 1;
    };

    public func contains(key : Text) : Bool {
      let h1 = hashDjb2(key);
      let h2 = hashSdbm(key);
      let h3 = hashFnv(key);
      bits[h1] and bits[h2] and bits[h3];
    };

    public func count() : Nat {
      itemCount;
    };

    public func clear() : () {
      var i : Nat = 0;
      while (i < m) {
        bits[i] := false;
        i += 1;
      };
      itemCount := 0;
    };
  };
};
