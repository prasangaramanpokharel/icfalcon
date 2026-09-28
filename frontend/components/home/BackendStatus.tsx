"use client"

import { useState } from "react"
import { Badge } from "@/components/ui/badge"
import { ShineBorder } from "@/components/ui/shine-border"
import { useBackendHealth } from "@/hooks/health/useBackendHealth"
import { canisterId, host } from "@/services/icp"
import { Check, Copy } from "lucide-react"

function HealthBadge() {
  const { data, error, isLoading } = useBackendHealth()

  if (isLoading) {
    return (
      <Badge variant="outline" className="gap-1.5 text-xs text-muted-foreground">
        <span className="h-1.5 w-1.5 rounded-full bg-amber-500 animate-pulse" />
        Checking
      </Badge>
    )
  }

  if (error || !data) {
    return (
      <Badge variant="destructive" className="gap-1.5 text-xs">
        <span className="h-1.5 w-1.5 rounded-full bg-destructive-foreground" />
        Offline
      </Badge>
    )
  }

  return (
    <Badge variant="secondary" className="gap-1.5 text-xs text-emerald-400">
      <span className="h-1.5 w-1.5 rounded-full bg-emerald-500" />
      Online
    </Badge>
  )
}

function CopyableRow({
  label,
  value,
}: {
  label: string
  value: string
}) {
  const [copied, setCopied] = useState(false)

  const handleCopy = () => {
    navigator.clipboard.writeText(value)
    setCopied(true)
    setTimeout(() => setCopied(false), 2000)
  }

  return (
    <div className="flex flex-col gap-1 rounded-lg border bg-muted/40 p-2.5">
      <div className="flex items-center justify-between text-[11px] text-muted-foreground">
        <span>{label}</span>
        <button
          onClick={handleCopy}
          aria-label={`Copy ${label}`}
          className="inline-flex items-center gap-1 rounded px-1.5 py-0.5 text-[11px] text-muted-foreground transition-colors hover:bg-muted hover:text-foreground"
        >
          {copied ? (
            <>
              <Check className="h-3 w-3 text-emerald-400" />
              <span className="text-emerald-400">Copied</span>
            </>
          ) : (
            <>
              <Copy className="h-3 w-3" />
              <span>Copy</span>
            </>
          )}
        </button>
      </div>
      <div className="truncate font-mono text-xs text-foreground">
        {value}
      </div>
    </div>
  )
}

export function BackendStatus() {
  const isLocal = host.includes("127.0.0.1") || host.includes("localhost")

  return (
    <div className="relative w-full max-w-sm overflow-hidden rounded-xl border bg-card p-4 text-card-foreground shadow-sm">
      <ShineBorder
        borderWidth={1}
        duration={12}
        shineColor={["#A07CFE", "#FE8FB5", "#FFBE7B"]}
      />

      <div className="relative z-10 flex flex-col gap-3 text-left">
        <div className="flex items-center justify-between border-b pb-2.5">
          <span className="text-xs font-medium text-muted-foreground">
            Backend Status
          </span>
          <div className="flex items-center gap-1.5">
            <Badge variant="outline" className="text-[10px] font-mono">
              {isLocal ? "local" : "mainnet"}
            </Badge>
            <HealthBadge />
          </div>
        </div>

        <div className="flex flex-col gap-2">
          <CopyableRow label="Replica Host" value={host} />
          <CopyableRow label="Canister ID" value={canisterId} />
        </div>
      </div>
    </div>
  )
}
