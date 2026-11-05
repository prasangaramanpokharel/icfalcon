import Result "mo:core/Result";
import Text "mo:core/Text";

module {
  public type Result<Ok, Err> = Result.Result<Ok, Err>;

  public type RecordId = Text;

  public type IndexType = {
    #unique;
    #foreignKey;
    #index;
  };

  public type IndexDef<T> = {
    name : Text;
    indexType : IndexType;
    extractKey : T -> Text;
  };

  public type TableConfig<T> = {
    name : Text;
    primaryKey : T -> RecordId;
    indices : [IndexDef<T>];
  };

  public type Page<T> = {
    items : [T];
    total : Nat;
    offset : Nat;
    limit : Nat;
    hasMore : Bool;
  };
};
