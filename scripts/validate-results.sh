#!/usr/bin/env bash
set -euo pipefail

RESULT_FILE="${1:-results/results.jtl}"

if [[ ! -f "$RESULT_FILE" ]]; then
  echo "Result file not found: $RESULT_FILE"
  exit 1
fi

TOTAL=$(awk 'NR>1 {count++} END {print count+0}' "$RESULT_FILE")
FAILED=$(awk -F',' 'NR>1 && $8=="false" {count++} END {print count+0}' "$RESULT_FILE")

echo "Total samples: $TOTAL"
echo "Failed samples: $FAILED"

if [[ "$TOTAL" -eq 0 ]]; then
  echo "No samples were executed."
  exit 1
fi

if [[ "$FAILED" -gt 0 ]]; then
  echo "Performance test finished with failed samples."
  exit 1
fi

echo "All samples passed."
