#!/usr/bin/env node

const { spawn, spawnSync } = require("child_process")
const fs = require("fs")
const path = require("path")

const args = process.argv.slice(2)

// Function to find falcon.yaml upwards from cwd
function findFalconYaml(startDir = process.cwd()) {
  let current = startDir
  while (true) {
    const candidate = path.join(current, "falcon.yaml")
    if (fs.existsSync(candidate)) {
      return { config: candidate, root: current }
    }
    const parent = path.dirname(current)
    if (parent === current) {
      break
    }
    current = parent
  }
  return null
}

const project = findFalconYaml()

// Scaffolding helper: if not inside project, or explicitly asked to create
const isCreateCommand =
  !project ||
  args[0] === "new" ||
  args[0] === "create" ||
  (args.length === 1 && !args[0].startsWith("-") && !args[0].includes(":") && args[0] !== "help")

if (isCreateCommand) {
  // Pass to scaffolder
  const scaffolderPath = path.join(__dirname, "..", "ops", "create-icfalcon", "bin", "create-icfalcon.js")
  if (fs.existsSync(scaffolderPath)) {
    const scaffoldArgs = args[0] === "new" || args[0] === "create" ? args.slice(1) : args
    const child = spawn(process.execPath, [scaffolderPath, ...scaffoldArgs], { stdio: "inherit" })
    child.on("exit", (code) => process.exit(code || 0))
  } else {
    console.error("IcFalcon: Scaffolder script not found.")
    process.exit(1)
  }
} else {
  // Inside existing project: run ops/falcon
  const falconBin = path.join(project.root, "ops", "falcon")
  const child = spawn(falconBin, args, { stdio: "inherit", cwd: project.root })
  child.on("exit", (code) => process.exit(code || 0))
}
