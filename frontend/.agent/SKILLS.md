# Frontend Agent Skills

Router for work under `frontend/`. Master standard: [`.agent/skills/frontendStandard/SKILL.md`](../../.agent/skills/frontendStandard/SKILL.md)

## Task → skill

| Task | Skill |
|---|---|
| Any frontend change | [`../../.agent/skills/frontendStandard/SKILL.md`](../../.agent/skills/frontendStandard/SKILL.md) |
| Package versions & @icp-sdk | [`skills/versionStandard/SKILL.md`](skills/versionStandard/SKILL.md) |
| `lib/` helpers | [`skills/libStandard/SKILL.md`](skills/libStandard/SKILL.md) |
| `hooks/` SWR | [`skills/hooksStandard/SKILL.md`](skills/hooksStandard/SKILL.md) |
| shadcn components & blocks | [`skills/shadcnStandard/SKILL.md`](skills/shadcnStandard/SKILL.md) |
| SWR reference | [`skills/swrOfficialStandard/SKILL.md`](skills/swrOfficialStandard/SKILL.md) |
| Next.js App Router | [`skills/nextjsStandard/SKILL.md`](skills/nextjsStandard/SKILL.md) |

## Cursor rules

Rules are thin pointers — detail lives in skills above.

| Rule | Scope | Skill |
|---|---|---|
| [`rules/uiComponents.mdc`](rules/uiComponents.mdc) | `components/**`, `app/**` | `frontendStandard` |
| [`rules/services.mdc`](rules/services.mdc) | `services/**` | `frontendStandard` |
| [`rules/libStandard.mdc`](rules/libStandard.mdc) | `lib/**` | `libStandard` |
| [`rules/hooksStandard.mdc`](rules/hooksStandard.mdc) | `hooks/**` | `hooksStandard` |
| [`rules/shadcnBlocks.mdc`](rules/shadcnBlocks.mdc) | full sections / shells | `shadcnBlocksStandard` |

## Folders (camelCase)

```
frontend/
├── lib/<feature>/
├── hooks/<feature>/
├── services/<feature>/
├── components/<feature>/
└── components/ui/
```

## Root skills (deploy, setup, versions)

| Task | Path |
|---|---|
| Project setup | [`../../.agent/skills/guideStandard/projectSetupStandard/SKILL.md`](../../.agent/skills/guideStandard/projectSetupStandard/SKILL.md) |
| Local deploy | [`../../.agent/skills/guideStandard/localDeployStandard/SKILL.md`](../../.agent/skills/guideStandard/localDeployStandard/SKILL.md) |
| Production deploy | [`../../.agent/skills/guideStandard/productionDeployStandard/SKILL.md`](../../.agent/skills/guideStandard/productionDeployStandard/SKILL.md) |
| Version standard | [`../../.agent/skills/versionStandard/SKILL.md`](../../.agent/skills/versionStandard/SKILL.md) |
