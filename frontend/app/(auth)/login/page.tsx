"use client"

import { useState } from "react"
import Image from "next/image"
import Link from "next/link"
import { useRouter } from "next/navigation"
import { useAuth } from "@/components/auth/auth-provider"
import { Card, CardContent, CardDescription, CardFooter, CardHeader, CardTitle } from "@/components/ui/card"
import { Button, buttonVariants } from "@/components/ui/button"
import { Badge } from "@/components/ui/badge"
import { ThemeToggle } from "@/components/ui/theme-toggle"
import { Meteors } from "@/components/ui/meteors"
import { cn } from "@/lib/utils"
import {
  ArrowLeft,
  Check,
  Copy,
  Fingerprint,
  Loader2,
  ShieldCheck,
  AlertCircle,
  ExternalLink,
} from "lucide-react"

export default function LoginPage() {
  const router = useRouter()
  const { principal, isAuthenticated, isLoading, login, logout } = useAuth()
  const [signingIn, setSigningIn] = useState<string | null>(null)
  const [error, setError] = useState<string | null>(null)
  const [copied, setCopied] = useState(false)

  async function handleLogin(provider?: "google" | "apple" | "microsoft") {
    setError(null)
    setSigningIn(provider || "ii")
    try {
      await login(provider ? { openIdProvider: provider } : undefined)
    } catch (err: unknown) {
      const msg = err instanceof Error ? err.message : "Failed to sign in"
      if (msg.includes("popup") || msg.includes("blocked")) {
        setError("Popup was blocked by your browser. Please allow popups or use redirect.")
      } else {
        setError(msg)
      }
    } finally {
      setSigningIn(null)
    }
  }

  async function handleRedirectLogin() {
    setError(null)
    setSigningIn("redirect")
    try {
      await login({ transport: "redirect" })
    } catch (err: unknown) {
      const msg = err instanceof Error ? err.message : "Redirect sign-in failed"
      setError(msg)
      setSigningIn(null)
    }
  }

  function copyPrincipal() {
    if (!principal) return
    navigator.clipboard.writeText(principal)
    setCopied(true)
    setTimeout(() => setCopied(false), 2000)
  }

  return (
    <main className="relative flex min-h-screen w-full flex-col justify-between overflow-hidden bg-background text-foreground p-6 sm:p-8">
      {/* Background Meteors */}
      <div className="pointer-events-none absolute inset-0 z-0 overflow-hidden">
        <Meteors number={25} minDelay={0.2} maxDelay={1.5} minDuration={2} maxDuration={8} angle={215} />
      </div>

      {/* Top Bar */}
      <header className="relative z-10 flex w-full items-center justify-between">
        <Link
          href="/"
          className={cn(
            buttonVariants({ variant: "ghost", size: "sm" }),
            "gap-2 text-muted-foreground hover:text-foreground",
          )}
        >
          <ArrowLeft className="h-4 w-4" />
          <span>Back to Home</span>
        </Link>
        <div className="flex items-center gap-2">
          <ThemeToggle />
        </div>
      </header>

      {/* Login Card */}
      <div className="relative z-10 flex flex-col items-center justify-center my-auto">
        <Card className="w-full max-w-md border-border/60 bg-card/70 backdrop-blur-xl shadow-2xl">
          <CardHeader className="text-center pb-4">
            <div className="flex justify-center mb-3">
              <div className="relative flex h-14 w-14 items-center justify-center rounded-2xl bg-muted/60 p-2 shadow-inner ring-1 ring-border">
                <Image
                  src="/brand/logo.png"
                  alt="IcFalcon Logo"
                  width={40}
                  height={40}
                  className="h-10 w-10 object-contain drop-shadow"
                  priority
                />
              </div>
            </div>
            <div className="flex items-center justify-center gap-2 mb-1">
              <CardTitle className="text-xl font-bold tracking-tight">IcFalcon</CardTitle>
              <Badge variant="outline" className="text-[10px] font-mono">
                Auth
              </Badge>
            </div>
            <CardDescription className="text-xs text-muted-foreground">
              Decentralized, end-to-end encrypted authentication
            </CardDescription>
          </CardHeader>

          <CardContent className="space-y-4">
            {error && (
              <div className="flex items-start gap-2 rounded-lg border border-destructive/40 bg-destructive/10 p-3 text-xs text-destructive">
                <AlertCircle className="h-4 w-4 shrink-0 mt-0.5" />
                <div className="flex-1">{error}</div>
              </div>
            )}

            {isLoading ? (
              <div className="flex flex-col items-center justify-center py-8 gap-3 text-muted-foreground">
                <Loader2 className="h-6 w-6 animate-spin text-primary" />
                <span className="text-xs">Checking session...</span>
              </div>
            ) : isAuthenticated ? (
              <div className="space-y-4 py-2">
                <div className="rounded-lg border border-border/80 bg-muted/40 p-3 space-y-2">
                  <div className="flex items-center gap-2 text-xs font-medium text-emerald-500">
                    <ShieldCheck className="h-4 w-4" />
                    <span>Signed In</span>
                  </div>
                  <div className="flex items-center justify-between gap-2 rounded bg-background/80 px-2 py-1.5 font-mono text-[11px] text-muted-foreground">
                    <span className="truncate">
                      {principal ? `${principal.slice(0, 14)}...${principal.slice(-10)}` : "Authenticated"}
                    </span>
                    <button
                      type="button"
                      onClick={copyPrincipal}
                      className="p-1 hover:text-foreground transition-colors cursor-pointer"
                      title="Copy full Principal"
                    >
                      {copied ? <Check className="h-3.5 w-3.5 text-emerald-500" /> : <Copy className="h-3.5 w-3.5" />}
                    </button>
                  </div>
                </div>

                <div className="flex flex-col gap-2">
                  <Button
                    type="button"
                    className="w-full"
                    onClick={() => router.push("/")}
                  >
                    Go to Dashboard
                  </Button>
                  <Button
                    type="button"
                    variant="outline"
                    className="w-full"
                    onClick={() => logout()}
                  >
                    Sign Out
                  </Button>
                </div>
              </div>
            ) : (
              <div className="space-y-4">
                {/* Primary Internet Identity Button */}
                <Button
                  type="button"
                  size="lg"
                  className="w-full justify-center gap-2.5 font-medium shadow-md transition-all active:scale-[0.98]"
                  onClick={() => handleLogin()}
                  disabled={!!signingIn}
                >
                  {signingIn === "ii" ? (
                    <Loader2 className="h-4 w-4 animate-spin" />
                  ) : (
                    <Fingerprint className="h-5 w-5" />
                  )}
                  <span>Continue with Internet Identity</span>
                </Button>

                <div className="flex items-center justify-center gap-1.5 text-[11px] text-muted-foreground">
                  <ShieldCheck className="h-3.5 w-3.5 text-primary/70" />
                  <span>Passkey, TouchID, FaceID or Security Key</span>
                </div>

                {/* Divider */}
                <div className="relative my-3">
                  <div className="absolute inset-0 flex items-center">
                    <span className="w-full border-t border-border/60" />
                  </div>
                  <div className="relative flex justify-center text-[10px] uppercase">
                    <span className="bg-card px-2 text-muted-foreground/80 font-medium">
                      or federated web3 login
                    </span>
                  </div>
                </div>

                {/* OpenID Providers Grid */}
                <div className="grid grid-cols-3 gap-2">
                  <Button
                    type="button"
                    variant="outline"
                    size="sm"
                    className="h-10 flex items-center justify-center gap-1.5 text-xs font-normal hover:bg-accent"
                    onClick={() => handleLogin("google")}
                    disabled={!!signingIn}
                  >
                    {signingIn === "google" ? (
                      <Loader2 className="h-3.5 w-3.5 animate-spin" />
                    ) : (
                      <svg className="h-3.5 w-3.5" viewBox="0 0 24 24">
                        <path
                          fill="#4285F4"
                          d="M22.56 12.25c0-.78-.07-1.53-.2-2.25H12v4.26h5.92c-.26 1.37-1.04 2.53-2.21 3.31v2.77h3.57c2.08-1.92 3.28-4.74 3.28-8.09z"
                        />
                        <path
                          fill="#34A853"
                          d="M12 23c2.97 0 5.46-.98 7.28-2.66l-3.57-2.77c-.98.66-2.23 1.06-3.71 1.06-2.86 0-5.29-1.93-6.16-4.53H2.18v2.84C3.99 20.53 7.7 23 12 23z"
                        />
                        <path
                          fill="#FBBC05"
                          d="M5.84 14.09c-.22-.66-.35-1.36-.35-2.09s.13-1.43.35-2.09V7.06H2.18C1.43 8.55 1 10.22 1 12s.43 3.45 1.18 4.94l2.85-2.22.81-.63z"
                        />
                        <path
                          fill="#EA4335"
                          d="M12 5.38c1.62 0 3.06.56 4.21 1.64l3.15-3.15C17.45 2.09 14.97 1 12 1 7.7 1 3.99 3.47 2.18 7.06l3.66 2.84c.87-2.6 3.3-4.52 6.16-4.52z"
                        />
                      </svg>
                    )}
                    <span>Google</span>
                  </Button>

                  <Button
                    type="button"
                    variant="outline"
                    size="sm"
                    className="h-10 flex items-center justify-center gap-1.5 text-xs font-normal hover:bg-accent"
                    onClick={() => handleLogin("apple")}
                    disabled={!!signingIn}
                  >
                    {signingIn === "apple" ? (
                      <Loader2 className="h-3.5 w-3.5 animate-spin" />
                    ) : (
                      <svg className="h-3.5 w-3.5 fill-current" viewBox="0 0 170 170">
                        <path d="M150.37 130.25c-2.45 5.66-5.35 10.87-8.71 15.66-4.58 6.53-8.33 11.05-11.22 13.56-4.48 4.12-9.28 6.23-14.42 6.35-3.69 0-8.14-1.05-13.32-3.18-5.19-2.12-9.97-3.17-14.34-3.17-4.58 0-9.49 1.05-14.75 3.17-5.26 2.13-9.5 3.24-12.74 3.35-4.35.13-9.16-1.9-14.42-6.08-3.69-3.04-7.5-7.71-11.45-14.01-6.19-9.9-11.09-20.91-14.71-33.02-3.62-12.11-5.43-23.36-5.43-33.74 0-14.78 3.73-27.14 11.19-37.07 7.46-9.93 16.9-14.99 28.32-15.19 5.03 0 10.45 1.25 16.27 3.76 5.82 2.51 9.4 3.82 10.74 3.93 1.8.11 5.67-1.32 11.61-4.29 5.94-2.97 11.23-4.32 15.87-4.06 13.91.73 24.96 5.85 33.15 15.36-12.23 7.39-18.23 17.51-18 30.36.23 10.02 4.11 18.52 11.64 25.5 7.53 6.98 16.58 11.04 27.15 12.18-2.35 7.15-5.35 14.54-9.01 22.17zM119.22 31.84c0-7.39 2.65-14.41 7.95-21.06 5.3-6.65 11.83-10.49 19.59-11.52.22 1.13.33 2.18.33 3.15 0 7.34-2.73 14.53-8.19 21.57-5.46 7.04-12.06 10.98-19.8 11.82-.11-1.36-.18-2.68-.18-3.96z" />
                      </svg>
                    )}
                    <span>Apple</span>
                  </Button>

                  <Button
                    type="button"
                    variant="outline"
                    size="sm"
                    className="h-10 flex items-center justify-center gap-1.5 text-xs font-normal hover:bg-accent"
                    onClick={() => handleLogin("microsoft")}
                    disabled={!!signingIn}
                  >
                    {signingIn === "microsoft" ? (
                      <Loader2 className="h-3.5 w-3.5 animate-spin" />
                    ) : (
                      <svg className="h-3.5 w-3.5" viewBox="0 0 23 23">
                        <path fill="#f35325" d="M1 1h10v10H1z" />
                        <path fill="#81bc06" d="M12 1h10v10H12z" />
                        <path fill="#05a6f0" d="M1 12h10v10H1z" />
                        <path fill="#ffba08" d="M12 12h10v10H12z" />
                      </svg>
                    )}
                    <span>Microsoft</span>
                  </Button>
                </div>

                {/* Redirect fallback */}
                <div className="pt-2 text-center">
                  <button
                    type="button"
                    onClick={handleRedirectLogin}
                    disabled={!!signingIn}
                    className="inline-flex items-center gap-1 text-[11px] text-muted-foreground hover:text-foreground transition-colors underline-offset-4 hover:underline cursor-pointer"
                  >
                    <span>Having popup issues? Use mobile redirect</span>
                    <ExternalLink className="h-3 w-3" />
                  </button>
                </div>
              </div>
            )}
          </CardContent>

          <CardFooter className="flex flex-col border-t border-border/40 pt-4 pb-4 text-center">
            <p className="text-[11px] text-muted-foreground/70">
              No passwords stored • Cryptographically secured • ICP Native
            </p>
          </CardFooter>
        </Card>
      </div>

      {/* Footer */}
      <footer className="relative z-10 flex w-full items-center justify-between text-xs text-muted-foreground">
        <div>
          Powered by <span className="font-semibold text-foreground">IcFalcon</span>
        </div>
        <div className="flex items-center gap-4">
          <a
            href="https://icpay.cloud/icfalcon"
            target="_blank"
            rel="noopener noreferrer"
            className="hover:text-foreground transition-colors"
          >
            icpay.cloud
          </a>
          <a
            href="https://github.com/prasangaramanpokharel/icfalcon"
            target="_blank"
            rel="noopener noreferrer"
            className="hover:text-foreground transition-colors"
          >
            GitHub
          </a>
        </div>
      </footer>
    </main>
  )
}
