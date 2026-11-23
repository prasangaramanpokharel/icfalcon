import Nat "mo:core/Nat";
import Text "mo:core/Text";
import Array "mo:core/Array";

module {
  public type Part = { index : Nat; data : [Nat8] };
  public type Upload = { id : Text; parts : [Part]; complete : Bool };
  public func addPart(u : Upload, part : Part) : Upload {
    { u with parts = Array.concat<Part>(u.parts, [part]) };
  };
  public func markComplete(u : Upload) : Upload { { u with complete = true } };
};
