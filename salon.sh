#!/bin/bash

PSQL="psql --username=freecodecamp --dbname=salon --tuples-only -c"

echo -e "\n~~~~~ MY SALON ~~~~~"

MAIN_MENU() {
  if [[ $1 ]]
  then
    echo $1
  else
    echo -e "\nWelcome to My Salon, how can I help you?\n"
  fi
  # show services
  echo "$($PSQL "SELECT service_id,name FROM services")" | while read SERVICE_ID BAR SERVICE_NAME
  do
    echo "$SERVICE_ID) $SERVICE_NAME"
  done
  read SERVICE_ID_SELECTED
  # if service isn't a number
  if [[ ! $SERVICE_ID_SELECTED =~ ^[0-9]+$ ]]
  then
    # send to main menu
    MAIN_MENU "I could not find that service. What would you like today?"
  else
  
    # get service name
    SERVICE_NAME=$($PSQL "SELECT name FROM services WHERE service_id=$SERVICE_ID_SELECTED")

    # if service doesn't exist
    if [[ -z $SERVICE_NAME ]]
    then
      # send to main menu
      MAIN_MENU "I could not find that service. What would you like today?"
    else
      echo "What's your phone number?"
      read CUSTOMER_PHONE

      # get customer name
      CUSTOMER_NAME=$($PSQL "SELECT name FROM customers WHERE phone='$CUSTOMER_PHONE'")

      # if customer names does't exist
      if [[ -z $CUSTOMER_NAME ]]
      then
        echo "I don't have a record for that phone number, what's your name?"
        read CUSTOMER_NAME

        # Add name and phone to customers table
        CUSTOMER_RESULT=$($PSQL "INSERT INTO customers(phone,name) VALUES('$CUSTOMER_PHONE','$CUSTOMER_NAME')")
      fi
      echo "What time would you like your $SERVICE_NAME, $CUSTOMER_NAME?"
      read SERVICE_TIME

      # get customer id
      CUSTOMER_ID=$($PSQL "SELECT customer_id FROM customers WHERE phone='$CUSTOMER_PHONE'")

      # insert an appointment
      APPOINTMENT_RESULT=$($PSQL "INSERT INTO appointments(customer_id,service_id, time) VALUES($CUSTOMER_ID,$SERVICE_ID_SELECTED,'$SERVICE_TIME')")

      if [[ $APPOINTMENT_RESULT == 'INSERT 0 1' ]]
      then
        echo -e "\nI have put you down for a $SERVICE_NAME at $SERVICE_TIME, $CUSTOMER_NAME."
      fi
    fi
  fi
}

MAIN_MENU
