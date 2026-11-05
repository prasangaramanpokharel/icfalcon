import Principal "mo:core/Principal";
import ORM "mo:pkg/orm/orm";
import Types "../types";

module {
  public type {{Name}}Table = ORM.Table<Types.{{Name}}>;
  public type {{Name}}State = ORM.TableState<Types.{{Name}}>;

  public func create{{Name}}Config() : ORM.TableConfig<Types.{{Name}}> {
    ORM.config<Types.{{Name}}>("{{name}}s", func(item : Types.{{Name}}) : Text { item.id }, [
      ORM.index("owner", func(item : Types.{{Name}}) : Text { Principal.toText(item.owner) }),
    ]);
  };

  public func create{{Name}}Table(?optState : ?{{Name}}State) : {{Name}}Table {
    let cfg = create{{Name}}Config();
    switch (optState) {
      case (?st) { ORM.createTableFromState<Types.{{Name}}>(cfg, st) };
      case (null) { ORM.createTable<Types.{{Name}}>(cfg) };
    };
  };

  public func create{{Name}}State() : {{Name}}State {
    ORM.createState<Types.{{Name}}>();
  };
};
