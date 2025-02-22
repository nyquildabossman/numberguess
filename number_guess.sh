#!/bin/bash

PSQL="psql --username=freecodecamp --dbname=<database_name> -t --no-align -c"

ASK_USERNAME(){
  echo -e "\nEnter your username:"
  read USERNAME

  USERNAME_CHARACTERS=$(echo $USERNAME | wc -c)
  if [[ $USERNAME_CHARACTERS -gt 22 ]]
  then
    ASK_USERNAME
  fi
}
ASK_USERNAME
RETURNING_USER=$($PSQL "SELECT username FROM users WHERE username = '$USERNAME'")
# RETURNING_USER_HAS_ONE=$($PSQL "SELECT COUNT(*) FROM users INNER JOIN games USING(user_id) WHERE username = '$USERNAME'")
if [[ -z $RETURNING_USER ]]
then
  INSERTED_USER=$($PSQL "INSERT INTO users (username) VALUES ('$USERNAME')")
  echo -e "\nWelcome, $USERNAME! It looks like this is your first time here."

else
  GAMES_PLAYED=$($PSQL "SELECT COUNT(*) FROM games INNER JOIN users USING(user_id) WHERE username = '$USERNAME'")
  BEST_GAME=$($PSQL "SELECT MIN(guesses) FROM games INNER JOIN users USING(user_id) WHERE username = '$USERNAME'")
  GAMES=$(if [[ $GAMES_PLAYED -eq 1 ]]; then echo "game"; else echo "games"; fi)
  GUESSES=$(if [[ $BEST_GAME -eq 1 ]]; then echo "guess"; else echo "guesses"; fi)
  echo -e "\nWelcome back, $USERNAME! You have played $GAMES_PLAYED games, and your best game took $BEST_GAME guesses."
fi