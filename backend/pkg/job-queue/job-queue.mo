import Nat "mo:core/Nat";
import Int "mo:core/Int";
import Text "mo:core/Text";
import Time "mo:core/Time";
import Queue "mo:core/Queue";
import Array "mo:core/Array";

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
        status = #pending;
        attempts = 0;
        maxRetries;
        createdAt = now;
        nextRunAt = now + delayNanos;
      };
      Queue.pushBack(jobs, job);
      id;
    };

    public func poll() : ?Job<Payload> {
      let now = Time.now();
      for (job in Queue.toArray(jobs).values()) {
        switch (job.status) {
          case (#pending) {
            if (now >= job.nextRunAt) {
              job.status := #processing;
              job.attempts += 1;
              return ?job;
            };
          };
          case (_) ();
        };
      };
      null;
    };

    public func markComplete(jobId : Nat) : Bool {
      for (job in Queue.toArray(jobs).values()) {
        if (job.id == jobId) {
          job.status := #completed;
          return true;
        };
      };
      false;
    };

    public func markFailed(jobId : Nat, reason : Text, backoffBaseNanos : Int) : Bool {
      let now = Time.now();
      for (job in Queue.toArray(jobs).values()) {
        if (job.id == jobId) {
          if (job.attempts < job.maxRetries) {
            job.status := #pending;
            // Linear/exponential backoff increment
            let delay = backoffBaseNanos * Int.abs(job.attempts);
            job.nextRunAt := now + delay;
          } else {
            job.status := #failed(reason);
          };
          return true;
        };
      };
      false;
    };

    public func size() : Nat {
      Queue.size(jobs);
    };
  };
};
