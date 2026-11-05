import Result "mo:core/Result";
import Types "./types";
import Table "./table";
import Query "./query";
import Relation "./relation";
import Migration "./migration";

module {
  public let createTable = Table.Table;
  public let hasMany = Relation.hasMany;
  public let hasOne = Relation.hasOne;
  public let belongsTo = Relation.belongsTo;
  public let validateForeignKey = Relation.validateForeignKey;
  public let deleteCascade = Relation.deleteCascade;
  public let deleteRestrict = Relation.deleteRestrict;
  public let migrate = Migration.migrate;

  // Schema builder helpers for declarative 3NF modeling
  public func unique<T>(name : Text, extractKey : T -> Text) : Types.IndexDef<T> {
    { name = name; indexType = #unique; extractKey = extractKey };
  };

  public func foreignKey<T>(name : Text, extractKey : T -> Text) : Types.IndexDef<T> {
    { name = name; indexType = #foreignKey; extractKey = extractKey };
  };

  public func index<T>(name : Text, extractKey : T -> Text) : Types.IndexDef<T> {
    { name = name; indexType = #index; extractKey = extractKey };
  };

  public func config<T>(name : Text, primaryKey : T -> Types.RecordId, indices : [Types.IndexDef<T>]) : Types.TableConfig<T> {
    { name = name; primaryKey = primaryKey; indices = indices };
  };

  // Restores a table from a stable array during canister postupgrade
  public func fromArray<T>(tableConfig : Types.TableConfig<T>, records : [T]) : Result.Result<Table.Table<T>, Text> {
    let tbl = Table.Table<T>(tableConfig);
    switch (tbl.populate(records)) {
      case (#ok(_)) { #ok(tbl) };
      case (#err(msg)) { #err(msg) };
    };
  };

  public type Table<T> = Table.Table<T>;
  public type Query<T> = Query.Query<T>;
  public type Page<T> = Types.Page<T>;
  public type IndexDef<T> = Types.IndexDef<T>;
  public type TableConfig<T> = Types.TableConfig<T>;
  public type RecordId = Types.RecordId;
};
