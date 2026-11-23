"use client"

import {
  createContext,
  useContext,
  useEffect,
  useState,
  useCallback,
  useMemo,
  type ReactNode,
} from "react"
import type { Identity } from "@icp-sdk/core/agent"
import {
  login as iiLogin,
  logout as iiLogout,
  createAuthClient,
  openBackendSession,
  discardRejectedSession,
  resumeRedirectSignIn,
  type LoginOptions,
} from "@/services/auth/auth"
import { playLoginChime } from "@/lib/ui/successChime"

export type AuthContextType = {
  identity: Identity | undefined
  principal: string
  isAuthenticated: boolean
  isLoading: boolean
  ready: boolean
  login: (options?: LoginOptions | unknown) => Promise<void>
  acceptIdentity: (identity: Identity) => Promise<void>
  logout: () => Promise<void>
}

const SOUND_KEY = "icpay:login-sound:"

function playLoginChimeOnce(principal: string) {
  if (typeof window === "undefined") return
  const key = SOUND_KEY + principal
  if (localStorage.getItem(key)) return
  localStorage.setItem(key, "1")
  playLoginChime()
}

const AuthContext = createContext<AuthContextType>({
  identity: undefined,
  principal: "",
  isAuthenticated: false,
  isLoading: true,
  ready: false,
  login: async () => {},
  acceptIdentity: async () => {},
  logout: async () => {},
})

export function AuthProvider({ children }: { children: ReactNode }) {
  const [identity, setIdentity] = useState<Identity | undefined>(undefined)
  const [isLoading, setIsLoading] = useState(true)

  useEffect(() => {
    async function init() {
      try {
        // 1. Check if returning from a mobile redirect sign-in flow
        const redirectedIdentity = await resumeRedirectSignIn()
        if (redirectedIdentity) {
          try {
            await openBackendSession(redirectedIdentity)
            setIdentity(redirectedIdentity)
            playLoginChimeOnce(redirectedIdentity.getPrincipal().toText())
            return
          } catch {
            await discardRejectedSession()
          }
        }

        // 2. Standard session check
        const authClient = await createAuthClient()
        if (!authClient.isAuthenticated()) return
        const id = await authClient.getIdentity()

        try {
          await openBackendSession(id)
          setIdentity(id)
        } catch {
          await discardRejectedSession()
        }
      } catch (e) {
        console.error("Auth init error:", e)
      } finally {
        setIsLoading(false)
      }
    }
    init()
  }, [])

  const acceptIdentity = useCallback(async (id: Identity) => {
    try {
      await openBackendSession(id)
    } catch (e) {
      console.error("Backend login error:", e)
    }
    playLoginChimeOnce(id.getPrincipal().toText())
    setIdentity(id)
  }, [])

  const login = useCallback(
    async (options?: LoginOptions | unknown) => {
      const opts =
        options &&
        typeof options === "object" &&
        ("openIdProvider" in options || "transport" in options)
          ? (options as LoginOptions)
          : undefined
      const id = await iiLogin(opts)
      if (!id) return
      await acceptIdentity(id)
    },
    [acceptIdentity],
  )

  const logout = useCallback(async () => {
    await iiLogout()
    setIdentity(undefined)
  }, [])

  const principal = useMemo(() => {
    return identity && !identity.getPrincipal().isAnonymous()
      ? identity.getPrincipal().toText()
      : ""
  }, [identity])

  return (
    <AuthContext.Provider
      value={{
        identity,
        principal,
        isAuthenticated: !!identity && !identity.getPrincipal().isAnonymous(),
        isLoading,
        ready: !isLoading,
        login,
        acceptIdentity,
        logout,
      }}
    >
      {children}
    </AuthContext.Provider>
  )
}

export const useAuth = () => {
  const context = useContext(AuthContext)
  if (!context) {
    throw new Error("useAuth must be used inside AuthProvider")
  }
  return context
}
