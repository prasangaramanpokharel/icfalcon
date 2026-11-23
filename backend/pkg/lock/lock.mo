import Time "mo:core/Time";
import Map "mo:core/Map";
import Text "mo:core/Text";
import Principal "mo:core/Principal";
import Int "mo:core/Int";

module {
  public type Lease = {
    owner : Principal;
    expiresAt : Int;
  };

  public type LockManager = Map.Map<Text, Lease>;

  public func empty() : LockManager {
    Map.empty();
  };

  public func acquire(
    locks : LockManager,
    resourceKey : Text,
    owner : Principal,
    ttlNanos : In
  ) : Bool {
    let now = Time.now();
    switch (Map.get(locks, Text.compare, resourceKey)) {
      case (?existing) {
        if (now < existing.expiresAt and existing.owner != owner) {
          false; // Locked by another owner and not yet expired
        } else {
          Map.add(locks, Text.compare, resourceKey, { owner; expiresAt = now + ttlNanos });
          true;
        };
      };
      case (null) {
        Map.add(locks, Text.compare, resourceKey, { owner; expiresAt = now + ttlNanos });
        true;
      };
    };
  };

  public func release(
    locks : LockManager,
    resourceKey : Text,
    owner : Principal
  ) : Bool {
    switch (Map.get(locks, Text.compare, resourceKey)) {
      case (null) true;
      case (?existing) {
        if (existing.owner == owner or Time.now() >= existing.expiresAt) {
          Map.remove(locks, Text.compare, resourceKey);
          true;
        } else {
          false; // Cannot release someone else's active lock
        };
      };
    };
  };

  public func isLocked(locks : LockManager, resourceKey : Text) : Bool {
    switch (Map.get(locks, Text.compare, resourceKey)) {
      case (null) false;
      case (?lease) Time.now() < lease.expiresAt;
    };
  };
};
