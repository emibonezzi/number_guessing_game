#!/bin/bash

PSQL="psql --username=freecodecamp --dbname=users -t --no-align -c"

# generate random number
CORRECT_NUMBER=$(($RANDOM % 1000 + 1))

echo "$CORRECT_NUMBER"

# current guesses 
NUMBER_OF_GUESSES=$((0))

echo "Enter your username:"
read USERNAME_INPUT

# check if user exists
IS_USER_FOUND=$($PSQL "SELECT username, games_played, best_game FROM users WHERE username='$USERNAME_INPUT'")

# if user not found
if [[ -z $IS_USER_FOUND ]]
then
  echo "Welcome, $USERNAME_INPUT! It looks like this is your first time here."
  INSERT_USER=$($PSQL "INSERT INTO users(username) VALUES('$USERNAME_INPUT')")
else
  # loop through result
  echo $IS_USER_FOUND | while IFS="|" read USERNAME GAMES_PLAYED BEST_GAME
  do
    echo "Welcome back, $USERNAME! You have played $GAMES_PLAYED games, and your best game took $BEST_GAME guesses."
  done
fi

echo "Guess the secret number between 1 and 1000:"
read NUMBER_GUESSED
NUMBER_OF_GUESSES=$(($NUMBER_OF_GUESSES + 1))

# while answer is not correct
while [[ $NUMBER_GUESSED -ne $CORRECT_NUMBER ]]
do
  # while input is not an integer
  while [[ ! $NUMBER_GUESSED =~ ^[0-9]*$ ]]
  do
    # keep asking
    echo "That is not an integer, guess again:"
    read NUMBER_GUESSED
  done

  #if number is lower
  if [[ ! $NUMBER_GUESSED -lt $CORRECT_NUMBER ]]
  then
    # keep asking
    echo "It's lower than that, guess again:"
    # increase guesses counter
    NUMBER_OF_GUESSES=$(($NUMBER_OF_GUESSES + 1))
    read NUMBER_GUESSED
  else
    # if higher keep asking
    echo "It's higher than that, guess again:"
    # increase guesses counter
    NUMBER_OF_GUESSES=$(($NUMBER_OF_GUESSES + 1))
    read NUMBER_GUESSED
  fi
done

#if user is correct
echo "You guessed it in $NUMBER_OF_GUESSES tries. The secret number was $CORRECT_NUMBER. Nice job!"

# retrieve stats
TOTAL_GAMES_PLAYED_BY_USER=$($PSQL "SELECT games_played FROM users WHERE username='$USERNAME_INPUT'")
BEST_GAME_BY_USER=$($PSQL "SELECT best_game FROM users WHERE username='$USERNAME_INPUT'")

# add current game to games played by user 
UPDATED_GAMES=$(( $TOTAL_GAMES_PLAYED_BY_USER + 1 ))
UPDATE_GAMES_NUMBER=$($PSQL "UPDATE users SET games_played=$UPDATED_GAMES WHERE username='$USERNAME_INPUT'")

# check if user has beaten his personal record
if [[ -z $BEST_GAME_BY_USER ]]
then
    UPDATE_RECORD=$($PSQL "UPDATE users SET best_game=$NUMBER_OF_GUESSES WHERE username='$USERNAME_INPUT'")
elif [[ $BEST_GAME_BY_USER -ge $NUMBER_OF_GUESSES ]]
then
# update record
  UPDATE_RECORD=$($PSQL "UPDATE users SET best_game=$NUMBER_OF_GUESSES WHERE username='$USERNAME_INPUT'")
fi
