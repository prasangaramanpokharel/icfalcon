import Result "mo:core/Result";
import Types "./types";
import Index "./index";
import Query "./query";

module {
  public class Table<T>(config : Types.TableConfig<T>) {
    let manager = Index.IndexManager<T>(config);

    public func insert(record : T) : Result.Result<T, Text> {
      manager.insert(record);
    };

    public func findById(id : Types.RecordId) : ?T {
      manager.get(id);
    };

    public func findOneByIndex(indexName : Text, value : Text) : ?T {
      manager.getByUnique(indexName, value);
    };

    public func findManyByIndex(indexName : Text, value : Text) : [T] {
      manager.getByGroup(indexName, value);
    };

    public func update(id : Types.RecordId, updater : T -> T) : Result.Result<T, Text> {
      switch (manager.get(id)) {
        case (null) { #err("Record not found with id: " # id) };
        case (?oldRecord) {
          let updated = updater(oldRecord);
          manager.update(oldRecord, updated);
        };
      };
    };

    public func delete(id : Types.RecordId) : Result.Result<T, Text> {
      switch (manager.get(id)) {
        case (null) { #err("Record not found with id: " # id) };
        case (?record) {
          switch (manager.delete(record)) {
            case (#ok(())) { #ok(record) };
            case (#err(msg)) { #err(msg) };
          };
        };
      };
    };

    public func all() : [T] {
      manager.all();
    };

    public func count() : Nat {
      manager.count();
    };

    public func builder() : Query.Query<T> {
      Query.Query<T>(manager.all());
    };

    public func where(predicate : T -> Bool) : Query.Query<T> {
      Query.Query<T>(manager.all()).where(predicate);
    };
  };
};
