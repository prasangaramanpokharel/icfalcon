#!/usr/bin/env bash
set -euo pipefail

ROOT="${FALCON_ROOT:?}"

USE_ORM=false
ARGS=()
for arg in "$@"; do
  if [[ "$arg" == "--orm" ]]; then
    USE_ORM=true
  else
    ARGS+=("$arg")
  fi
done

NAME_RAW="${ARGS[0]:-}"

fail() { echo "error: $1" >&2; exit 1; }

[[ -n "$NAME_RAW" ]] || fail "usage: falcon make:feature <Name> [--orm]  (e.g. Order, Product)"

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

TPL="$ROOT/ops/templates/feature"
BACKEND="$ROOT/backend/src"
FRONTEND="$ROOT/frontend"

render() {
  local src="$1"
  local dest="$2"
  sed -e "s/{{Name}}/$NAME/g" \
      -e "s/{{name}}/$name/g" \
      -e "s/{{kebab}}/$kebab/g" \
      "$src" > "$dest"
}

step() { echo "  + $1"; }

if [[ "$USE_ORM" == "true" ]]; then
  step "backend/storage/${NAME}Storage.mo (FalconORM Table)"
  render "$TPL/StorageOrm.mo.tpl" "$BACKEND/storage/${NAME}Storage.mo"

  step "backend/repositories/${NAME}Repository.mo (FalconORM Repo)"
  render "$TPL/RepositoryOrm.mo.tpl" "$BACKEND/repositories/${NAME}Repository.mo"

  step "backend/validators/${NAME}Validator.mo"
  render "$TPL/Validator.mo.tpl" "$BACKEND/validators/${NAME}Validator.mo"

  step "backend/services/${NAME}Service.mo (FalconORM Service)"
  render "$TPL/ServiceOrm.mo.tpl" "$BACKEND/services/${NAME}Service.mo"
else
  step "backend/storage/${NAME}Storage.mo"
  render "$TPL/Storage.mo.tpl" "$BACKEND/storage/${NAME}Storage.mo"

  step "backend/repositories/${NAME}Repository.mo"
  render "$TPL/Repository.mo.tpl" "$BACKEND/repositories/${NAME}Repository.mo"

  step "backend/validators/${NAME}Validator.mo"
  render "$TPL/Validator.mo.tpl" "$BACKEND/validators/${NAME}Validator.mo"

  step "backend/services/${NAME}Service.mo"
  render "$TPL/Service.mo.tpl" "$BACKEND/services/${NAME}Service.mo"
fi

step "backend/api/v1/${NAME}.mo"
render "$TPL/Api.mo.tpl" "$BACKEND/api/v1/${NAME}.mo"

if ! grep -q "public type ${NAME} =" "$BACKEND/types.mo"; then
  step "types.mo — add ${NAME} type"
  perl -i -pe '
    if (/public type HealthStatus = \{/) {
      print "  public type '"$NAME"' = {\n    id : Text;\n    name : Text;\n    owner : Principal;\n    createdAt : Int;\n  };\n\n";
    }
  ' "$BACKEND/types.mo"
fi

mkdir -p "$FRONTEND/services/$kebab" "$FRONTEND/components/$kebab"

step "frontend/services/${kebab}/${kebab}.ts"
render "$TPL/service.ts.tpl" "$FRONTEND/services/$kebab/$kebab.ts"

step "frontend/components/${kebab}/${kebab}-panel.tsx"
render "$TPL/panel.tsx.tpl" "$FRONTEND/components/$kebab/${kebab}-panel.tsx"

MAIN="$BACKEND/main.mo"
if ! grep -q "${NAME}Api" "$MAIN"; then
  step "main.mo — wire ${NAME} module"
  if [[ "$USE_ORM" == "true" ]]; then
    perl -i -pe '
      if (/import FeatureApi "api\/v1\/Feature";/) {
        $_ .= "import '"${NAME}"'Api \"api/v1/'"${NAME}"'\";\n";
      } elsif (/import FeatureService "services\/FeatureService";/) {
        $_ .= "import '"${NAME}"'Service \"services/'"${NAME}"'Service\";\n";
      } elsif (/import FeatureStorage "storage\/FeatureStorage";/) {
        $_ .= "import '"${NAME}"'Storage \"storage/'"${NAME}"'Storage\";\n";
      } elsif (/let features = FeatureStorage\.createFeatureMap\(\);/) {
        $_ .= "  transient let '"${name}"'s = '"${NAME}"'Storage.create'"${NAME}"'Table(null);\n";
      } elsif (/transient let featureService = FeatureService\.create\(features, users\);/) {
        $_ .= "  transient let '"${name}"'Service = '"${NAME}"'Service.create('"${name}"'s, users);\n";
      } elsif (/include FeatureApi\(featureService, mwConfig\);/) {
        $_ .= "  include '"${NAME}"'Api('"${name}"'Service, mwConfig);\n";
      }
    ' "$MAIN"
  else
    perl -i -pe '
      if (/import FeatureApi "api\/v1\/Feature";/) {
        $_ .= "import '"${NAME}"'Api \"api/v1/'"${NAME}"'\";\n";
      } elsif (/import FeatureService "services\/FeatureService";/) {
        $_ .= "import '"${NAME}"'Service \"services/'"${NAME}"'Service\";\n";
      } elsif (/import FeatureStorage "storage\/FeatureStorage";/) {
        $_ .= "import '"${NAME}"'Storage \"storage/'"${NAME}"'Storage\";\n";
      } elsif (/let features = FeatureStorage\.createFeatureMap\(\);/) {
        $_ .= "  let '"${name}"'s = '"${NAME}"'Storage.create'"${NAME}"'Map();\n";
      } elsif (/transient let featureService = FeatureService\.create\(features, users\);/) {
        $_ .= "  transient let '"${name}"'Service = '"${NAME}"'Service.create('"${name}"'s, users);\n";
      } elsif (/include FeatureApi\(featureService, mwConfig\);/) {
        $_ .= "  include '"${NAME}"'Api('"${name}"'Service, mwConfig);\n";
      }
    ' "$MAIN"
  fi
fi

echo ""
echo "Created module: ${NAME}"
echo ""
echo "Next:"
echo "  falcon b:test --local"
echo "  falcon b:deploy --local"
echo ""
echo "Frontend: import { ${NAME}Panel } from \"@/components/${kebab}/${kebab}-panel\""
