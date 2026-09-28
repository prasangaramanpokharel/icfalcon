"use client"

import { useEffect, useState } from "react"
import { Moon, Sun } from "lucide-react"
import { buttonVariants } from "@/components/ui/button"
import { cn } from "@/lib/utils"

export function ThemeToggle() {
  const [mounted, setMounted] = useState(false)
  const [isDark, setIsDark] = useState(true)

  useEffect(() => {
    setMounted(true)
    const isDarkMode = document.documentElement.classList.contains("dark")
    setIsDark(isDarkMode)
  }, [])

  const toggleTheme = () => {
    const isCurrentlyDark = document.documentElement.classList.contains("dark")
    const nextDark = !isCurrentlyDark
    if (nextDark) {
      document.documentElement.classList.add("dark")
      localStorage.setItem("theme", "dark")
    } else {
      document.documentElement.classList.remove("dark")
      localStorage.setItem("theme", "light")
    }
    setIsDark(nextDark)
  }

  return (
    <button
      type="button"
      onClick={toggleTheme}
      aria-label="Toggle theme"
      className={cn(
        buttonVariants({ variant: "outline", size: "icon-sm" }),
        "h-8 w-8 rounded-full cursor-pointer transition-colors"
      )}
    >
      {!mounted ? (
        <span className="h-4 w-4" />
      ) : isDark ? (
        <Sun className="h-4 w-4 text-zinc-200 transition-transform hover:rotate-45" />
      ) : (
        <Moon className="h-4 w-4 text-zinc-800 transition-transform hover:-rotate-12" />
      )}
    </button>
  )
}
