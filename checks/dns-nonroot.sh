#! /usr/bin/env bash

# Set path to a save default
# Set path to a save default
PATH="$(dirname "$0")/..:/usr/lib/gatemon:/usr/lib/nagios/plugins:/usr/lib/monitoring-plugins:/bin:/usr/bin:/sbin:/usr/sbin"

# Include config if exists
if [[ -e /etc/gatemon.cfg ]]; then
  . /etc/gatemon.cfg
else
  echo '/etc/gatemon.cfg does not exists' >&2
  exit 1
fi

export TIMEFORMAT="%0R"

NETWORK_DEVICE="$1"
SERVER_IP4="$2"
SERVER_IP6="$3"

if [[ -z "$NETWORK_DEVICE" ]] || [[ -z "$SERVER_IP4" ]] || [[ -z "$SERVER_IP6" ]]; then
  echo "$0 <device> <ipv4> <ipv6>" >&2
  exit 1
fi

cat <<EOF
    dns:
      '0':
EOF

# IPv4
ELAPSED_TIME=0
STATUS_CODE=0

exec 3>/dev/null 4>/dev/null
ELAPSED_TIME="$( { time dig +short +timeout=10 "$HOST_TO_FETCH" @"$SERVER_IP4" 1>&3 2>&4; } 2>&1)"
exec 3>&- 4>&-

if [[ "$?" = 0 ]]; then
  STATUS_CODE=1
fi

cat <<EOF
        ipv4: ${STATUS_CODE}
EOF

# IPv6
ELAPSED_TIME=0
STATUS_CODE=0

exec 3>/dev/null 4>/dev/null
ELAPSED_TIME="$( { time dig +short +timeout=10 "$HOST_TO_FETCH" @"$SERVER_IP6" 1>&3 2>&4; } 2>&1)"
exec 3>&- 4>&-

if [[ "$?" = 0 ]]; then
  STATUS_CODE=1
fi

cat <<EOF
        ipv6: ${STATUS_CODE}
EOF
