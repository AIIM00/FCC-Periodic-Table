#!/bin/bash

# Check if an argument is provided
if [[ -z $1 ]]; then
  echo "Please provide an element as an argument."
  exit 0
fi

# Set up the PSQL command (no space around =)
PSQL="psql --username=freecodecamp --dbname=periodic_table -t --no-align -c"

# Detect input type: atomic_number, symbol, or name
if [[ $1 =~ ^[0-9]+$ ]]; then
  CONDITION="atomic_number = $1"
elif [[ $1 =~ ^[A-Z][a-z]?$ ]]; then
  CONDITION="symbol = '$1'"
else
  CONDITION="name = '$1'"
fi

# Query the database for the element
ELEMENT=$($PSQL "SELECT atomic_number, name, symbol, types.type, atomic_mass, melting_point_celsius, boiling_point_celsius
FROM elements
INNER JOIN properties USING(atomic_number)
INNER JOIN types USING(type_id)
WHERE $CONDITION;")

# If no element was found
if [[ -z $ELEMENT ]]; then
  echo "I could not find that element in the database."
  exit 0
fi

# Parse the result into variables
IFS="|" read ATOMIC_NUMBER NAME SYMBOL TYPE MASS MELT BOIL <<< "$ELEMENT"

# Print the formatted output
echo "The element with atomic number $ATOMIC_NUMBER is $NAME ($SYMBOL). It's a $TYPE, with a mass of $MASS amu. $NAME has a melting point of $MELT celsius and a boiling point of $BOIL celsius."
