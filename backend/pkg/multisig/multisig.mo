import Principal "mo:core/Principal";
import Array "mo:core/Array";

module {
  public type Proposal = { id : Nat; approvals : [Principal]; required : Nat };
  public func approve(p : Proposal, caller : Principal) : Proposal {
    switch (Array.find<Principal>(p.approvals, func(x : Principal) : Bool { Principal.equal(x, caller) })) {
      case (?_) p;
      case (null) { { p with approvals = Array.concat<Principal>(p.approvals, [caller]) } };
    };
  };
  public func isApproved(p : Proposal) : Bool { p.approvals.size() >= p.required };
};
