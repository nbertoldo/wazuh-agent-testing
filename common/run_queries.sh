#!/bin/bash

QUERY_FILE="$1"
OUTPUT_DIR="/vagrant/results"
HOSTNAME="$(hostname)"
OUTPUT_FILE="${OUTPUT_DIR}/system_info_${HOSTNAME}.json"
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

  # Extract the table name from the query
  # This assumes the table name is after the "FROM" keyword
  # and is a simple alphanumeric identifier.
  TABLE_NAME=$(echo "$QUERY" | grep -oiE "FROM +[a-zA-Z0-9_]+" | awk '{print $2}')

  # Run the query using osqueryi
  RESULT=$(osqueryi --json "$QUERY" 2> /tmp/osquery_error)
  EXIT_CODE=$?

  if [[ $EXIT_CODE -eq 0 ]]; then
    ESCAPED_QUERY=$(echo "$QUERY" | sed 's/"/\\"/g')

    [[ $FIRST -eq 0 ]] && echo "," >> "$OUTPUT_FILE"
    echo "  {\"table_name\": \"${TABLE_NAME}\", \"query\": \"${ESCAPED_QUERY}\", \"rows\": $RESULT}" >> "$OUTPUT_FILE"
    FIRST=0
    ((SUCCESS_COUNT++))
  else
    echo "[ERROR] Execution of query #$QUERY_NUM failed" | tee -a "$LOG_FILE"
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
