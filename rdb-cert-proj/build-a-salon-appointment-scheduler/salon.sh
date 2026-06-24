#!/bin/bash

PSQL="psql -X -U freecodecamp -d salon --no-align -t -c"

echo -e "\n~~~~~ MY SALON ~~~~~\n"

SERVICE_CUSTOMER() {
  #ask for phone number
  echo -e "\nWhat's your phone number?"
  read CUSTOMER_PHONE
  
  CUSTOMER_NAME="$($PSQL "SELECT name FROM customers WHERE phone = '$CUSTOMER_PHONE'")"
  #if no record
  if [[ -z $CUSTOMER_NAME ]]
  then 
    #create new record with name
    echo -e "\nI don't have a record for that phone number, what's your name?"
    read CUSTOMER_NAME

    $PSQL "INSERT INTO customers (name, phone) VALUES ('$CUSTOMER_NAME', '$CUSTOMER_PHONE')" > /dev/null
  fi
  
  #ask for time
  echo -e "\nWhat time would you like your cut, $CUSTOMER_NAME?"
  read SERVICE_TIME

  #insert
  $PSQL "INSERT INTO appointments (customer_id, service_id, time) VALUES ((SELECT customer_id FROM customers WHERE name = '$CUSTOMER_NAME'), (SELECT service_id FROM services WHERE name = '$1'), '$SERVICE_TIME')" > /dev/null
  echo -e "\nI have put you down for a $1 at $SERVICE_TIME, $CUSTOMER_NAME."
}

MAIN_MENU() {
  echo Welcome to My Salon, how can I help you?
  echo

  #read services
  if [[ $1 ]]
  then
    echo $1
  fi
  
  GET_SERVICES_RESULT="$($PSQL "SELECT service_id, name FROM services")"
  
  echo "$GET_SERVICES_RESULT" | while IFS="|" read -r SERVICE_ID SERVICE_NAME
  do
    echo "$SERVICE_ID) $SERVICE_NAME"
  done

  read SERVICE_ID_SELECTED
  SERVICE_NAME="$($PSQL "SELECT name FROM services WHERE service_id = '$SERVICE_ID_SELECTED'")"

  if [[ -z $SERVICE_NAME ]] 
  then 
    MAIN_MENU "I could not find that service. What would you like today?" 
  else
    # echo "$SERVICE_ID_SELECTED $SERVICE_NAME"
    SERVICE_CUSTOMER $SERVICE_NAME
  fi
}

MAIN_MENU 