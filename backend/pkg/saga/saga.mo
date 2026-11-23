import Text "mo:core/Text";
import Queue "mo:core/Queue";
import Result "mo:core/Result";
import Nat "mo:core/Nat";

module {
  public type Context = Text;

  public type Step = {
    name : Text;
    execute : Context -> async Result.Result<Context, Text>;
    compensate : Context -> async ();
  };

  public class SagaOrchestrator() {
    private let steps = Queue.empty<Step>();

    public func addStep(step : Step) : () {
      Queue.pushBack(steps, step);
    };

    public func run(initialContext : Context) : async Result.Result<Context, Text> {
      let allSteps = Queue.toArray(steps);
      let executedSteps = Queue.empty<Step>();
      var currentCtx = initialContext;

      for (step in allSteps.values()) {
        try {
          let stepResult = await step.execute(currentCtx);
          switch (stepResult) {
            case (#ok(nextCtx)) {
              currentCtx := nextCtx;
              Queue.pushBack(executedSteps, step);
            };
            case (#err(reason)) {
              await rollback(executedSteps, currentCtx);
              return #err("Saga failed at step [" # step.name # "]: " # reason);
            };
          };
        } catch (_e) {
          await rollback(executedSteps, currentCtx);
          return #err("Saga trapped at step [" # step.name # "]");
        };
      };

      #ok(currentCtx);
    };

    private func rollback(executed : Queue.Queue<Step>, ctx : Context) : async () {
      let arr = Queue.toArray(executed);
      var i = arr.size();
      while (i > 0) {
        i -= 1;
        try {
          await arr[i].compensate(ctx);
        } catch (_) {};
      };
    };

    public func size() : Nat {
      Queue.size(steps);
    };

    public func clear() : () {
      Queue.clear(steps);
    };
  };
};
