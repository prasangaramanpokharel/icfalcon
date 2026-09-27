import Text "mo:core/Text";
import Queue "mo:core/Queue";
import Result "mo:core/Result";
import Bool "mo:core/Bool";

module {
  public type Transition<S, E> = {
    fromState : S;
    event : E;
    toState : S;
    guard : ?((S, E) -> Bool);
  };

  public class StateMachine<S, E>(
    initialState : S,
    stateEqual : (S, S) -> Bool,
    eventEqual : (E, E) -> Bool
  ) {
    private var state : S = initialState;
    private let transitions = Queue.empty<Transition<S, E>>();

    public func currentState() : S {
      state;
    };

    public func addTransition(fromState : S, event : E, toState : S, guardOpt : ?((S, E) -> Bool)) : () {
      Queue.pushBack(transitions, {
        fromState;
        event;
        toState;
        guard = guardOpt;
      });
    };

    public func can(event : E) : Bool {
      for (t in Queue.toArray(transitions).values()) {
        if (stateEqual(t.fromState, state) and eventEqual(t.event, event)) {
          let allowed = switch (t.guard) {
            case (null) true;
            case (?g) g(state, event);
          };
          if (allowed) {
            return true;
          };
        };
      };
      false;
    };

    public func trigger(event : E) : Result.Result<S, Text> {
      for (t in Queue.toArray(transitions).values()) {
        if (stateEqual(t.fromState, state) and eventEqual(t.event, event)) {
          let allowed = switch (t.guard) {
            case (null) true;
            case (?g) g(state, event);
          };
          if (allowed) {
            state := t.toState;
            return #ok(state);
          } else {
            return #err("Transition guard rejected event");
          };
        };
      };
      #err("No valid transition for current state and event");
    };

    public func reset(newState : S) : () {
      state := newState;
    };
  };
};
