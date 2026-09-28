"use client"

import Image from "next/image"
import { BackendStatus } from "@/components/home/BackendStatus"
import { Meteors } from "@/components/ui/meteors"
import { Badge } from "@/components/ui/badge"
import { buttonVariants } from "@/components/ui/button"
import { ThemeToggle } from "@/components/ui/theme-toggle"
import { cn } from "@/lib/utils"

export default function HomePage() {
  return (
    <main className="relative flex h-screen max-h-screen w-full flex-col justify-between overflow-hidden bg-background text-foreground p-6 sm:p-8">
      {/* Background Meteors */}
      <div className="pointer-events-none absolute inset-0 z-0 overflow-hidden">
        <Meteors number={30} minDelay={0.2} maxDelay={1.5} minDuration={2} maxDuration={8} angle={215} />
      </div>

      {/* Top Bar */}
      <header className="relative z-10 flex w-full items-center justify-between">
        <div className="flex items-center gap-2.5">
          <Image
            src="/brand/logo.png"
            alt="IcFalcon Logo"
            width={28}
            height={28}
            className="h-7 w-7"
            priority
          />
          <span className="font-semibold tracking-tight">IcFalcon</span>
          <Badge variant="outline" className="text-[11px] font-mono">
            v0.2.4
          </Badge>
        </div>

        <nav className="flex items-center gap-2">
          <ThemeToggle />
          <a
            href="https://raw.githubusercontent.com/prasangapokharel/IcFalcon/refs/heads/main/docs/README.md"
            target="_blank"
            rel="noopener noreferrer"
            className={cn(buttonVariants({ variant: "ghost", size: "sm" }))}
          >
            Docs
          </a>
        </nav>
      </header>

      {/* Center Hero */}
      <div className="relative z-10 flex flex-col items-center justify-center text-center my-auto">
        <Image
          src="/brand/logo.png"
          alt="IcFalcon"
          width={200}
          height={200}
          priority
          className="h-auto w-36 sm:w-44 drop-shadow-xl"
        />

        <div className="mt-4 flex flex-col items-center gap-2">
          <h1 className="select-none bg-gradient-to-b from-zinc-950 via-zinc-800 to-zinc-500 dark:from-white dark:via-zinc-200 dark:to-zinc-600 bg-clip-text text-center text-4xl font-extrabold tracking-tight text-transparent sm:text-5xl lg:text-6xl">
            Welcome to IcFalcon
          </h1>
          <p className="max-w-md text-sm text-muted-foreground sm:text-base">
            The Motoko framework for Internet Computer apps.
          </p>
        </div>

        <div className="mt-6 w-full max-w-sm">
          <BackendStatus />
        </div>

        <div className="mt-5 flex items-center justify-center gap-2.5">
          <a
            href="https://raw.githubusercontent.com/prasangapokharel/IcFalcon/refs/heads/main/docs/README.md"
            target="_blank"
            rel="noopener noreferrer"
            className={cn(buttonVariants({ variant: "default", size: "sm" }))}
          >
            Documentation
          </a>
          <a
            href="https://icpay.app/products/icFalcon/commands"
            target="_blank"
            rel="noopener noreferrer"
            className={cn(buttonVariants({ variant: "outline", size: "sm" }))}
          >
            Commands
          </a>
        </div>
      </div>

      {/* Footer */}
      <footer className="relative z-10 flex w-full items-center justify-between text-xs text-muted-foreground">
        <span>© {new Date().getFullYear()} IcFalcon</span>

        <a
          href="https://icpay.app"
          target="_blank"
          rel="noopener noreferrer"
          className="inline-flex items-center gap-2 rounded-full border bg-card/60 px-3 py-1 text-xs text-muted-foreground transition-colors hover:border-foreground/20 hover:text-foreground"
        >
          <span className="text-[11px]">Powered by</span>
          <div className="flex items-center gap-1.5 font-semibold text-foreground">
            <Image
              src="/brand/partner.png"
              alt="icPay"
              width={16}
              height={16}
              className="h-4 w-4 rounded-xs"
            />
            <span>icPay</span>
          </div>
        </a>
      </footer>
    </main>
  )
}
