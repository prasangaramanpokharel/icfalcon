import { Actor, HttpAgent } from "@icp-sdk/core"
import type { Identity } from "@icp-sdk/core/agent"

export const idlFactory = ({ IDL }: { IDL: any }) => {
  const CanisterStatus = IDL.Record({
    canister: IDL.Text,
    version: IDL.Text,
    pendingOutboxCount: IDL.Nat,
  })
  const Event = IDL.Record({
    id: IDL.Text,
    topic: IDL.Text,
    source: IDL.Principal,
    timestamp: IDL.Int,
    sequence: IDL.Nat,
    payload: IDL.Text,
    correlationId: IDL.Opt(IDL.Text),
  })
  const DeliveryStatus = IDL.Variant({
    delivered: IDL.Null,
    failed: IDL.Text,
    pending: IDL.Null,
    skipped: IDL.Null,
  })
  const Receipt = IDL.Record({
    eventId: IDL.Text,
    subscriber: IDL.Principal,
    status: DeliveryStatus,
    timestamp: IDL.Int,
  })

  return IDL.Service({
    ping: IDL.Func([], [IDL.Text], ["query"]),
    status: IDL.Func([], [CanisterStatus], ["query"]),
    onUniverseEvent: IDL.Func([Event], [Receipt], []),
    emitEvent: IDL.Func([IDL.Text, IDL.Text], [Event], []),
  })
}

export function get{{Name}}CanisterId(): string {
  if (typeof process !== "undefined" && process.env?.NEXT_PUBLIC_{{UPPER}}_CANISTER_ID) {
    return process.env.NEXT_PUBLIC_{{UPPER}}_CANISTER_ID
  }
  try {
    const canisterIds = require("@/canister_ids.json")
    const isLocal = typeof window !== "undefined" && (window.location.hostname === "localhost" || window.location.hostname === "127.0.0.1")
    const net = isLocal ? "local" : "ic"
    return canisterIds["{{kebab}}"]?.[net] || ""
  } catch {
    return ""
  }
}

export function create{{Name}}Actor(identity?: Identity) {
  const canisterId = get{{Name}}CanisterId()
  const host = typeof process !== "undefined" && process.env?.NEXT_PUBLIC_IC_HOST
    ? process.env.NEXT_PUBLIC_IC_HOST
    : "http://127.0.0.1:4943"

  const agent = new HttpAgent({ host, identity })

  if (host.includes("127.0.0.1") || host.includes("localhost")) {
    agent.fetchRootKey().catch(() => {})
  }

  return Actor.createActor(idlFactory, { agent, canisterId })
}

/**
 * Offline-first ping with graceful fallback
 */
export async function ping{{Name}}Canister(): Promise<string> {
  try {
    const actor: any = create{{Name}}Actor()
    return await actor.ping()
  } catch (error) {
    console.warn("[{{Name}}Client] Canister unreachable or offline:", error)
    return "offline"
  }
}
