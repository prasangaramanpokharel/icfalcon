export const canisterId = process.env.NEXT_PUBLIC_CANISTER_ID ?? "uxrrr-q7777-77774-qaaaq-cai"
export const host = process.env.NEXT_PUBLIC_IC_HOST ?? "http://127.0.0.1:4943"
export const iiUrl = process.env.NEXT_PUBLIC_II_URL ?? "https://identity.ic0.app"

export function getHost(): string {
  return host
}

export function getIdentityProvider(): string {
  return iiUrl
}

export function getDerivationOrigin(): string | undefined {
  if (typeof window === "undefined") return undefined
  return process.env.NEXT_PUBLIC_DERIVATION_ORIGIN || undefined
}

