#!/bin/bash


SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

JAR_FILE="$SCRIPT_DIR/paper-1.21.4-147.jar"
LOG_FILE="$SCRIPT_DIR/paper_logs.log"

if [[ -f "$JAR_FILE" ]]; then
  java -Xms1G -Xmx1G -jar "$JAR_FILE" --nogui
fi
