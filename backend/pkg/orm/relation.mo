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
};
