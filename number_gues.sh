#! /bin/bash

PSQL="psql -X -U freecodecamp -d number_guess -t --no-align -c"

echo -e "\nEnter your username:"
read USERNAME

if [[ -z $USERNAME || $USERNAME =~ ^[0-9]+$ ]]
then
  echo "Please enter a username"
else
  USERNAME_CHECK=$($PSQL "SELECT name FROM users WHERE name='$USERNAME'")
  if [[ -z $USERNAME_CHECK ]]
  then
    INSERT_USERNAME=$($PSQL "INSERT INTO users (name) VALUES('$USERNAME')")
    echo -e "\nWelcome, $(echo $USERNAME | sed -e 's/^* | *$//g')! It looks like this is your first time here."
  else
    PLAYED_COUNT=$($PSQL "SELECT played_count FROM users WHERE name='$USERNAME'")
    BEST_GUESS=$($PSQL "SELECT user_best_guess FROM users WHERE name='$USERNAME'")
    echo -e "\nWelcome back, $(echo $USERNAME | sed -e 's/^* | *$//g')! You have played $PLAYED_COUNT games, and your best game took $BEST_GUESS guesses."
    
    fi
    echo -e "\nGuess the secret number between 1 and 1000:"
    RANGE=$((1000-1+1))
    RANDOM_GENERATED_NUMBER=$(($(($RANDOM%$RANGE))+1))
    IS_DONE=1
    RANDOM_NUMBER_GAME() {
      if [[ $1 ]]
      then
        echo -e "\n$1"
      fi
      read GUESSED_NUMBER
      GUESSED_COUNTER=$((GUESSED_COUNTER + 1 ))
      if [[ -z $GUESSED_NUMBER || ! $GUESSED_NUMBER =~ ^[0-9]+$ ]]
      then
        RANDOM_NUMBER_GAME "That is not an integer, guess again:"
      else
        if [[ $RANDOM_GENERATED_NUMBER -lt $GUESSED_NUMBER ]]
        then
          RANDOM_NUMBER_GAME "It's lower than that, guess again:"
        elif [[ $RANDOM_GENERATED_NUMBER -gt $GUESSED_NUMBER ]]
        then
          RANDOM_NUMBER_GAME "It's higher than that, guess again:"
        else
          echo -e "\nYou guessed it in $GUESSED_COUNTER tries. The secret number was $RANDOM_GENERATED_NUMBER. Nice job!"
          IS_DONE=0
        fi
      fi
    }

    if [[ $IS_DONE -eq 1 ]]
    then
      RANDOM_NUMBER_GAME
    fi

    PLAYED_TIME_COUNT=$($PSQL "SELECT played_count FROM users WHERE name='$USERNAME'")
    PLAYED_TIME_COUNT=$(( PLAYED_TIME_COUNT + 1))

    GUESSED_COUNTER_CHECK=$($PSQL "SELECT user_best_guess FROM users WHERE name='$USERNAME'")
    if [[ -z $GUESSED_COUNTER_CHECK ]]
    then
      GUESSED_COUNTER_CHECK=1001
    fi
    if [[ $GUESSED_COUNTER_CHECK -gt $GUESSED_COUNTER ]]
    then
      UPDATE_PLAYED_COUNT=$($PSQL "UPDATE users SET played_count=$PLAYED_TIME_COUNT WHERE name='$USERNAME'")
      UPDATE_GUESS_COUNT=$($PSQL "UPDATE users SET user_best_guess = $GUESSED_COUNTER WHERE name='$USERNAME'")
    else
      UPDATE_PLAYED_COUNT=$($PSQL "UPDATE users SET played_count=$PLAYED_TIME_COUNT WHERE name='$USERNAME'")
    fi
fi


