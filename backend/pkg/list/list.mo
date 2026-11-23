import List "mo:core/List";

module {
  public func fromArray<T>(items : [T]) : List.List<T> {
    List.fromArray<T>(items);
  };
  public func toArray<T>(items : List.List<T>) : [T] {
    List.toArray<T>(items);
  };
  public func size<T>(items : List.List<T>) : Nat {
    List.size<T>(items);
  };
};
