import Nat "mo:core/Nat";
import Queue "mo:core/Queue";
import Bool "mo:core/Bool";

module {
  public type Listener<T> = {
    id : Nat;
    callback : T -> ();
    isOnce : Bool;
  };

  public class EventEmitter<T>() {
    private var nextId : Nat = 1;
    private let listeners = Queue.empty<Listener<T>>();

    public func on(callback : T -> ()) : Nat {
      let id = nextId;
      nextId += 1;
      Queue.pushBack(listeners, { id; callback; isOnce = false });
      id;
    };

    public func once(callback : T -> ()) : Nat {
      let id = nextId;
      nextId += 1;
      Queue.pushBack(listeners, { id; callback; isOnce = true });
      id;
    };

    public func off(id : Nat) : Bool {
      let arr = Queue.toArray(listeners);
      Queue.clear(listeners);
      var removed = false;
      for (l in arr.values()) {
        if (l.id == id) {
          removed := true;
        } else {
          Queue.pushBack(listeners, l);
        };
      };
      removed;
    };

    public func emit(payload : T) : () {
      let arr = Queue.toArray(listeners);
      Queue.clear(listeners);
      for (l in arr.values()) {
        l.callback(payload);
        if (not l.isOnce) {
          Queue.pushBack(listeners, l);
        };
      };
    };

    public func listenerCount() : Nat {
      Queue.size(listeners);
    };

    public func removeAll() : () {
      Queue.clear(listeners);
    };
  };
};
