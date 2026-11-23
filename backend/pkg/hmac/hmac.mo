import Text "mo:core/Text";
import Blob "mo:core/Blob";
import Array "mo:core/Array";
import Nat8 "mo:core/Nat8";
import Nat "mo:core/Nat";
import Iter "mo:core/Iter";

module {
  public let BLOCK_SIZE : Nat = 64; // SHA-256 block size in bytes
  public let IPAD_BYTE : Nat8 = 0x36;
  public let OPAD_BYTE : Nat8 = 0x5c;

  public type HmacConfig = {
    algorithm : Text;
    key : Blob;
  };

  public func timingSafeEqual(a : Text, b : Text) : Bool {
    let aChars = Iter.toArray(Text.toIter(a));
    let bChars = Iter.toArray(Text.toIter(b));
    let aSize = aChars.size();
    let bSize = bChars.size();

    var diff : Nat = if (aSize == bSize) 0 else 1;
    let minLen = if (aSize < bSize) aSize else bSize;
    var i : Nat = 0;
    while (i < minLen) {
      if (aChars[i] != bChars[i]) {
        diff += 1;
      };
      i += 1;
    };
    diff == 0;
  };

  public func padKey(keyBytes : [Nat8]) : [Nat8] {
    let keyLen = keyBytes.size();
    if (keyLen >= BLOCK_SIZE) {
      keyBytes;
    } else {
      Array.tabulate<Nat8>(BLOCK_SIZE, func(i : Nat) : Nat8 {
        if (i < keyLen) keyBytes[i] else 0x00;
      });
    };
  };

  public func computeIpad(paddedKey : [Nat8]) : [Nat8] {
    Array.tabulate<Nat8>(BLOCK_SIZE, func(i : Nat) : Nat8 {
      paddedKey[i] ^ IPAD_BYTE;
    });
  };

  public func computeOpad(paddedKey : [Nat8]) : [Nat8] {
    Array.tabulate<Nat8>(BLOCK_SIZE, func(i : Nat) : Nat8 {
      paddedKey[i] ^ OPAD_BYTE;
    });
  };
};
