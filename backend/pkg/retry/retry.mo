import Nat "mo:core/Nat";
import Text "mo:core/Text";

module {
  public type Result<T> = { #ok : T; #err : Text };

  public func withRetry(attempts : Nat, run : () -> async Result<Text>) : async Result<Text> {
    var left = attempts;
    var last = "";
    while (left > 0) {
      switch (await run()) {
        case (#ok(v)) return #ok(v);
        case (#err(e)) { last := e; left -= 1 };
      };
    };
    #err(last);
  };

  public func retryBool(attempts : Nat, run : () -> async Bool) : async Bool {
    var left = attempts;
    while (left > 0) {
      if (await run()) return true;
      left -= 1;
    };
    false;
  };
};
