"use client"

import { useEffect, useState } from "react"
import { Moon, Sun } from "lucide-react"
import { Button } from "@/components/ui/button"

export function ThemeToggle() {
  const [isDark, setIsDark] = useState(true)

  useEffect(() => {
    const isDarkMode = document.documentElement.classList.contains("dark")
    setIsDark(isDarkMode)
  }, [])

  const toggleTheme = () => {
    const nextDark = !isDark
    setIsDark(nextDark)
    if (nextDark) {
      document.documentElement.classList.add("dark")
      localStorage.setItem("theme", "dark")
    } else {
      document.documentElement.classList.remove("dark")
      localStorage.setItem("theme", "light")
    }
  }

  return (
    <Button
      variant="outline"
      size="icon-sm"
      onClick={toggleTheme}
      aria-label="Toggle theme"
      className="h-8 w-8 rounded-full"
    >
      {isDark ? (
        <Sun className="h-4 w-4 text-zinc-300 transition-transform hover:rotate-45" />
      ) : (
        <Moon className="h-4 w-4 text-zinc-700 transition-transform hover:-rotate-12" />
      )}
    </Button>
  )
}
