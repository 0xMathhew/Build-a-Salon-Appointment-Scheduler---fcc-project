#!/bin/bash
PSQL="psql --username=freecodecamp --dbname=salon --tuples-only -c"


echo -e "\n~~~~~ Best Cut ~~~~~\n"
echo -e "Welcome to Best Cut, how can i help you?\n"

PRINT_SERVICE_LIST(){
  
   # get list of services from database
  SERVICES_LIST=$($PSQL "SELECT service_id, name FROM services")

    # Find all the rows starting with a number using grep,
    # modify output with sed 
    # read variables in while loop and print
    echo "$SERVICES_LIST" | grep -E '^[[:space:]]*[0-9]+.*$' | sed -e 's/^[[:space:]]*//;s/ |/)/' | while read SERVICE_ID SERVICE_NAME
  do
    echo $SERVICE_ID $SERVICE_NAME
  done
}

SERVICE_LIST(){

 PRINT_SERVICE_LIST

 #get user service
 read SERVICE_ID_SELECTED

    # check service availibility
    CHECK_SERVICE=$($PSQL "SELECT service_id FROM services WHERE service_id=$SERVICE_ID_SELECTED")
    echo $CHECK_SERVICE
    if [[ -z $CHECK_SERVICE ]]; then
      echo "I could not find that service. What would you like today?"
      SERVICE_LIST
    else
    # get user phone number
      echo -e "\nWhat's your phone number?"
      read CUSTOMER_PHONE
      # get customer name from database using his phone
      CUSTOMER_NAME=$($PSQL "SELECT name FROM customers WHERE phone='$CUSTOMER_PHONE'")
      if [[ -z $CUSTOMER_NAME ]]; then
        echo -e "\nI don't have a record for that phone number, what's your name?"
        read CUSTOMER_NAME
        # insert customer into database
        INSERT_CUSTOMER_DATA=$($PSQL "INSERT INTO customers(phone, name) VALUES('$CUSTOMER_PHONE', '$CUSTOMER_NAME')")
      fi
        echo -e "\nWhat time would you like your cut, $CUSTOMER_NAME?"
        read SERVICE_TIME

        GET_CUSTOMER_ID=$($PSQL "SELECT customer_id FROM customers WHERE phone='$CUSTOMER_PHONE'")
        INSERT_CUSTOMER_APPOINTMENT=$($PSQL "INSERT INTO appointments(time, customer_id, service_id) VALUES('$SERVICE_TIME', $GET_CUSTOMER_ID, $SERVICE_ID_SELECTED)")
        GET_CUSTOMER_SERVICE_NAME=$($PSQL "SELECT name FROM services WHERE service_id=$SERVICE_ID_SELECTED")

        echo -e "\nI have put you down for a $GET_CUSTOMER_SERVICE_NAME at $SERVICE_TIME, $CUSTOMER_NAME.\n"
    fi
 
}

SERVICE_LIST
