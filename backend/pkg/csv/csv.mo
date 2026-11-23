import Text "mo:core/Text";
import Iter "mo:core/Iter";

module {
  public func joinRow(fields : [Text]) : Text {
    Text.join(fields.vals(), ",");
  };
  public func splitRow(row : Text) : [Text] {
    Iter.toArray<Text>(Text.split(row, #char ','));
  };
};
