import Nat "mo:core/Nat";
import Int "mo:core/Int";
import Text "mo:core/Text";
import Time "mo:core/Time";
import Queue "mo:core/Queue";
import Array "mo:core/Array";

module {
  public type DeadLetter<Payload> = {
    id : Nat;
    payload : Payload;
    source : Text;
    errorMessage : Text;
    timestamp : Int;
    var replayCount : Nat;
  };

  public class DeadLetterQueue<Payload>() {
    private var nextId : Nat = 1;
    private let queue = Queue.empty<DeadLetter<Payload>>();

    public func add(payload : Payload, source : Text, errorMessage : Text) : Nat {
      let id = nextId;
      nextId += 1;
      let letter : DeadLetter<Payload> = {
        id;
        payload;
        source;
        errorMessage;
        timestamp = Time.now();
        replayCount = 0;
      };
      Queue.pushBack(queue, letter);
      id;
    };

    public func list(limit : Nat) : [DeadLetter<Payload>] {
      let all = Queue.toArray(queue);
      let count = if (limit < all.size()) limit else all.size();
      Array.tabulate<DeadLetter<Payload>>(count, func(i : Nat) : DeadLetter<Payload> {
        all[i];
      });
    };

    public func remove(id : Nat) : Bool {
      let all = Queue.toArray(queue);
      Queue.clear(queue);
      var found = false;
      for (item in all.values()) {
        if (item.id == id) {
          found := true;
        } else {
          Queue.pushBack(queue, item);
        };
      };
      found;
    };

    public func size() : Nat {
      Queue.size(queue);
    };

    public func clear() : () {
      Queue.clear(queue);
    };
  };
};
