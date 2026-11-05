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
  public let migrate = Migration.migrate;

  public type Table<T> = Table.Table<T>;
  public type Query<T> = Query.Query<T>;
  public type Page<T> = Types.Page<T>;
  public type IndexDef<T> = Types.IndexDef<T>;
  public type TableConfig<T> = Types.TableConfig<T>;
  public type RecordId = Types.RecordId;
};
