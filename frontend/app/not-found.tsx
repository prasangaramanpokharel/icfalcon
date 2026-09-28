import Link from "next/link"
import { buttonVariants } from "@/components/ui/button"
import { cn } from "@/lib/utils"

export default function NotFound() {
  return (
    <main className="flex h-screen flex-col items-center justify-center bg-background px-4 text-center">
      <h1 className="text-4xl font-bold tracking-tight text-foreground sm:text-6xl">404</h1>
      <p className="mt-3 text-base text-muted-foreground">Page not found</p>
      <div className="mt-6">
        <Link href="/" className={cn(buttonVariants({ variant: "outline" }))}>
          Back to Home
        </Link>
      </div>
    </main>
  )
}
