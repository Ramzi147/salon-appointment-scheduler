#!/bin/bash
PSQL="psql --username=freecodecamp --dbname=salon --no-align --tuples-only --quiet -c"
echo "Welcome to My Salon, how can I help you?"
while true; do
  $PSQL "SELECT service_id, name FROM services ORDER BY service_id" | while IFS='|' read -r SERVICE_ID SERVICE_NAME; do
    echo "$SERVICE_ID) $SERVICE_NAME"
  done
  read SERVICE_ID_SELECTED || exit 0
  if [[ $SERVICE_ID_SELECTED =~ ^[0-9]+$ ]]; then
    SERVICE_NAME=$($PSQL "SELECT name FROM services WHERE service_id = $SERVICE_ID_SELECTED")
    [[ -n $SERVICE_NAME ]] && break
  fi
  echo "I could not find that service. What would you like today?"
done
echo "What is your phone number?"
read CUSTOMER_PHONE || exit 0
PHONE_SQL=$(printf '%s' "$CUSTOMER_PHONE" | sed "s/'/''/g")
CUSTOMER_ID=$($PSQL "SELECT customer_id FROM customers WHERE phone = '$PHONE_SQL'")
if [[ -z $CUSTOMER_ID ]]; then
  echo "What is your name?"
  read CUSTOMER_NAME || exit 0
  NAME_SQL=$(printf '%s' "$CUSTOMER_NAME" | sed "s/'/''/g")
  CUSTOMER_ID=$($PSQL "INSERT INTO customers(name, phone) VALUES ('$NAME_SQL', '$PHONE_SQL') RETURNING customer_id")
else
  CUSTOMER_NAME=$($PSQL "SELECT name FROM customers WHERE customer_id = $CUSTOMER_ID")
fi
echo "What time would you like your $SERVICE_NAME, $CUSTOMER_NAME?"
read SERVICE_TIME || exit 0
TIME_SQL=$(printf '%s' "$SERVICE_TIME" | sed "s/'/''/g")
$PSQL "INSERT INTO appointments(customer_id, service_id, time) VALUES ($CUSTOMER_ID, $SERVICE_ID_SELECTED, '$TIME_SQL')" > /dev/null
echo "I have put you down for a $SERVICE_NAME at $SERVICE_TIME, $CUSTOMER_NAME."
