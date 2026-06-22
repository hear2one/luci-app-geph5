#!/bin/sh

set -eu

UPSTREAM_DIR="${1:-}"
TEMP_DIR=""

cleanup() {
	[ -z "$TEMP_DIR" ] || rm -rf "$TEMP_DIR"
}
trap cleanup EXIT INT TERM

if [ -z "$UPSTREAM_DIR" ]; then
	TEMP_DIR="$(mktemp -d)"
	git clone --depth 1 https://github.com/geph-official/geph5.git "$TEMP_DIR/geph5"
	UPSTREAM_DIR="$TEMP_DIR/geph5"
fi

CONFIG_RS="$UPSTREAM_DIR/binaries/geph5-client/src/client.rs"
CLI_RS="$UPSTREAM_DIR/binaries/geph5-client/src/bin/geph5-client.rs"

[ -f "$CONFIG_RS" ] && [ -f "$CLI_RS" ] || {
	echo "geph5-client upstream source layout was not found" >&2
	exit 1
}

for field in \
	socks5_listen http_proxy_listen pac_listen control_listen control_listen_unix \
	exit_constraint allow_direct cache broker tunneled_broker broker_keys port_forward \
	vpn vpn_fd spoof_dns passthrough_china dry_run credentials sess_metadata task_limit
do
	grep -Eq "pub[[:space:]]+$field[[:space:]]*:" "$CONFIG_RS" || {
		echo "upstream Config field missing or renamed: $field" >&2
		exit 1
	}
done

grep -Eq '#\[arg\(short,[[:space:]]*long\)\]' "$CLI_RS" || {
	echo "upstream geph5-client no longer exposes the expected -c/--config argument" >&2
	exit 1
}

if grep -Eq 'pub[[:space:]]+bridge_mode[[:space:]]*:' "$CONFIG_RS"; then
	echo "upstream restored bridge_mode; review generated YAML before updating the marker" >&2
	exit 1
fi

echo "Geph5 upstream configuration and CLI contract are compatible."
