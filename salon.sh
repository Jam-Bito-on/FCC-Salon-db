#!/bin/bash

PSQL="psql --username=freecodecamp --dbname=salon -t --no-align -c"

echo -e "\n~~~~~ Welcome to the Salon Appointment Scheduler ~~~~~\n"

# Function to show available services
SHOW_SERVICES() {
  echo "Available Services:"
  SERVICES=$($PSQL "SELECT service_id, name FROM services ORDER BY service_id")
  echo "$SERVICES" | while IFS="|" read SERVICE_ID SERVICE_NAME; do
    echo "$SERVICE_ID) $SERVICE_NAME"
  done
}

# Ask for service selection
while true; do
  SHOW_SERVICES
  echo -e "\nPlease enter the service ID you want:"
  read SERVICE_ID_SELECTED

  SERVICE_NAME=$($PSQL "SELECT name FROM services WHERE service_id=$SERVICE_ID_SELECTED")

  if [[ -z $SERVICE_NAME ]]; then
    echo -e "\nInvalid selection. Please choose a valid service ID."
  else
    break
  fi
done

# Get customer phone number
echo -e "\nEnter your phone number:"
read CUSTOMER_PHONE

CUSTOMER_INFO=$($PSQL "SELECT customer_id, name FROM customers WHERE phone='$CUSTOMER_PHONE'")
if [[ -z $CUSTOMER_INFO ]]; then
  # New customer
  echo -e "\nYou're a new customer! What is your name?"
  read CUSTOMER_NAME
  $PSQL "INSERT INTO customers (name, phone) VALUES ('$CUSTOMER_NAME', '$CUSTOMER_PHONE')"
  CUSTOMER_ID=$($PSQL "SELECT customer_id FROM customers WHERE phone='$CUSTOMER_PHONE'")
else
  # Existing customer
  CUSTOMER_ID=$(echo $CUSTOMER_INFO | cut -d '|' -f1)
  CUSTOMER_NAME=$(echo $CUSTOMER_INFO | cut -d '|' -f2)
fi

# Get appointment time
echo -e "\nEnter the appointment time:"
read SERVICE_TIME

# Insert appointment
$PSQL "INSERT INTO appointments (customer_id, service_id, time) VALUES ($CUSTOMER_ID, $SERVICE_ID_SELECTED, '$SERVICE_TIME')"

# Confirmation message
echo -e "\nI have put you down for a $SERVICE_NAME at $SERVICE_TIME, $CUSTOMER_NAME."
