#! /bin/bash
PSQL="psql -X --username=postgres --dbname=salon --tuples-only -c"
echo "~~~~~ MY SALON ~~~~~"
echo -E "\nWelcome to My Salon, how can I help you?"
SERVICES=$($PSQL "SELECT service_id, name FROM services ORDER BY service_id")
echo "$SERVICES"| while read SERVICE_ID BAR SERVICE_NAME
do 
  echo "$SERVICE_ID) $SERVICE_NAME"
done  

while true;
do
  read SERVICE_ID_SELECTED
  SERVICE_NAME=$($PSQL "SELECT name FROM services WHERE service_id=$SERVICE_ID_SELECTED")
  if [[ -z $SERVICE_NAME ]]; then
    echo "I could not find that service. What would you like today?"
    echo "$SERVICES" | while read SERVICE_ID BAR SERVICE_NAME
     do
      echo "$SERVICE_ID) $SERVICE_NAME"
     done
  else
    break
  fi
done
echo "What's your phone number?"
read CUSTOMER_PHONE
CUSTOMER_NAME=$($PSQL "SELECT name FROM customers WHERE phone='$CUSTOMER_PHONE'")

if [[ -z $CUSTOMER_NAME ]]; then
  # New customer, ask for their name
  echo "It looks like you're a new customer. What's your name?"
  read CUSTOMER_NAME

  # Insert new customer
  INSERT_CUSTOMER_RESULT=$($PSQL "INSERT INTO customers(name, phone) VALUES('$CUSTOMER_NAME', '$CUSTOMER_PHONE')")
fi
CUSTOMER_ID=$($PSQL "SELECT customer_id FROM customers WHERE phone='$CUSTOMER_PHONE'")
echo "What time would you like your $SERVICE_NAME, $CUSTOMER_NAME"
read SERVICE_TIME

INSERT_APPOINTMENT_RESULT=$($PSQL "INSERT INTO appointments(customer_id, service_id, time) VALUES($CUSTOMER_ID, $SERVICE_ID_SELECTED, '$SERVICE_TIME')")

if [[ $INSERT_APPOINTMENT_RESULT == "INSERT 0 1" ]]; then
  echo "I have put you down for a $SERVICE_NAME at $SERVICE_TIME, $CUSTOMER_NAME."
fi