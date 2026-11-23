import Nat "mo:core/Nat";
import Array "mo:core/Array";
import Queue "mo:core/Queue";
import Bool "mo:core/Bool";

module {
  public func chunk<T>(items : [T], chunkSize : Nat) : [[T]] {
    let size = items.size();
    if (size == 0 or chunkSize == 0) {
      [];
    } else {
      let numChunks = if (size % chunkSize == 0) (size / chunkSize) else (size / chunkSize + 1);
      Array.tabulate<[T]>(numChunks, func(chunkIdx : Nat) : [T] {
        let start = chunkIdx * chunkSize;
        let remaining = if (size > start) { size - start } else { 0 };
        let count = if (remaining < chunkSize) remaining else chunkSize;
        Array.tabulate<T>(count, func(i : Nat) : T {
          items[start + i];
        });
      });
    };
  };

  public func partition<T>(items : [T], predicate : T -> Bool) : ([T], [T]) {
    let passQueue = Queue.empty<T>();
    let failQueue = Queue.empty<T>();
    for (item in items.values()) {
      if (predicate(item)) {
        Queue.pushBack(passQueue, item);
      } else {
        Queue.pushBack(failQueue, item);
      };
    };
    (Queue.toArray(passQueue), Queue.toArray(failQueue));
  };

  public func processBatched<In, Out>(
    items : [In],
    batchSize : Nat,
    handler : [In] -> [Out]
  ) : [Out] {
    let chunks = chunk<In>(items, batchSize);
    let results = Queue.empty<Out>();
    for (c in chunks.values()) {
      let chunkOut = handler(c);
      for (outItem in chunkOut.values()) {
        Queue.pushBack(results, outItem);
      };
    };
    Queue.toArray(results);
  };
};
