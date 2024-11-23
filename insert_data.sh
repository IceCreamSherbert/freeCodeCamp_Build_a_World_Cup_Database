#! /bin/bash

if [[ $1 == "test" ]]
then
  PSQL="psql --username=postgres --dbname=worldcuptest -t --no-align -c"
else
  PSQL="psql --username=freecodecamp --dbname=worldcup -t --no-align -c"
fi

# Do not change code above this line. Use the PSQL variable above to query your database.
# ------------------------------
# games- game_id, year, round, winner_goals, opponent_goals, winner_id, opponent_id
# teams- team_id, name

# delete previous data
echo "$($PSQL "TRUNCATE TABLE games, teams")"
echo -e "data cleared\n"

# read games.csv and set variables
cat games.csv | while IFS="," read YEAR ROUND WINNER OPPONENT WINNER_GOALS OPPONENT_GOALS
do
  # skips the first row of games.csv
  if [[ "$WINNER" != "winner" ]]
  then
    # get the winner_id if it already exists in a table
    WINNER_ID=$($PSQL "SELECT team_id FROM teams WHERE name='$WINNER'")
    # if winner_id isn't already in a table, add it:
    if [[ -z $WINNER_ID ]]
    then
      # insert unique team into teams
      INSERT_WINNER=$($PSQL "INSERT INTO teams(name) VALUES('$WINNER')")
      if [[ $INSERT_WINNER == "INSERT 0 1" ]]
      then
        echo "Inserted $WINNER into teams"
      fi
      # set the winner id to the new team
      WINNER_ID=$($PSQL "SELECT team_id FROM teams WHERE name='$WINNER'")
    fi

    # get the opponent_id if it already exists in a table
    OPPONENT_ID=$($PSQL "SELECT team_id FROM teams WHERE name='$OPPONENT'")
    # if opponent_id isn't already in a table, add it:
    if [[ -z $OPPONENT_ID ]]
    then
      # insert unique team into teams
      INSERT_OPPONENT=$($PSQL "INSERT INTO teams(name) VALUES('$OPPONENT')")
      if [[ $INSERT_OPPONENT == "INSERT 0 1" ]]
      then
        echo "Inserted $OPPONENT into teams"
      fi
      # set the opponent id to the new team
      OPPONENT_ID=$($PSQL "SELECT team_id FROM teams WHERE name='$OPPONENT'")
    fi

    # adding game data
    INSERT_GAME=$($PSQL "INSERT INTO games(year, round, winner_goals, opponent_goals, winner_id, opponent_id) VALUES($YEAR, '$ROUND', $WINNER_GOALS, $OPPONENT_GOALS, $WINNER_ID, $OPPONENT_ID)")
    if [[ $INSERT_GAME == "INSERT 0 1" ]]
    then
      echo "Inserted $YEAR, $ROUND, $WINNER_GOALS, $OPPONENT_GOALS, $WINNER_ID, $OPPONENT_ID into games"
    fi
  fi
done

echo -e "\n~~ Complete ~~\n"
