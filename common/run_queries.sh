#!/bin/bash

QUERY_FILE="$1"
OUTPUT_DIR="/vagrant/results"
HOSTNAME="$(hostname)"
OUTPUT_FILE="${OUTPUT_DIR}/osquery_results_${HOSTNAME}.json"
LOG_FILE="${OUTPUT_DIR}/osquery_errors_${HOSTNAME}.log"

mkdir -p "$OUTPUT_DIR"
echo "[" > "$OUTPUT_FILE"
echo -n "" > "$LOG_FILE"

FIRST=1
QUERY_NUM=1
SUCCESS_COUNT=0
FAIL_COUNT=0

while IFS= read -r QUERY || [[ -n "$QUERY" ]]; do
  # Ignore empty lines and comments
  [[ -z "$QUERY" || "$QUERY" =~ ^-- ]] && continue

  echo "[INFO] Running query #$QUERY_NUM: $QUERY"

  # Run the query using osqueryi
  # Redirect stderr to a temporary file to capture errors
  # and check the exit code
  RESULT=$(osqueryi --json "$QUERY" 2> /tmp/osquery_error)
  EXIT_CODE=$?

  if [[ $EXIT_CODE -eq 0 ]]; then
    ESCAPED_QUERY=$(echo "$QUERY" | sed 's/"/\\"/g')

    [[ $FIRST -eq 0 ]] && echo "," >> "$OUTPUT_FILE"
    echo "  {\"query\": \"$ESCAPED_QUERY\", \"results\": $RESULT}" >> "$OUTPUT_FILE"
    FIRST=0
    ((SUCCESS_COUNT++))
  else
    echo "[ERROR] Execution of query #$QUERY_NUM fail" | tee -a "$LOG_FILE"
    echo "Query: $QUERY" >> "$LOG_FILE"
    echo "Error: $(cat /tmp/osquery_error)" >> "$LOG_FILE"
    echo "---" >> "$LOG_FILE"
    ((FAIL_COUNT++))
  fi

  ((QUERY_NUM++))
done < "$QUERY_FILE"

echo "]" >> "$OUTPUT_FILE"

# Show summary
echo ""
echo "✅ Success queries: $SUCCESS_COUNT"
echo "❌ Fail queries: $FAIL_COUNT"

[[ $FAIL_COUNT -gt 0 ]] && echo "📄 See errors in: $LOG_FILE"
