import Text "mo:core/Text";
import Int "mo:core/Int";
import Time "mo:core/Time";
import Iter "mo:core/Iter";

module {
  public type Header = {
    alg : Text;
    typ : Text;
  };

  public type Claims = {
    iss : ?Text;
    sub : ?Text;
    aud : ?Text;
    exp : ?Int;
    nbf : ?Int;
    iat : ?Int;
    jti : ?Text;
  };

  public type Token = {
    header : Header;
    claims : Claims;
    signature : Text;
    raw : Text;
  };

  public func defaultHeader() : Header {
    { alg = "HS256"; typ = "JWT" };
  };

  public func emptyClaims() : Claims {
    {
      iss = null;
      sub = null;
      aud = null;
      exp = null;
      nbf = null;
      iat = null;
      jti = null;
    };
  };

  public func isExpired(claims : Claims, nowNanos : Int) : Bool {
    switch (claims.exp) {
      case (null) false;
      case (?expNanos) nowNanos >= expNanos;
    };
  };

  public func isValidNow(claims : Claims) : Bool {
    let now = Time.now();
    let expired = isExpired(claims, now);
    let notYetValid = switch (claims.nbf) {
      case (null) false;
      case (?nbfNanos) now < nbfNanos;
    };
    not expired and not notYetValid;
  };

  public func splitToken(tokenText : Text) : ?(Text, Text, Text) {
    let parts = Text.split(tokenText, #char '.');
    let arr = Iter.toArray(parts);
    if (arr.size() != 3) {
      null;
    } else {
      ?(arr[0], arr[1], arr[2]);
    };
  };

  public func makeClaims(sub : Text, ttlNanos : Int) : Claims {
    let now = Time.now();
    {
      iss = ?"icfalcon";
      sub = ?sub;
      aud = null;
      exp = ?(now + ttlNanos);
      nbf = ?now;
      iat = ?now;
      jti = null;
    };
  };
};
