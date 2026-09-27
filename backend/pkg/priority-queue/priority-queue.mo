import CorePQ "mo:core/PriorityQueue";
import Int "mo:core/Int";
import Order "mo:core/Order";
import Nat "mo:core/Nat";
import Bool "mo:core/Bool";

module {
  public type Item<T> = {
    priority : Int;
    payload : T;
  };

  private func compareMax<T>(a : Item<T>, b : Item<T>) : Order.Order {
    Int.compare(a.priority, b.priority);
  };

  private func compareMin<T>(a : Item<T>, b : Item<T>) : Order.Order {
    switch (Int.compare(a.priority, b.priority)) {
      case (#less) #greater;
      case (#greater) #less;
      case (#equal) #equal;
    };
  };

  public class PriorityQueue<T>(isMaxHeap : Bool) {
    private let pq = CorePQ.empty<Item<T>>();
    private func compareFunc(a : Item<T>, b : Item<T>) : Order.Order {
      if (isMaxHeap) { compareMax<T>(a, b) } else { compareMin<T>(a, b) };
    };

    public func push(priority : Int, payload : T) : () {
      CorePQ.push(pq, compareFunc, { priority; payload });
    };

    public func pop() : ?T {
      switch (CorePQ.pop(pq, compareFunc)) {
        case (null) null;
        case (?item) ?item.payload;
      };
    };

    public func peek() : ?T {
      switch (CorePQ.peek(pq)) {
        case (null) null;
        case (?item) ?item.payload;
      };
    };

    public func size() : Nat {
      CorePQ.size(pq);
    };

    public func isEmpty() : Bool {
      CorePQ.isEmpty(pq);
    };

    public func clear() : () {
      CorePQ.clear(pq);
    };
  };

  public func makeMaxHeap<T>() : PriorityQueue<T> {
    PriorityQueue<T>(true);
  };

  public func makeMinHeap<T>() : PriorityQueue<T> {
    PriorityQueue<T>(false);
  };
};
