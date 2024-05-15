#!/bin/bash

PSQL="psql --username=freecodecamp --dbname=number_guess -t --no-align -c"

#prompt the user for a username
echo "Enter your username:"
read USERNAME

#check if username is less or equal than 22 char 
NUMBER_CHARS=${#USERNAME}
if [[ $NUMBER_CHARS -le 22 ]]
then
  #username has not been used before
  SELECTED_NAME=$($PSQL "SELECT username FROM users WHERE username='$USERNAME'")
  if [[ -z $SELECTED_NAME ]]
  then
    echo -e "\nWelcome, $USERNAME! It looks like this is your first time here."
    #insert new user
    INSERT_NEW_USER=$($PSQL "INSERT INTO users(username, games_played) VALUES('$USERNAME', 1)")
  else
    BEST_GAME=$($PSQL "SELECT best_game FROM users WHERE username='$USERNAME'")
    GAMES_PLAYED=$($PSQL "SELECT games_played FROM users WHERE username='$USERNAME'")
    echo -e "\nWelcome back, $USERNAME! You have played $GAMES_PLAYED games, and your best game took $BEST_GAME guesses."
  fi
else
  echo "Please enter username that have 22 char max"
  read USERNAME
fi

echo -e "\nGuess the secret number between 1 and 1000:"
read GUESS_NUMBER

SECRET_NUMBER=$(($RANDOM%(1000)+1))

number_of_guesses=1

until [[ $GUESS_NUMBER -eq $SECRET_NUMBER ]]
do
  #increment number_of_guesses
  number_of_guesses=$(($number_of_guesses + 1))
  #input is not a number
  if [[ ! $GUESS_NUMBER =~ ^[0-9]+$ ]]
  then
    echo -e "\nThat is not an integer, guess again:"
  #if guess number is higher than the secret number
  else
    if [[ $GUESS_NUMBER -ge $SECRET_NUMBER ]]
    then
      echo -e "\nIt's lower than that, guess again:"
    #if guess number is lower than the secret number  
    else
      echo -e "\nIt's higher than that, guess again:"
    fi
  fi
  read GUESS_NUMBER
done

#update first best_game
if [[ -z $SELECTED_NAME ]]
then
  BEST_GAMES_UPDATED=$($PSQL "UPDATE users SET best_game=$number_of_guesses WHERE username='$USERNAME'")
fi

#update best_game if number_of_guesses is lower than best games number
if [[ $number_of_guesses -lt $BEST_GAME ]]
then
  BEST_GAMES_UPDATED=$($PSQL "UPDATE users SET best_game=$number_of_guesses WHERE username='$USERNAME'")
fi

#update games_played
GAMES_PLAYED=$(($GAMES_PLAYED + 1))
GAMES_PLAYED_UPDATED=$($PSQL "UPDATE users SET games_played=$GAMES_PLAYED WHERE username='$USERNAME'")

echo -e "\nYou guessed it in $number_of_guesses tries. The secret number was $GUESS_NUMBER. Nice job!"