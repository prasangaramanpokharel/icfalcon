import Array "mo:core/Array";
import Nat "mo:core/Nat";

module {
  public func chunk(data : [Nat8], size : Nat) : [[Nat8]] {
    if (size == 0) return [];
    var out : [[Nat8]] = [];
    var i = 0;
    while (i < data.size()) {
      let end = if (i + size > data.size()) data.size() else i + size;
      out := Array.concat<[Nat8]>(out, [Array.tabulate<Nat8>(end - i, func(j : Nat) { data[i + j] })]);
      i += size;
    };
    out;
  };
  public func join(chunks : [[Nat8]]) : [Nat8] {
    Array.flatten<Nat8>(chunks);
  };
};
