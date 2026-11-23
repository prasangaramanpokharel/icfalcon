const REDIRECT_PENDING_KEY = "icp:auth:redirect_pending"

export function prefersRedirectTransport(): boolean {
  if (typeof window === "undefined") return false
  const userAgent = navigator.userAgent.toLowerCase()
  return /iphone|ipad|ipod|android|mobile/.test(userAgent)
}

export function markRedirectPending(): void {
  if (typeof window !== "undefined") {
    sessionStorage.setItem(REDIRECT_PENDING_KEY, "true")
  }
}

export function clearRedirectPending(): void {
  if (typeof window !== "undefined") {
    sessionStorage.removeItem(REDIRECT_PENDING_KEY)
  }
}

export function hasRedirectPending(): boolean {
  if (typeof window === "undefined") return false
  return sessionStorage.getItem(REDIRECT_PENDING_KEY) === "true"
}

export function isInternetIdentityReturn(): boolean {
  if (typeof window === "undefined") return false
  return (
    window.location.hash.includes("authorize") ||
    window.location.search.includes("authorize") ||
    window.location.hash.includes("delegation")
  )
}

export function clearInternetIdentityReturnHash(): void {
  if (typeof window !== "undefined" && window.location.hash) {
    history.replaceState(null, document.title, window.location.pathname + window.location.search)
  }
}
