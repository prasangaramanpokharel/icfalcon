import Int "mo:core/Int";
import Nat "mo:core/Nat";
import Text "mo:core/Text";
import Time "mo:core/Time";

module {
  public let DEFAULT_STEP_NANOS : Int = 30_000_000_000;
  public let DEFAULT_DIGITS : Nat = 6;

  public type Config = {
    stepNanos : Int;
    digits : Nat;
    driftWindows : Nat;
  };

  public func defaultConfig() : Config {
    {
      stepNanos = DEFAULT_STEP_NANOS;
      digits = DEFAULT_DIGITS;
      driftWindows = 1;
    };
  };

  public func getCounter(nowNanos : Int, stepNanos : Int) : Nat {
    if (nowNanos <= 0 or stepNanos <= 0) {
      0;
    } else {
      let n = nowNanos / stepNanos;
      Int.abs(n);
    };
  };

  public func currentCounter() : Nat {
    getCounter(Time.now(), DEFAULT_STEP_NANOS);
  };

  public func formatCode(codeInt : Nat, digits : Nat) : Text {
    let s = Nat.toText(codeInt);
    let len = Text.size(s);
    if (len >= digits) {
      s;
    } else {
      var pad = "";
      var i : Nat = 0;
      while (i + len < digits) {
        pad := pad # "0";
        i += 1;
      };
      pad # s;
    };
  };

  public func isWindowValid(counter : Nat, expectedCounter : Nat, drift : Nat) : Bool {
    let minAllowed = if (expectedCounter > drift) { expectedCounter - drift } else { 0 };
    let maxAllowed = expectedCounter + drift;
    counter >= minAllowed and counter <= maxAllowed;
  };
};
