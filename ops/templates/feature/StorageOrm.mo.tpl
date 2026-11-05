import Principal "mo:core/Principal";
import ORM "mo:pkg/orm/orm";
import Types "../types";

module {
  public type {{Name}}Table = ORM.Table<Types.{{Name}}>;

  public func create{{Name}}Table() : {{Name}}Table {
    let config = ORM.config<Types.{{Name}}>("{{name}}s", func(item : Types.{{Name}}) : Text { item.id }, [
      ORM.index("owner", func(item : Types.{{Name}}) : Text { Principal.toText(item.owner) }),
    ]);
    ORM.createTable<Types.{{Name}}>(config);
  };
};
