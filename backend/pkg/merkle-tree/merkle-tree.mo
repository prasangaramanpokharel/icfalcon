import Text "mo:core/Text";
import Array "mo:core/Array";
import Nat "mo:core/Nat";

module {
  public type ProofStep = {
    sibling : Text;
    isLeft : Bool;
  };

  public type Proof = [ProofStep];

  // Deterministic parent node combiner (sorts pairs to prevent second pre-image attacks)
  public func combineHashes(left : Text, right : Text) : Text {
    if (Text.compare(left, right) == #less) {
      "H(" # left # "+" # right # ")";
    } else {
      "H(" # right # "+" # left # ")";
    };
  };

  public func computeRoot(leaves : [Text]) : Text {
    let count = leaves.size();
    if (count == 0) {
      "";
    } else if (count == 1) {
      leaves[0];
    } else {
      var currentLevel = leaves;
      while (currentLevel.size() > 1) {
        let levelSize = currentLevel.size();
        let nextSize = (levelSize + 1) / 2;
        currentLevel := Array.tabulate<Text>(nextSize, func(i : Nat) : Text {
          let leftIdx = i * 2;
          let rightIdx = leftIdx + 1;
          let left = currentLevel[leftIdx];
          let right = if (rightIdx < levelSize) currentLevel[rightIdx] else left;
          combineHashes(left, right);
        });
      };
      currentLevel[0];
    };
  };

  public func verifyProof(leaf : Text, proof : Proof, expectedRoot : Text) : Bool {
    var current = leaf;
    for (step in proof.values()) {
      current := if (step.isLeft) {
        combineHashes(step.sibling, current);
      } else {
        combineHashes(current, step.sibling);
      };
    };
    current == expectedRoot;
  };
};
