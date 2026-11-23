#!/usr/bin/env bash

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/../../.." && pwd)"

has_icp() {
  command -v icp >/dev/null 2>&1 && [[ -f "$ROOT/icp.yaml" ]]
}

replica_api_url() {
  if has_icp; then
    printf '%s' "http://127.0.0.1:8000"
  else
    printf '%s' "http://127.0.0.1:4943"
  fi
}

replica_is_running() {
  if has_icp; then
    (cd "$ROOT" && icp network ping local &>/dev/null)
  else
    dfx ping &>/dev/null
  fi
}

wait_for_replica() {
  local i=0
  while ! replica_is_running; do
    i=$((i + 1))
    [[ $i -ge 60 ]] && return 1
    sleep 1
  done
}

kill_lingering_replica_processes() {
  pkill -9 -f "pocket-ic" 2>/dev/null || true
  pkill -9 -f "dfx start" 2>/dev/null || true
  pkill -9 -f "icx-proxy" 2>/dev/null || true
  local backend="${FALCON_BACKEND_DIR:-$PWD}"
  rm -f "$backend/.dfx/network/local/pid" 2>/dev/null || true
}

start_local_replica() {
  if replica_is_running; then
    return 0
  fi
  kill_lingering_replica_processes
  if has_icp; then
    cd "$ROOT"
    icp network start -d
    wait_for_replica
  else
    cd "${FALCON_BACKEND_DIR:?}"
    nohup dfx start --clean --background </dev/null >/dev/null 2>&1 || dfx start --clean --background
    wait_for_replica
  fi
}

stop_local_replica() {
  if has_icp; then
    cd "$ROOT"
    icp network stop 2>/dev/null || true
  else
    cd "${FALCON_BACKEND_DIR:?}"
    dfx stop 2>/dev/null || true
  fi
  kill_lingering_replica_processes
}

replica_canister_id() {
  if has_icp; then
    (cd "$ROOT" && icp canister status "${FALCON_CANISTER:-app}" -e local 2>/dev/null | awk '/Canister Id:/ {print $3}') || true
  else
    dfx canister id "${FALCON_CANISTER:-app}" --network local 2>/dev/null || true
  fi
}
