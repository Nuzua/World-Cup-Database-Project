#! /bin/bash

if [[ $1 == "test" ]]
then
  PSQL="psql --username=postgres --dbname=worldcuptest -t --no-align -c"
else
  PSQL="psql --username=freecodecamp --dbname=worldcup -t --no-align -c"
fi

# Do not change code above this line. Use the PSQL variable above to query your database.

echo $($PSQL "TRUNCATE games,teams RESTART IDENTITY")

tail -n +2 games.csv | while IFS="," read year round winner opponent winner_goals opponent_goals
do
# get team_id for winner
WINNER_TEAM_ID=$($PSQL "SELECT team_id FROM teams WHERE name='$winner'")
  # if not found
  if [[ -z $WINNER_TEAM_ID ]]
  then
  # insert team
  INSERT_RESULT=$($PSQL "INSERT INTO teams(name) VALUES('$winner')")
   if [[ $INSERT_RESULT == "INSERT 0 1" ]]
   then
   echo Inserted into teams: $winner
   fi
  fi
# get new team_id for winner
WINNER_TEAM_ID=$($PSQL "SELECT team_id FROM teams WHERE name='$winner'")

# get team_id for opponent
OPPONENT_TEAM_ID=$($PSQL "SELECT team_id FROM teams WHERE name='$opponent'")
  # if not found
  if [[ -z $OPPONENT_TEAM_ID ]]
  then
  # insert team
  INSERT_RESULT=$($PSQL "INSERT INTO teams(name) VALUES('$opponent')")
    if [[ $INSERT_RESULT == "INSERT 0 1" ]]
    then
    echo Inserted into teams: $opponent
    fi
  fi
# get new team_id for opponent
OPPONENT_TEAM_ID=$($PSQL "SELECT team_id FROM teams WHERE name='$opponent'")

#get game_id
GAME_ID=$($PSQL "SELECT game_id FROM games WHERE (year, round, winner_id, opponent_id, winner_goals, opponent_goals) = ($year, '$round', $WINNER_TEAM_ID, $OPPONENT_TEAM_ID, $winner_goals, $opponent_goals)")
#if game_id is not found
  if [[ -z $GAME_ID ]]
  then
  #insert game
    INSERT_RESULT=$($PSQL "INSERT INTO games(year, round, winner_id, opponent_id, winner_goals, opponent_goals) VALUES ($year, '$round', $WINNER_TEAM_ID, $OPPONENT_TEAM_ID, $winner_goals, $opponent_goals)")
    if [[ $INSERT_RESULT == "INSERT 0 1" ]]
   then
   echo Inserted into games: $year, $round, $winner, $opponent, $winner_goals, $opponent_goals
   fi
  fi
 done