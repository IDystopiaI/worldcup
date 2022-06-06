#! /bin/bash

if [[ $1 == "test" ]]
then
  PSQL="psql --username=postgres --dbname=worldcuptest -t --no-align -c"
else
  PSQL="psql --username=freecodecamp --dbname=worldcup -t --no-align -c"
fi

# Do not change code above this line. Use the PSQL variable above to query your database.

# start tables fresh
echo $($PSQL "TRUNCATE teams, games")

# open file and pipe values
cat games.csv | while IFS="," read YEAR ROUND WINNER OPPONENT WINNER_GOALS OPPONENT_GOALS
do
# echo "$YEAR $ROUND $WINNER $OPPONENT $WINNER_GOALS $OPPONENT_GOALS"
# filling in teams table
# filter out first line .. if $winner != 'winner' then... fi

  if [[ $WINNER != "winner" ]]
  then
    # select winner_id
    WINNER_ID=$($PSQL "SELECT team_id from teams WHERE name = '$WINNER'")

    # if null insert winner
    if [[ -z $WINNER_ID ]]
    then
      INSERT_WINNER=$($PSQL "INSERT INTO teams(name) VALUES('$WINNER')")
          # make better feedback
      # if [[ $INSERT_WINNER == "INSERT 0 1" ]]
      # then
        echo Inserted winner: $WINNER
      # fi
  
      # get WINNER_ID for games table
      WINNER_ID=$($PSQL "SELECT team_id FROM teams WHERE name='$WINNER'")
    fi
    # echo winner $WINNER_ID
  fi
  
# repeat for opponent
  if [[ $OPPONENT != 'opponent' ]]
  then
  # select statement to see if OPPONENT_ID exists
  OPPONENT_ID=$($PSQL "SELECT team_id FROM teams WHERE name='$OPPONENT'")
  # echo $OPPONENT_ID

  # if opponent_id is null insert $OPPONENT
    if [[ -z $OPPONENT_ID ]]
    then
      INSERT_OPPONENT=$($PSQL "INSERT INTO teams(name) VALUES('$OPPONENT')")
      OPPONENT_ID=$($PSQL "SELECT team_id FROM teams WHERE name='$OPPONENT'")
      # feedback if opponent is inserted
      if [[ $INSERT_OPPONENT == "INSERT 0 1" ]]
      then
      echo Inserted opponenent: $OPPONENT
      fi
    fi


# echo winner: $WINNER_ID opponent: $OPPONENT_ID

# above script inserts correct number of teams

# begin working on games table
# year round winner_goals opponent_goals [fkey winner_id] [fkey opponent_id]
# place inside first if clause so that there is no null insert when $WINNER == 'winner'
  GAME_INSERT=$($PSQL "INSERT INTO games(year, round, winner_goals, opponent_goals, winner_id, opponent_id) VALUES($YEAR, '$ROUND', $WINNER_GOALS, $OPPONENT_GOALS, $WINNER_ID, $OPPONENT_ID)")
  # echo "$GAME_INSERT"
  fi
done
