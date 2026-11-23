import Array "mo:core/Array";
import VarArray "mo:core/VarArray";
import Types "./types";

module {
  public class Query<T>(records : [T]) {
    public func where(predicate : T -> Bool) : Query<T> {
      let filtered = Array.filter<T>(records, predicate);
      Query<T>(filtered);
    };

    public func orderBy(isLessThanOrEqual : (T, T) -> Bool) : Query<T> {
      let sorted = sortArray<T>(records, isLessThanOrEqual);
      Query<T>(sorted);
    };

    public func skip(count : Nat) : Query<T> {
      let total = records.size();
      let start = if (count > total) { total } else { count };
      let slice = Array.tabulate<T>(
        total - start,
        func(i : Nat) { records[start + i] },
      );
      Query<T>(slice);
    };

    public func take(count : Nat) : Query<T> {
      let total = records.size();
      let len = if (count > total) { total } else { count };
      let slice = Array.tabulate<T>(
        len,
        func(i : Nat) { records[i] },
      );
      Query<T>(slice);
    };

    public func paginate(offset : Nat, limit : Nat) : Types.Page<T> {
      let total = records.size();
      let start = if (offset > total) { total } else { offset };
      let end = if (start + limit > total) { total } else { start + limit };
      let slice = Array.tabulate<T>(
        end - start,
        func(i : Nat) { records[start + i] },
      );
      let hasMore = end < total;
      {
        items = slice;
        total = total;
        offset = offset;
        limit = limit;
        hasMore = hasMore;
      };
    };

    public func first() : ?T {
      if (records.size() == 0) {
        null;
      } else {
        ?records[0];
      };
    };

    public func count() : Nat {
      records.size();
    };

    public func toArray() : [T] {
      records;
    };
  };

  func sortArray<T>(arr : [T], isLessThanOrEqual : (T, T) -> Bool) : [T] {
    let n = arr.size();
    if (n <= 1) { return arr };
    let mut = Array.toVarArray<T>(arr);
    var i = 1;
    while (i < n) {
      let key = mut[i];
      var j = i;
      while (j > 0 and not isLessThanOrEqual(mut[j - 1], key)) {
        mut[j] := mut[j - 1];
        j -= 1;
      };
      mut[j] := key;
      i += 1;
    };
    VarArray.toArray<T>(mut);
  };
};
