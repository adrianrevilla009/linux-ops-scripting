#!/usr/bin/env bats

setup() {
  SCRIPT="$BATS_TEST_DIRNAME/../orders-report.sh"
  CSV="$BATS_TEST_DIRNAME/../orders.csv"
}

@test "sums totals per customer" {
  run "$SCRIPT" "$CSV"
  [ "$status" -eq 0 ]
  [ "${lines[0]}" = "ana 15.50" ]
  [ "${lines[1]}" = "bo 4.25" ]
}

@test "no arguments prints usage and exits 2" {
  run "$SCRIPT"
  [ "$status" -eq 2 ]
}

@test "missing file exits 1" {
  run "$SCRIPT" /nonexistent.csv
  [ "$status" -eq 1 ]
}

@test "malformed row fails instead of being skipped" {
  printf 'id,customer,total\n1,ana,abc\n' > "$BATS_TEST_TMPDIR/bad.csv"
  run "$SCRIPT" "$BATS_TEST_TMPDIR/bad.csv"
  [ "$status" -ne 0 ]
}
