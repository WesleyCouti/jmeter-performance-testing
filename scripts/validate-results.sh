#!/usr/bin/env bash
set -euo pipefail

RESULT_FILE="${1:-results/results.jtl}"

MAX_ERROR_RATE="${MAX_ERROR_RATE:-1}"
MAX_AVG_RESPONSE_TIME_MS="${MAX_AVG_RESPONSE_TIME_MS:-1000}"
MAX_P95_RESPONSE_TIME_MS="${MAX_P95_RESPONSE_TIME_MS:-1500}"
MAX_P99_RESPONSE_TIME_MS="${MAX_P99_RESPONSE_TIME_MS:-2000}"

if [[ ! -f "$RESULT_FILE" ]]; then
  echo "Result file not found: $RESULT_FILE"
  exit 1
fi

TOTAL=$(awk -F',' '
  NR > 1 {
    count++
  }
  END {
    print count + 0
  }
' "$RESULT_FILE")

FAILED=$(awk -F',' '
  NR > 1 && $8 == "false" {
    count++
  }
  END {
    print count + 0
  }
' "$RESULT_FILE")

if [[ "$TOTAL" -eq 0 ]]; then
  echo "No samples were executed."
  exit 1
fi

ERROR_RATE=$(awk \
  -v failed="$FAILED" \
  -v total="$TOTAL" '
  BEGIN {
    printf "%.2f", (failed / total) * 100
  }
')

AVG_RESPONSE_TIME=$(awk -F',' '
  NR > 1 {
    sum += $2
    count++
  }

  END {
    if (count > 0) {
      printf "%.0f", sum / count
    } else {
      print 0
    }
  }
' "$RESULT_FILE")

P95_RESPONSE_TIME=$(
  awk -F',' '
    NR > 1 {
      print $2
    }
  ' "$RESULT_FILE" |
  sort -n |
  awk '
    {
      values[NR] = $1
    }

    END {
      if (NR == 0) {
        print 0
        exit
      }

      percentile_index = int((NR * 0.95) + 0.999999)

      if (percentile_index < 1) {
        percentile_index = 1
      }

      if (percentile_index > NR) {
        percentile_index = NR
      }

      print values[percentile_index]
    }
  '
)

P99_RESPONSE_TIME=$(
  awk -F',' '
    NR > 1 {
      print $2
    }
  ' "$RESULT_FILE" |
  sort -n |
  awk '
    {
      values[NR] = $1
    }

    END {
      if (NR == 0) {
        print 0
        exit
      }

      percentile_index = int((NR * 0.99) + 0.999999)

      if (percentile_index < 1) {
        percentile_index = 1
      }

      if (percentile_index > NR) {
        percentile_index = NR
      }

      print values[percentile_index]
    }
  '
)

FIRST_TIMESTAMP=$(awk -F',' '
  NR == 2 {
    print $1
    exit
  }
' "$RESULT_FILE")

LAST_TIMESTAMP=$(awk -F',' '
  NR > 1 {
    timestamp = $1
  }

  END {
    print timestamp
  }
' "$RESULT_FILE")

ELAPSED_SECONDS=$(awk \
  -v first="$FIRST_TIMESTAMP" \
  -v last="$LAST_TIMESTAMP" '
  BEGIN {
    duration = (last - first) / 1000

    if (duration <= 0) {
      duration = 1
    }

    printf "%.2f", duration
  }
')

THROUGHPUT=$(awk \
  -v total="$TOTAL" \
  -v seconds="$ELAPSED_SECONDS" '
  BEGIN {
    printf "%.2f", total / seconds
  }
')

echo ""
echo "========================================"
echo "       PERFORMANCE TEST SUMMARY"
echo "========================================"
echo "Result file:              $RESULT_FILE"
echo "Total samples:            $TOTAL"
echo "Failed samples:           $FAILED"
echo "Error rate:               ${ERROR_RATE}%"
echo "Average response time:    ${AVG_RESPONSE_TIME} ms"
echo "P95 response time:        ${P95_RESPONSE_TIME} ms"
echo "P99 response time:        ${P99_RESPONSE_TIME} ms"
echo "Approx. throughput:       ${THROUGHPUT} req/s"
echo "Execution window:         ${ELAPSED_SECONDS} s"
echo ""
echo "Quality Gates"
echo "----------------------------------------"
echo "Max error rate:           ${MAX_ERROR_RATE}%"
echo "Max average response:     ${MAX_AVG_RESPONSE_TIME_MS} ms"
echo "Max P95 response:         ${MAX_P95_RESPONSE_TIME_MS} ms"
echo "Max P99 response:         ${MAX_P99_RESPONSE_TIME_MS} ms"
echo "========================================"
echo ""

FAILED_GATE=0

if awk \
  -v actual="$ERROR_RATE" \
  -v limit="$MAX_ERROR_RATE" \
  'BEGIN { exit !(actual > limit) }'; then

  echo "FAIL: Error rate ${ERROR_RATE}% exceeds ${MAX_ERROR_RATE}%."
  FAILED_GATE=1
else
  echo "PASS: Error rate is within threshold."
fi

if [[ "$AVG_RESPONSE_TIME" -gt "$MAX_AVG_RESPONSE_TIME_MS" ]]; then
  echo "FAIL: Average response time ${AVG_RESPONSE_TIME} ms exceeds ${MAX_AVG_RESPONSE_TIME_MS} ms."
  FAILED_GATE=1
else
  echo "PASS: Average response time is within threshold."
fi

if [[ "$P95_RESPONSE_TIME" -gt "$MAX_P95_RESPONSE_TIME_MS" ]]; then
  echo "FAIL: P95 response time ${P95_RESPONSE_TIME} ms exceeds ${MAX_P95_RESPONSE_TIME_MS} ms."
  FAILED_GATE=1
else
  echo "PASS: P95 response time is within threshold."
fi

if [[ "$P99_RESPONSE_TIME" -gt "$MAX_P99_RESPONSE_TIME_MS" ]]; then
  echo "FAIL: P99 response time ${P99_RESPONSE_TIME} ms exceeds ${MAX_P99_RESPONSE_TIME_MS} ms."
  FAILED_GATE=1
else
  echo "PASS: P99 response time is within threshold."
fi

echo ""

if [[ "$FAILED_GATE" -ne 0 ]]; then
  echo "Performance quality gate failed."
  exit 1
fi

echo "Performance quality gate passed."
