import Text "mo:core/Text";
import Queue "mo:core/Queue";
import Result "mo:core/Result";
import Array "mo:core/Array";
import Nat "mo:core/Nat";

module {
  public type Step<Ctx> = {
    name : Text;
    execute : Ctx -> async* Result.Result<Ctx, Text>;
    compensate : Ctx -> async* ();
  };

  public class SagaOrchestrator<Ctx>() {
    private let steps = Queue.empty<Step<Ctx>>();

    public func addStep(step : Step<Ctx>) : () {
      Queue.pushBack(steps, step);
    };

    public func run(initialContext : Ctx) : async* Result.Result<Ctx, Text> {
      let allSteps = Queue.toArray(steps);
      let executedSteps = Queue.empty<Step<Ctx>>();
      var currentCtx = initialContext;

      for (step in allSteps.values()) {
        try {
          let stepResult = await* step.execute(currentCtx);
          switch (stepResult) {
            case (#ok(nextCtx)) {
              currentCtx := nextCtx;
              Queue.pushBack(executedSteps, step);
            };
            case (#err(reason)) {
              await* rollback(executedSteps, currentCtx);
              return #err("Saga failed at step [" # step.name # "]: " # reason);
            };
          };
        } catch (_e) {
          await* rollback(executedSteps, currentCtx);
          return #err("Saga trapped at step [" # step.name # "]");
        };
      };

      #ok(currentCtx);
    };

    private func rollback(executed : Queue.Queue<Step<Ctx>>, ctx : Ctx) : async* () {
      let arr = Queue.toArray(executed);
      var i = arr.size();
      while (i > 0) {
        i -= 1;
        let step = arr[i];
        try {
          await* step.compensate(ctx);
        } catch (_e) {
          ();
        };
      };
    };
  };
};
