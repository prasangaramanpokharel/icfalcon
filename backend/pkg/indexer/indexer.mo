import Map "mo:core/Map";
import Text "mo:core/Text";
import Array "mo:core/Array";

module {
  public type Index = Map.Map<Text, [Text]>;
  public func empty() : Index { Map.empty() };
  public func add(idx : Index, field : Text, value : Text, id : Text) : () {
    let current = switch (Map.get(idx, Text.compare, field # ":" # value)) {
      case (?ids) ids;
      case (null) [];
    };
    Map.add(idx, Text.compare, field # ":" # value, Array.concat<Text>(current, [id]));
  };
  public func lookup(idx : Index, field : Text, value : Text) : [Text] {
    switch (Map.get(idx, Text.compare, field # ":" # value)) {
      case (?ids) ids;
      case (null) [];
    };
  };
};
