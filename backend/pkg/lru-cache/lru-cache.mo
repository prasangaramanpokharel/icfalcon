import Map "mo:core/Map";
import Text "mo:core/Text";
import Int "mo:core/Int";
import Nat "mo:core/Nat";
import Time "mo:core/Time";

module {
  public type CacheEntry<V> = {
    value : V;
    lastAccessed : Int;
    expiresAt : ?Int;
  };

  public class LruCache<V>(capacityLimit : Nat) {
    private let map = Map.empty<Text, CacheEntry<V>>();
    private let capacity : Nat = if (capacityLimit == 0) 1 else capacityLimit;

    public func size() : Nat {
      Map.size(map);
    };

    public func get(key : Text) : ?V {
      let now = Time.now();
      switch (Map.get(map, Text.compare, key)) {
        case (null) null;
        case (?entry) {
          switch (entry.expiresAt) {
            case (?exp) {
              if (now >= exp) {
                Map.remove(map, Text.compare, key);
                null;
              } else {
                Map.add(map, Text.compare, key, { entry with lastAccessed = now });
                ?entry.value;
              };
            };
            case (null) {
              Map.add(map, Text.compare, key, { entry with lastAccessed = now });
              ?entry.value;
            };
          };
        };
      };
    };

    private func evictOldest() : () {
      var oldestKey : ?Text = null;
      var oldestTime : Int = Time.now() + 1_000_000_000;
      for ((k, entry) in Map.entries(map)) {
        if (entry.lastAccessed < oldestTime) {
          oldestTime := entry.lastAccessed;
          oldestKey := ?k;
        };
      };
      switch (oldestKey) {
        case (null) ();
        case (?k) { Map.remove(map, Text.compare, k); };
      };
    };

    public func set(key : Text, value : V, ttlNanos : ?Int) : () {
      let now = Time.now();
      let expiresAt = switch (ttlNanos) {
        case (null) null;
        case (?ttl) ?(now + ttl);
      };
      let isNew = switch (Map.get(map, Text.compare, key)) {
        case (null) true;
        case (?_) false;
      };
      if (Map.size(map) >= capacity and isNew) {
        evictOldest();
      };
      Map.add(map, Text.compare, key, { value; lastAccessed = now; expiresAt });
    };

    public func delete(key : Text) : () {
      Map.remove(map, Text.compare, key);
    };

    public func clear() : () {
      for ((k, _) in Map.entries(map)) {
        Map.remove(map, Text.compare, k);
      };
    };
  };
};
