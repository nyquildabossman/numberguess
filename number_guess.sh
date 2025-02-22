#!/bin/bash

PSQL="psql --username=freecodecamp --dbname=number_guess --no-align --tuples-only -c"
SECRET_NUMBER=$(( RANDOM % 1000 + 1 ))

ASK_USERNAME() {
  echo -e "\nEnter your username:"
  read USERNAME

  if [[ ${#USERNAME} -gt 22 ]]; then
    ASK_USERNAME
  fi
}
ASK_USERNAME

RETURNING_USER=$($PSQL "SELECT username FROM users WHERE username = '$USERNAME'")

if [[ -z "$RETURNING_USER" ]]; then
  INSERTED_USER=$($PSQL "INSERT INTO users (username) VALUES ('$USERNAME')")
  echo -e "\nWelcome, $USERNAME! It looks like this is your first time here."
else
  GAMES_PLAYED=$($PSQL "SELECT COUNT(*) FROM games INNER JOIN users USING(user_id) WHERE username = '$USERNAME'")
  BEST_GAME=$($PSQL "SELECT MIN(guesses) FROM games INNER JOIN users USING(user_id) WHERE username = '$USERNAME'")

  if [[ -z "$BEST_GAME" ]]; then
    BEST_GAME=0
  fi

  echo -e "\nWelcome back, $USERNAME! You have played $GAMES_PLAYED games, and your best game took $BEST_GAME guesses."
fi

USER_ID=$($PSQL "SELECT user_id FROM users WHERE username = '$USERNAME'")

TRIES=0
GUESS=0

GUESSING_MACHINE() {
  while true; do
    read GUESS

    if ! [[ "$GUESS" =~ ^[0-9]+$ ]]; then
      echo -e "\nThat is not an integer, guess again:"
      continue
    fi

    TRIES=$((TRIES + 1))

    if [[ $GUESS -gt $SECRET_NUMBER ]]; then
      echo -e "\nIt's lower than that, guess again:"
    elif [[ $GUESS -lt $SECRET_NUMBER ]]; then
      echo -e "\nIt's higher than that, guess again:"
    else
      break
    fi
  done
}

echo -e "\nGuess the secret number between 1 and 1000:"
GUESSING_MACHINE

INSERTED_GAME=$($PSQL "INSERT INTO games (user_id, guesses) VALUES ($USER_ID, $TRIES)")

PLURAL_TRIES=$(if [[ $TRIES -eq 1 ]]; then echo "try"; else echo "tries"; fi)
echo -e "\nYou guessed it in $TRIES tries. The secret number was $SECRET_NUMBER. Nice job!"
