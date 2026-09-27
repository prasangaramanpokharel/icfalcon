#!/usr/bin/env bash

replica_api_url() {
  printf '%s' "http://127.0.0.1:4943"
}

replica_is_running() {
  dfx ping &>/dev/null
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
  cd "${FALCON_BACKEND_DIR:?}"
  if replica_is_running; then
    return 0
  fi
  kill_lingering_replica_processes
  dfx start --clean --background
  wait_for_replica
}

stop_local_replica() {
  cd "${FALCON_BACKEND_DIR:?}"
  dfx stop 2>/dev/null || true
  kill_lingering_replica_processes
}

replica_canister_id() {
  dfx canister id "${FALCON_CANISTER:-app}" --network local 2>/dev/null || true
}
