import Result "mo:core/Result";
import Types "./types";
import Table "./table";

module {
  public func migrate<OldT, NewT>(
    oldTable : Table.Table<OldT>,
    newConfig : Types.TableConfig<NewT>,
    transformer : OldT -> NewT
  ) : Result.Result<Table.Table<NewT>, Text> {
    let newTable = Table.Table<NewT>(newConfig, null);

    for (oldRecord in oldTable.all().values()) {
      let transformed = transformer(oldRecord);
      switch (newTable.insert(transformed)) {
        case (#ok(_)) {};
        case (#err(msg)) {
          return #err("Migration aborted: " # msg);
        };
      };
    };

    #ok(newTable);
  };
};
