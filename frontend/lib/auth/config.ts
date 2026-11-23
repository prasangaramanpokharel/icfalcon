// 8 days in nanoseconds (standard Internet Identity TTL)
export const DELEGATION_TTL = BigInt(8 * 24 * 60 * 60 * 1_000_000_000)

export const POPUP_FEATURES =
  "toolbar=0,location=0,menubar=0,width=500,height=700,left=100,top=100"

export const II_BACKEND_CANISTER_ID =
  process.env.NEXT_PUBLIC_II_CANISTER_ID ?? "rdmx6-jaaaa-aaaaa-aaadq-cai"
