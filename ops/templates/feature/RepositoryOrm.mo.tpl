import Principal "mo:core/Principal";
import Types "../types";
import {{Name}}Storage "../storage/{{Name}}Storage";

module {
  public func getById(table : {{Name}}Storage.{{Name}}Table, id : Text) : ?Types.{{Name}} {
    table.findById(id);
  };

  public func save(table : {{Name}}Storage.{{Name}}Table, item : Types.{{Name}}) : () {
    ignore table.upsert(item);
  };

  public func remove(table : {{Name}}Storage.{{Name}}Table, id : Text) : () {
    ignore table.delete(id);
  };

  public func list(table : {{Name}}Storage.{{Name}}Table) : [Types.{{Name}}] {
    table.all();
  };

  public func count(table : {{Name}}Storage.{{Name}}Table) : Nat {
    table.count();
  };

  public func listByOwner(table : {{Name}}Storage.{{Name}}Table, owner : Principal) : [Types.{{Name}}] {
    table.findManyByIndex("owner", Principal.toText(owner));
  };
};
