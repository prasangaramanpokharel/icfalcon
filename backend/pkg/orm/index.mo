import Array "mo:core/Array";
import Iter "mo:core/Iter";
import Map "mo:core/Map";
import Result "mo:core/Result";
import Text "mo:core/Text";
import Types "./types";

module {
  public class IndexManager<T>(config : Types.TableConfig<T>) {
    let store = Map.empty<Text, T>();
    let uniqueIndices = Map.empty<Text, Map.Map<Text, Text>>();
    let groupIndices = Map.empty<Text, Map.Map<Text, [Text]>>();

    // Initialize secondary index containers
    for (idx in config.indices.values()) {
      switch (idx.indexType) {
        case (#unique) {
          Map.add(uniqueIndices, Text.compare, idx.name, Map.empty<Text, Text>());
        };
        case (#foreignKey or #index) {
          Map.add(groupIndices, Text.compare, idx.name, Map.empty<Text, [Text]>());
        };
      };
    };

    public func insert(record : T) : Result.Result<T, Text> {
      let id = config.primaryKey(record);

      if (Map.containsKey(store, Text.compare, id)) {
        return #err("Primary key already exists: " # id);
      };

      // Check unique constraints before mutating state
      for (idx in config.indices.values()) {
        switch (idx.indexType) {
          case (#unique) {
            let key = idx.extractKey(record);
            switch (Map.get(uniqueIndices, Text.compare, idx.name)) {
              case (?subMap) {
                if (Map.containsKey(subMap, Text.compare, key)) {
                  return #err("Unique constraint violation on index '" # idx.name # "' for key: " # key);
                };
              };
              case (null) {};
            };
          };
          case (_) {};
        };
      };

      // Insert into primary store
      Map.add(store, Text.compare, id, record);

      // Index secondary keys
      for (idx in config.indices.values()) {
        let key = idx.extractKey(record);
        switch (idx.indexType) {
          case (#unique) {
            switch (Map.get(uniqueIndices, Text.compare, idx.name)) {
              case (?subMap) {
                Map.add(subMap, Text.compare, key, id);
              };
              case (null) {};
            };
          };
          case (#foreignKey or #index) {
            switch (Map.get(groupIndices, Text.compare, idx.name)) {
              case (?subMap) {
                let existing = switch (Map.get(subMap, Text.compare, key)) {
                  case (?list) { list };
                  case (null) { [] };
                };
                Map.add(subMap, Text.compare, key, Array.concat(existing, [id]));
              };
              case (null) {};
            };
          };
        };
      };

      #ok(record);
    };

    public func insertMany(records : [T]) : Result.Result<[T], Text> {
      var insertedIds : [Text] = [];
      for (rec in records.values()) {
        switch (insert(rec)) {
          case (#ok(_)) {
            insertedIds := Array.concat(insertedIds, [config.primaryKey(rec)]);
          };
          case (#err(msg)) {
            // Roll back previously inserted records in this batch
            for (id in insertedIds.values()) {
              switch (get(id)) {
                case (?r) { ignore delete(r) };
                case (null) {};
              };
            };
            return #err("Batch insert aborted and rolled back: " # msg);
          };
        };
      };
      #ok(records);
    };

    public func exists(id : Text) : Bool {
      Map.containsKey(store, Text.compare, id);
    };

    public func get(id : Text) : ?T {
      Map.get(store, Text.compare, id);
    };

    public func getByUnique(indexName : Text, value : Text) : ?T {
      switch (Map.get(uniqueIndices, Text.compare, indexName)) {
        case (null) { null };
        case (?subMap) {
          switch (Map.get(subMap, Text.compare, value)) {
            case (null) { null };
            case (?id) { Map.get(store, Text.compare, id) };
          };
        };
      };
    };

    public func getByGroup(indexName : Text, value : Text) : [T] {
      switch (Map.get(groupIndices, Text.compare, indexName)) {
        case (null) { [] };
        case (?subMap) {
          switch (Map.get(subMap, Text.compare, value)) {
            case (null) { [] };
            case (?ids) {
              Array.filterMap<Text, T>(ids, func(id : Text) : ?T {
                Map.get(store, Text.compare, id);
              });
            };
          };
        };
      };
    };

    public func update(oldRecord : T, newRecord : T) : Result.Result<T, Text> {
      let id = config.primaryKey(oldRecord);
      let newId = config.primaryKey(newRecord);

      if (id != newId) {
        return #err("Primary key cannot be modified");
      };

      // Validate modified unique indices
      for (idx in config.indices.values()) {
        switch (idx.indexType) {
          case (#unique) {
            let oldKey = idx.extractKey(oldRecord);
            let newKey = idx.extractKey(newRecord);
            if (oldKey != newKey) {
              switch (Map.get(uniqueIndices, Text.compare, idx.name)) {
                case (?subMap) {
                  if (Map.containsKey(subMap, Text.compare, newKey)) {
                    return #err("Unique constraint violation on update for index '" # idx.name # "' for key: " # newKey);
                  };
                };
                case (null) {};
              };
            };
          };
          case (_) {};
        };
      };

      // Apply index updates
      for (idx in config.indices.values()) {
        let oldKey = idx.extractKey(oldRecord);
        let newKey = idx.extractKey(newRecord);
        if (oldKey != newKey) {
          switch (idx.indexType) {
            case (#unique) {
              switch (Map.get(uniqueIndices, Text.compare, idx.name)) {
                case (?subMap) {
                  Map.remove(subMap, Text.compare, oldKey);
                  Map.add(subMap, Text.compare, newKey, id);
                };
                case (null) {};
              };
            };
            case (#foreignKey or #index) {
              switch (Map.get(groupIndices, Text.compare, idx.name)) {
                case (?subMap) {
                  // Remove from old group
                  switch (Map.get(subMap, Text.compare, oldKey)) {
                    case (?oldList) {
                      let filtered = Array.filter<Text>(oldList, func(elem : Text) : Bool { elem != id });
                      if (filtered.size() == 0) {
                        Map.remove(subMap, Text.compare, oldKey);
                      } else {
                        Map.add(subMap, Text.compare, oldKey, filtered);
                      };
                    };
                    case (null) {};
                  };
                  // Add to new group
                  let existing = switch (Map.get(subMap, Text.compare, newKey)) {
                    case (?list) { list };
                    case (null) { [] };
                  };
                  Map.add(subMap, Text.compare, newKey, Array.concat(existing, [id]));
                };
                case (null) {};
              };
            };
          };
        };
      };

      // Update primary store
      Map.add(store, Text.compare, id, newRecord);
      #ok(newRecord);
    };

    public func delete(record : T) : Result.Result<(), Text> {
      let id = config.primaryKey(record);

      if (not Map.containsKey(store, Text.compare, id)) {
        return #err("Record not found: " # id);
      };

      Map.remove(store, Text.compare, id);

      // Clean secondary indices
      for (idx in config.indices.values()) {
        let key = idx.extractKey(record);
        switch (idx.indexType) {
          case (#unique) {
            switch (Map.get(uniqueIndices, Text.compare, idx.name)) {
              case (?subMap) {
                Map.remove(subMap, Text.compare, key);
              };
              case (null) {};
            };
          };
          case (#foreignKey or #index) {
            switch (Map.get(groupIndices, Text.compare, idx.name)) {
              case (?subMap) {
                switch (Map.get(subMap, Text.compare, key)) {
                  case (?list) {
                    let filtered = Array.filter<Text>(list, func(elem : Text) : Bool { elem != id });
                    if (filtered.size() == 0) {
                      Map.remove(subMap, Text.compare, key);
                    } else {
                      Map.add(subMap, Text.compare, key, filtered);
                    };
                  };
                  case (null) {};
                };
              };
              case (null) {};
            };
          };
        };
      };

      #ok(());
    };

    public func all() : [T] {
      Array.fromIter<T>(Map.values(store));
    };

    public func count() : Nat {
      Map.size(store);
    };
  };
};
