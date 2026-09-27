import Text "mo:core/Text";
import Nat "mo:core/Nat";
import Iter "mo:core/Iter";

module {
  public type Algorithm = {
    #argon2id;
    #pbkdf2_sha256;
    #bcrypt;
  };

  public type HashRecord = {
    algorithm : Algorithm;
    iterations : Nat;
    salt : Text;
    hash : Text;
  };

  public func formatRecord(record : HashRecord) : Text {
    let algStr = switch (record.algorithm) {
      case (#argon2id) "argon2id";
      case (#pbkdf2_sha256) "pbkdf2-sha256";
      case (#bcrypt) "bcrypt";
    };
    "$" # algStr # "$" # Nat.toText(record.iterations) # "$" # record.salt # "$" # record.hash;
  };

  public func parseRecord(formatted : Text) : ?HashRecord {
    let parts = Iter.toArray(Text.split(formatted, #char '$'));
    if (parts.size() < 5) {
      null;
    } else {
      let algOpt = switch (parts[1]) {
        case ("argon2id") ?#argon2id;
        case ("pbkdf2-sha256") ?#pbkdf2_sha256;
        case ("bcrypt") ?#bcrypt;
        case (_) null;
      };
      switch (algOpt) {
        case (null) null;
        case (?algorithm) {
          switch (Nat.fromText(parts[2])) {
            case (null) null;
            case (?iterations) {
              ?{
                algorithm;
                iterations;
                salt = parts[3];
                hash = parts[4];
              };
            };
          };
        };
      };
    };
  };

  public func verifyTimingSafe(a : Text, b : Text) : Bool {
    let aChars = Iter.toArray(Text.toIter(a));
    let bChars = Iter.toArray(Text.toIter(b));
    let aLen = aChars.size();
    let bLen = bChars.size();
    
    var diff : Nat = if (aLen == bLen) 0 else 1;
    let minLen = if (aLen < bLen) aLen else bLen;
    var i : Nat = 0;
    while (i < minLen) {
      if (aChars[i] != bChars[i]) {
        diff += 1;
      };
      i += 1;
    };
    diff == 0;
  };
};
