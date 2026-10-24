import Principal "mo:core/Principal";
import Nat "mo:core/Nat";

module {
  public type CanisterStatus = {
    canister : Text;
    version : Text;
    pendingOutboxCount : Nat;
  };

  public type {{Name}}Item = {
    id : Text;
    owner : Principal;
    data : Text;
    createdAt : Int;
  };
};
