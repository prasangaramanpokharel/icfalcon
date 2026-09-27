import Array "mo:core/Array";
import VarArray "mo:core/VarArray";
import Nat "mo:core/Nat";
import Bool "mo:core/Bool";

module {
  public class RingBuffer<T>(capLimit : Nat, defaultVal : T) {
    private let capacity : Nat = if (capLimit == 0) 1 else capLimit;
    private let buffer : [var T] = VarArray.repeat<T>(defaultVal, capacity);
    private var head : Nat = 0; // insertion point
    private var count : Nat = 0;

    public func size() : Nat {
      count;
    };

    public func isFull() : Bool {
      count == capacity;
    };

    public func isEmpty() : Bool {
      count == 0;
    };

    public func push(item : T) : () {
      buffer[head] := item;
      head := (head + 1) % capacity;
      if (count < capacity) {
        count += 1;
      };
    };

    private func getTail() : Nat {
      (head + capacity - (count % capacity)) % capacity;
    };

    public func peekOldest() : ?T {
      if (count == 0) {
        null;
      } else {
        ?buffer[getTail()];
      };
    };

    public func popOldest() : ?T {
      if (count == 0) {
        null;
      } else {
        let item = buffer[getTail()];
        count -= 1;
        ?item;
      };
    };

    public func toArray() : [T] {
      if (count == 0) {
        [];
      } else {
        let tail = getTail();
        Array.tabulate<T>(count, func(i : Nat) : T {
          let idx = (tail + i) % capacity;
          buffer[idx];
        });
      };
    };

    public func clear() : () {
      head := 0;
      count := 0;
    };
  };
};
