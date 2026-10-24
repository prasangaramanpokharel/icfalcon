#!/usr/bin/env bash
set -euo pipefail

ROOT="${FALCON_ROOT:?}"
NAME_RAW="${1:-}"

fail() { echo "error: $1" >&2; exit 1; }

[[ -n "$NAME_RAW" ]] || fail "usage: falcon make:canister <Name>  (e.g. Trade, Vault, Dex)"

to_pascal() {
  perl -e '
    my $s = shift;
    $s =~ s/(?:^|[-_])([a-z])/uc($1)/ge;
    $s =~ s/[-_]//g;
    print "$s\n";
  ' "$1"
}

to_camel() {
  local pascal
  pascal="$(to_pascal "$1")"
  echo "$(tr '[:upper:]' '[:lower:]' <<< "${pascal:0:1}")${pascal:1}"
}

to_kebab() {
  echo "$1" | sed -E 's/([a-z])([A-Z])/\1-\2/g' | tr '[:upper:]' '[:lower:]' | tr '_' '-'
}

NAME="$(to_pascal "$NAME_RAW")"
name="$(to_camel "$NAME_RAW")"
kebab="$(to_kebab "$NAME")"
UPPER="$(echo "$kebab" | tr '[:lower:]-' '[:upper:]_')"

TPL="$ROOT/ops/templates/canister"
BACKEND="$ROOT/backend"
FRONTEND="$ROOT/frontend"
DEST="$BACKEND/canisters/$kebab"

render() {
  local src="$1"
  local dest="$2"
  sed -e "s/{{Name}}/$NAME/g" \
      -e "s/{{name}}/$name/g" \
      -e "s/{{kebab}}/$kebab/g" \
      -e "s/{{UPPER}}/$UPPER/g" \
      "$src" > "$dest"
}

step() { echo "  + $1"; }

mkdir -p "$DEST"

step "backend/canisters/${kebab}/main.mo (wired with Falcon Universe mesh)"
render "$TPL/main.mo.tpl" "$DEST/main.mo"

step "backend/canisters/${kebab}/types.mo"
render "$TPL/types.mo.tpl" "$DEST/types.mo"

DFX_JSON="$BACKEND/dfx.json"
if [[ -f "$DFX_JSON" ]]; then
  step "backend/dfx.json — register '${kebab}' canister target"
  python3 -c "
import json
with open('$DFX_JSON') as f:
    dfx = json.load(f)
if 'canisters' not in dfx:
    dfx['canisters'] = {}
dfx['canisters']['$kebab'] = {
    'main': 'canisters/$kebab/main.mo',
    'type': 'motoko',
    'args': '--package pkg pkg'
}
with open('$DFX_JSON', 'w') as f:
    json.dump(dfx, f, indent=2)
    f.write('\n')
"
fi

if [[ -d "$FRONTEND" ]]; then
  mkdir -p "$FRONTEND/services/$kebab"
  step "frontend/services/${kebab}/client.ts (@icp-sdk offline-first client)"
  render "$TPL/client.ts.tpl" "$FRONTEND/services/$kebab/client.ts"
fi

echo ""
echo "🚀 Created micro-canister: ${NAME} (${kebab})"
echo ""
echo "Build & deploy:"
echo "  falcon b:build --canister ${kebab} --local"
echo "  falcon b:deploy --canister ${kebab} --local"
echo "  falcon c:ping --canister ${kebab} --local"
echo "  falcon c:status --canister ${kebab} --local"
echo ""
echo "Frontend: import { ping${NAME}Canister } from \"@/services/${kebab}/client\""
