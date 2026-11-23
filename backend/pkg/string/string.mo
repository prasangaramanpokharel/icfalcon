import Text "mo:core/Text";
import Char "mo:core/Char";
import Iter "mo:core/Iter";

module {
  public func truncate(value : Text, max : Nat) : Text {
    if (value.size() <= max) value else {
      Text.fromIter(Iter.take<Char.Char>(value.chars(), max)) # "...";
    };
  };

  public func capitalize(value : Text) : Text {
    let cs = value.chars();
    switch (cs.next()) {
      case (null) "";
      case (?first) {
        Text.toUpper(Char.toText(first)) # Text.fromIter(cs);
      };
    };
  };
};
