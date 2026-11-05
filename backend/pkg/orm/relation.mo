import Nat "mo:core/Nat";
import Result "mo:core/Result";
import Types "./types";
import Table "./table";

module {
  // Resolves 1-to-Many relationship (e.g., User hasMany Orders)
  public func hasMany<Parent, Child>(
    parent : Parent,
    parentKey : Parent -> Types.RecordId,
    childTable : Table.Table<Child>,
    foreignKeyIndexName : Text
  ) : [Child] {
    let pKey = parentKey(parent);
    childTable.findManyByIndex(foreignKeyIndexName, pKey);
  };

  // Resolves 1-to-1 relationship (e.g., User hasOne Profile)
  public func hasOne<Parent, Child>(
    parent : Parent,
    parentKey : Parent -> Types.RecordId,
    childTable : Table.Table<Child>,
    foreignKeyIndexName : Text
  ) : ?Child {
    let pKey = parentKey(parent);
    let children = childTable.findManyByIndex(foreignKeyIndexName, pKey);
    if (children.size() == 0) {
      null;
    } else {
      ?children[0];
    };
  };

  // Resolves Many-to-1 relationship (e.g., Order belongsTo User)
  public func belongsTo<Child, Parent>(
    child : Child,
    foreignKeyExtractor : Child -> Types.RecordId,
    parentTable : Table.Table<Parent>
  ) : ?Parent {
    let parentId = foreignKeyExtractor(child);
    parentTable.findById(parentId);
  };

  // Validates referential integrity: ensures referenced parent exists
  public func validateForeignKey<Child, Parent>(
    child : Child,
    foreignKeyExtractor : Child -> Types.RecordId,
    parentTable : Table.Table<Parent>
  ) : Result.Result<(), Text> {
    let parentId = foreignKeyExtractor(child);
    switch (parentTable.findById(parentId)) {
      case (?_) { #ok(()) };
      case (null) { #err("Foreign key constraint violation: referenced parent id '" # parentId # "' does not exist") };
    };
  };

  // Cascades delete: deletes all referencing child records, then deletes the parent
  public func deleteCascade<Parent, Child>(
    parentTable : Table.Table<Parent>,
    parentId : Types.RecordId,
    childTable : Table.Table<Child>,
    foreignKeyIndexName : Text,
    childIdExtractor : Child -> Types.RecordId
  ) : Result.Result<Nat, Text> {
    let children = childTable.findManyByIndex(foreignKeyIndexName, parentId);
    var deletedChildren : Nat = 0;
    for (child in children.values()) {
      let childId = childIdExtractor(child);
      switch (childTable.delete(childId)) {
        case (#ok(_)) { deletedChildren += 1 };
        case (#err(msg)) { return #err("Cascade delete aborted: " # msg) };
      };
    };
    switch (parentTable.delete(parentId)) {
      case (#ok(_)) { #ok(deletedChildren) };
      case (#err(msg)) { #err("Parent delete failed: " # msg) };
    };
  };

  // Restricts delete: prevents parent deletion if any child records reference it
  public func deleteRestrict<Parent, Child>(
    parentTable : Table.Table<Parent>,
    parentId : Types.RecordId,
    childTable : Table.Table<Child>,
    foreignKeyIndexName : Text
  ) : Result.Result<Parent, Text> {
    let children = childTable.findManyByIndex(foreignKeyIndexName, parentId);
    if (children.size() > 0) {
      return #err("Foreign key restriction: cannot delete parent because " # Nat.toText(children.size()) # " child records reference it");
    };
    parentTable.delete(parentId);
  };
};
