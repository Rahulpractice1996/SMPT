#!/bin/bash

# Add MySQL to PATH (for Windows Git Bash)
export PATH=$PATH:"/c/Program Files/MySQL/MySQL Server 8.0/bin"

# Configuration
DB_HOST="192.168.1.76"
DB_PORT="3308"
DB_USER="admin"
DB_PASS="QAZwsx@1234"
DB_NAME="hapserviceticketlive"
CSV_FILE="/D/schedular_report.csv"

# Email Details
MAIL_TO="recipient@example.com"
MAIL_SUBJECT="Schedular Report - $(date +%Y-%m-%d)"

# Gmail SMTP via Stunnel
SMTP_SERVER="localhost"
SMTP_PORT="465"
SMTP_USER="blesson.connect@gmail.com"
SMTP_PASS="cayg vfvj nnoq jhyp"
SMTP_FROM="blesson.connect@gmail.com"

# SQL Query
SQL_QUERY="SELECT SCHEDULAR_ID, SCHEDULAR_NAME, ORDER_SEQ, CATEGORY, DATE(LastExecutedOn)
FROM master_schedular
WHERE status='A' AND DATE(LastExecutedOn) <> CURDATE()
ORDER BY ORDER_SEQ ASC;"

# Create CSV with header
echo "SCHEDULAR_ID,SCHEDULAR_NAME,ORDER_SEQ,CATEGORY,LastExecutedOn" > "$CSV_FILE"

# Run query and append results to CSV
mysql -h "$DB_HOST" -P "$DB_PORT" -u "$DB_USER" -p"$DB_PASS" -D "$DB_NAME" -e "$SQL_QUERY" \
| sed '1d' | sed 's/\t/,/g' >> "$CSV_FILE"

# Check if CSV has more than just the header
if [ $(wc -l < "$CSV_FILE") -gt 1 ]; then
    # Send email using Blat with raw string body
    "C:/blat/blat/full/blat.exe" -body "Please find attached the schedular report." \
    -to "$MAIL_TO" \
    -subject "$MAIL_SUBJECT" \
    -attach "$CSV_FILE" \
    -server "$SMTP_SERVER" -port "$SMTP_PORT" \
    -u "$SMTP_USER" -pw "$SMTP_PASS" \
    -f "$SMTP_FROM"

    echo " Email sent to $MAIL_TO with CSV attachment."
else
    echo " No data to send. Query returned no results."
fi