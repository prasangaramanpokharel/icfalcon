import Result "mo:core/Result";
import Types "./types";
import Index "./index";
import Query "./query";

module {
  public class Table<T>(config : Types.TableConfig<T>, optState : ?Types.TableState<T>) {
    let manager = Index.IndexManager<T>(config, optState);

    public func insert(record : T) : Result.Result<T, Text> {
      manager.insert(record);
    };

    public func insertMany(records : [T]) : Result.Result<[T], Text> {
      manager.insertMany(records);
    };

    public func upsert(record : T) : Result.Result<T, Text> {
      let id = config.primaryKey(record);
      switch (manager.get(id)) {
        case (null) {
          manager.insert(record);
        };
        case (?oldRecord) {
          manager.update(oldRecord, record);
        };
      };
    };

    public func exists(id : Types.RecordId) : Bool {
      manager.exists(id);
    };

    public func findById(id : Types.RecordId) : ?T {
      manager.get(id);
    };

    public func findFirst(predicate : T -> Bool) : ?T {
      where(predicate).first();
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

    public func deleteMany(ids : [Types.RecordId]) : Result.Result<Nat, Text> {
      var deletedCount : Nat = 0;
      for (id in ids.values()) {
        switch (delete(id)) {
          case (#ok(_)) { deletedCount += 1 };
          case (#err(_)) {};
        };
      };
      #ok(deletedCount);
    };

    public func populate(records : [T]) : Result.Result<Nat, Text> {
      switch (manager.insertMany(records)) {
        case (#ok(recs)) { #ok(recs.size()) };
        case (#err(msg)) { #err(msg) };
      };
    };

    public func all() : [T] {
      manager.all();
    };

    public func count() : Nat {
      manager.count();
    };

    public func getState() : Types.TableState<T> {
      manager.getState();
    };

    public func builder() : Query.Query<T> {
      Query.Query<T>(manager.all());
    };

    public func where(predicate : T -> Bool) : Query.Query<T> {
      Query.Query<T>(manager.all()).where(predicate);
    };
  };
};
