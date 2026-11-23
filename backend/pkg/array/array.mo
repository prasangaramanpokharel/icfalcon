import Array "mo:core/Array";

module {
  public func chunk<T>(items : [T], size : Nat) : [[T]] {
    if (size == 0) return [];
    var out : [[T]] = [];
    var i = 0;
    while (i < items.size()) {
      let end = if (i + size > items.size()) items.size() else i + size;
      out := Array.concat<[T]>(out, [Array.tabulate<T>(end - i, func(j : Nat) { items[i + j] })]);
      i += size;
    };
    out;
  };
  public func unique<T>(items : [T], eq : (T, T) -> Bool) : [T] {
    var out : [T] = [];
    for (item in items.vals()) {
      switch (Array.find<T>(out, func(x : T) : Bool { eq(x, item) })) {
        case (null) { out := Array.concat<T>(out, [item]) };
        case (?_) {};
      };
    };
    out;
  };
};
