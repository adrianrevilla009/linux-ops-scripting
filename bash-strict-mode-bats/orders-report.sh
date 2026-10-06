#!/usr/bin/env bash
# Sum order totals per customer from a CSV (id,customer,total).
set -euo pipefail
IFS=$'\n\t'

usage() {
  echo "usage: orders-report.sh <orders.csv>" >&2
  exit 2
}

main() {
  [[ $# -eq 1 ]] || usage
  local file=$1
  [[ -r $file ]] || { echo "error: cannot read $file" >&2; exit 1; }
  tail -n +2 "$file" | awk -F, '
    NF != 3 || $3 !~ /^[0-9]+(\.[0-9]+)?$/ { print "bad row " NR + 1 > "/dev/stderr"; bad = 1; exit 3 }
    { sum[$2] += $3 }
    END { if (bad) exit 3; for (c in sum) printf "%s %.2f\n", c, sum[c] }' | sort
}

main "$@"
