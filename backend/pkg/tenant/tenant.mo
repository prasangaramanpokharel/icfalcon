import Text "mo:core/Text";
import Int "mo:core/Int";
import Nat "mo:core/Nat";
import Iter "mo:core/Iter";

module {
  public type Tenant = {
    id : Text;
    name : Text;
    createdAt : Int;
    isActive : Bool;
  };

  public func makeKey(tenantId : Text, resourceKey : Text) : Text {
    "tenant:" # tenantId # ":" # resourceKey;
  };

  public func parseKey(namespacedKey : Text) : ?(Text, Text) {
    let parts = Iter.toArray(Text.split(namespacedKey, #char ':'));
    if (parts.size() >= 3 and parts[0] == "tenant") {
      let tenantId = parts[1];
      // Remaining parts form the resource key
      var resourceKey = "";
      var i : Nat = 2;
      while (i < parts.size()) {
        resourceKey := if (i == 2) parts[i] else resourceKey # ":" # parts[i];
        i += 1;
      };
      ?(tenantId, resourceKey);
    } else {
      null;
    };
  };

  public func isValidTenantId(id : Text) : Bool {
    let len = Text.size(id);
    if (len < 3 or len > 64) {
      false;
    } else {
      // Must not contain colons or slashes
      for (c in Text.toIter(id)) {
        if (c == ':' or c == '/' or c == ' ') {
          return false;
        };
      };
      true;
    };
  };
};
