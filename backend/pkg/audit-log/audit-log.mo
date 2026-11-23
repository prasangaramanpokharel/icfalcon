import Time "mo:core/Time";
import Text "mo:core/Text";
import Principal "mo:core/Principal";
import Array "mo:core/Array";
import Queue "mo:core/Queue";
import Int "mo:core/Int";
import Nat "mo:core/Nat";

module {
  public type Status = {
    #success;
    #failure : Text;
  };

  public type Entry = {
    id : Nat;
    timestamp : Int;
    operator : Principal;
    action : Text;
    targetResource : Text;
    targetId : ?Text;
    status : Status;
    details : Text;
  };

  public class Store() {
    private let entries = Queue.empty<Entry>();
    private var nextId : Nat = 1;

    public func log(
      operator : Principal,
      action : Text,
      targetResource : Text,
      targetId : ?Text,
      status : Status,
      details : Tex
    ) : Entry {
      let entry : Entry = {
        id = nextId;
        timestamp = Time.now();
        operator;
        action;
        targetResource;
        targetId;
        status;
        details;
      };
      nextId += 1;
      Queue.pushBack(entries, entry);
      entry;
    };

    public func size() : Nat {
      Queue.size(entries);
    };

    public func getLatest(limit : Nat) : [Entry] {
      let allEntries = Queue.toArray(entries);
      let total = allEntries.size();
      let take = if (limit < total) limit else total;
      let start = if (total > take) { total - take } else { 0 };
      Array.tabulate<Entry>(take, func(i : Nat) : Entry {
        allEntries[start + i];
      });
    };

    public func filterByOperator(op : Principal, limit : Nat) : [Entry] {
      let allEntries = Queue.toArray(entries);
      let filtered = Queue.empty<Entry>();
      for (e in allEntries.values()) {
        if (e.operator == op and Queue.size(filtered) < limit) {
          Queue.pushBack(filtered, e);
        };
      };
      Queue.toArray(filtered);
    };
  };
};
