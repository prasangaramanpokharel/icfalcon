import Principal "mo:core/Principal";
import Caller "mo:pkg/principal/caller";
import Id "mo:pkg/id/uuid";
import Result "mo:pkg/errors/result";
import Rbac "mo:pkg/rbac/rbac";
import TimeNow "mo:pkg/time/now";
import Types "../types";
import {{Name}}Repo "../repositories/{{Name}}Repository";
import {{Name}}Storage "../storage/{{Name}}Storage";
import {{Name}}Validator "../validators/{{Name}}Validator";
import UserRepo "../repositories/UserRepository";
import UserStorage "../storage/UserStorage";

module {
  public type {{Name}}Service = {
    table : {{Name}}Storage.{{Name}}Table;
    userStore : UserStorage.UserMap;
  };

  public func create(table : {{Name}}Storage.{{Name}}Table, userStore : UserStorage.UserMap) : {{Name}}Service {
    { table; userStore };
  };

  public func create{{Name}}(
    service : {{Name}}Service,
    caller : Principal,
    name : Text,
  ) : async Types.ApiResult<Types.{{Name}}> {
    switch (Caller.requireAuth(caller)) {
      case (?message) { return Result.err(Result.unauthorized, message) };
      case (null) {};
    };

    switch ({{Name}}Validator.validateName(name)) {
      case (?message) { return Result.err(Result.badRequest, message) };
      case (null) {};
    };

    let userRole = switch (UserRepo.getById(service.userStore, caller)) {
      case (?user) { user.role };
      case (null) { #guest };
    };

    switch (Rbac.require(userRole, #write)) {
      case (?message) { return Result.err(Result.forbidden, message) };
      case (null) {};
    };

    let item : Types.{{Name}} = {
      id = Id.fromPrincipal("{{name}}", caller);
      name = name;
      owner = caller;
      createdAt = TimeNow.now();
    };
    {{Name}}Repo.save(service.table, item);
    Result.ok(item);
  };

  public func get{{Name}}(service : {{Name}}Service, id : Text) : ?Types.{{Name}} {
    {{Name}}Repo.getById(service.table, id);
  };

  public func list{{Name}}s(
    service : {{Name}}Service,
    offset : Nat,
    limit : Nat,
  ) : Types.ApiResult<{ items : [Types.{{Name}}]; total : Nat }> {
    let page = service.table.builder().paginate(offset, limit);
    Result.ok({ items = page.items; total = page.total });
  };

  public func count(service : {{Name}}Service) : Nat {
    {{Name}}Repo.count(service.table);
  };
};
