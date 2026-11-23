import Nat "mo:core/Nat";
import Int "mo:core/Int";
import Text "mo:core/Text";
import Time "mo:core/Time";
import Queue "mo:core/Queue";

module {
  public type JobStatus = {
    #pending;
    #processing;
    #completed;
    #failed : Text;
  };

  public type Job<Payload> = {
    id : Nat;
    payload : Payload;
    var status : JobStatus;
    var attempts : Nat;
    maxRetries : Nat;
    createdAt : Int;
    var nextRunAt : Int;
  };

  public class JobQueue<Payload>() {
    private var nextJobId : Nat = 1;
    private let jobs = Queue.empty<Job<Payload>>();

    public func enqueue(payload : Payload, maxRetries : Nat, delayNanos : Int) : Nat {
      let id = nextJobId;
      nextJobId += 1;
      let now = Time.now();
      let job : Job<Payload> = {
        id;
        payload;
        var status = #pending;
        var attempts = 0;
        maxRetries;
        createdAt = now;
        var nextRunAt = now + delayNanos;
      };
      Queue.pushBack(jobs, job);
      id;
    };

    public func poll() : ?Job<Payload> {
      let now = Time.now();
      for (job in Queue.toArray(jobs).values()) {
        switch (job.status) {
          case (#pending) {
            if (job.nextRunAt <= now) {
              job.status := #processing;
              return ?job;
            };
          };
          case (_) {};
        };
      };
      null;
    };

    public func complete(id : Nat) : Bool {
      updateStatus(id, #completed);
    };

    public func fail(id : Nat, reason : Text, backoffNanos : Int) : Bool {
      for (job in Queue.toArray(jobs).values()) {
        if (job.id == id) {
          job.attempts += 1;
          if (job.attempts >= job.maxRetries) {
            job.status := #failed(reason);
          } else {
            job.status := #pending;
            job.nextRunAt := Time.now() + backoffNanos;
          };
          return true;
        };
      };
      false;
    };

    private func updateStatus(id : Nat, newStatus : JobStatus) : Bool {
      for (job in Queue.toArray(jobs).values()) {
        if (job.id == id) {
          job.status := newStatus;
          return true;
        };
      };
      false;
    };

    public func size() : Nat {
      Queue.size(jobs);
    };

    public func clear() : () {
      Queue.clear(jobs);
    };
  };
};
