#!/bin/sh -eux

cli() {
  # Grab the first argument and drop it from the input
  arg="$1"

  case $arg in
    # Users can update caddy with additional plugins or modules at runtime. The
    # caddy binary needs to be mutable in this case.
    add-package|remove-package)
      [ -e "${SNAP_COMMON}/caddy-mod" ] || {
        cp -f "${SNAP}/usr/bin/caddy" "${SNAP_COMMON}/caddy-mod"
        _caddy="${SNAP_COMMON}/caddy-mod"
      }

      shift 1
      $_caddy "$arg" "$@"

      snapctl set modified=true ;;
    *) $_caddy "$@"             ;;
  esac
}

reload() {
  $_caddy reload --config "${SNAP_COMMON}/caddy.json"
}

run() {
  $_caddy run \
    --config  "${SNAP_COMMON}/caddy.json" \
    --pidfile "${SNAP_COMMON}/caddy.pid"
}

_caddy="${SNAP}/usr/bin/caddy"
[ "$(snapctl get modified)" = "true" ] && _caddy="${SNAP_COMMON}/caddy-mod"

"$@"
