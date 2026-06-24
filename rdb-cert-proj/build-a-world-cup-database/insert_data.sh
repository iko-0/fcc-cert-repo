#! /bin/bash

if [[ $1 == "test" ]]
then
  PSQL="psql --username=postgres --dbname=worldcuptest -t --no-align -c"
else
  PSQL="psql --username=freecodecamp --dbname=worldcup -t --no-align -c"
fi

# Do not change code above this line. Use the PSQL variable above to query your database.

# Populate teams table
cat games.csv | while IFS="," read -r YEAR ROUND WINNER OPPONENT WINNER_GOALS OPPONENT_GOALS
do
  # Exclude first row
  if [[ ! $YEAR =~ ^[0-9]+$ ]] 
  then 
    continue 
  fi

  # Check if team exists
  WINNER_EXISTS=$($PSQL "SELECT name FROM teams WHERE name = '$WINNER';")
  
  if [[ ! $WINNER_EXISTS ]]
  then
    INSERT_WINNER_RESULT=$($PSQL "INSERT INTO teams(name) VALUES ('$WINNER') ON CONFLICT (name) DO NOTHING;")
    echo $INSERT_WINNER_RESULT FOR TEAM $WINNER
  fi

  OPPONENT_EXISTS=$($PSQL "SELECT name FROM teams WHERE name = '$OPPONENT';")

  if [[ ! $OPPONENT_EXISTS ]]
  then
    INSERT_OPPONENT_RESULT=$($PSQL "INSERT INTO teams(name) VALUES ('$OPPONENT') ON CONFLICT (name) DO NOTHING;")
    echo $INSERT_WINNER_RESULT FOR TEAM $OPPONENT
  fi

done

# Populate games table
cat games.csv | while IFS="," read -r YEAR ROUND WINNER OPPONENT WINNER_GOALS OPPONENT_GOALS
do
  # Skip first row
  if [[ ! $YEAR =~ ^[0-9]+$ ]]
  then
    continue
  fi

  WINNER_ID=$($PSQL "SELECT team_id FROM teams WHERE name = '$WINNER';")
  OPPONENT_ID=$($PSQL "SELECT team_id FROM teams WHERE name = '$OPPONENT';")
  INSERT_GAME_RESULT=$($PSQL "INSERT INTO games (year, round, winner_id, opponent_id, winner_goals, opponent_goals) VALUES ($YEAR, '$ROUND', $WINNER_ID, $OPPONENT_ID, $WINNER_GOALS, $OPPONENT_GOALS);")
  echo $INSERT_GAME_RESULT FOR $WINNER VS $OPPONENT
done