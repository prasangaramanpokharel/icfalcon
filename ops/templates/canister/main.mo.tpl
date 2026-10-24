import Principal "mo:core/Principal";
import Time "mo:core/Time";
import Int "mo:core/Int";
import Text "mo:core/Text";
import Universe "mo:pkg/universe/universe";
import Types "./types";

/**
 * {{Name}}Canister — Micro-canister partitioned via Falcon Universe mesh.
 * Provides independent cycles, decoupled upgrades, and idempotent event processing.
 */
persistent actor {{Name}}Canister {
  let selfPrincipal = Principal.fromActor({{Name}}Canister);

  // Falcon Universe Node: Pub/Sub event mesh with 1,000-event deduplication window
  let universeNode = Universe.createNode(
    selfPrincipal,
    "{{Name}}Canister",
    ["{{kebab}}.*", "{{kebab}}.created", "{{kebab}}.updated"], // Topics produced
    ["*"],                                                     // Topics consumed
    1000                                                       // Deduplication capacity
  );

  // ── Diagnostics ────────────────────────────────────────────────────────
  public query func ping() : async Text {
    "pong";
  };

  public query func status() : async Types.CanisterStatus {
    {
      canister = "{{Name}}";
      version = "0.1.0";
      pendingOutboxCount = Int.toNat(Universe.pendingEvents(universeNode).size());
    };
  };

  // ── Universe Mesh: Idempotent Event Receiver ───────────────────────────
  public shared ({ caller = _ }) func onUniverseEvent(event : Universe.Event) : async Universe.Receipt {
    // Sliding window check: safely neutralizes network retries and duplicate transmissions
    if (Universe.isProcessed(universeNode, event.id)) {
      return {
        eventId = event.id;
        subscriber = selfPrincipal;
        status = #skipped;
        timestamp = Time.now();
      };
    };

    // Mark event ID as consumed in deduplication window
    ignore Universe.consume(universeNode, event);

    // Route event by topic pattern
    switch (event.topic) {
      case ("{{kebab}}.ping") {
        ();
      };
      case (_) {
        ();
      };
    };

    {
      eventId = event.id;
      subscriber = selfPrincipal;
      status = #delivered;
      timestamp = Time.now();
    };
  };

  // ── Universe Mesh: Transactional Outbox Emitter ────────────────────────
  public shared ({ caller = _ }) func emitEvent(topic : Text, payload : Text) : async Universe.Event {
    let eventId = "{{kebab}}-evt-" # Int.toText(Time.now());
    let event = Universe.publish(
      universeNode,
      eventId,
      topic,
      payload,
      Time.now(),
      null
    );
    event;
  };
};
