#! /bin/bash

if [[ $1 == "test" ]]
then
  PSQL="psql --username=postgres --dbname=worldcuptest -t --no-align -c"
else
  PSQL="psql --username=freecodecamp --dbname=worldcup -t --no-align -c"
fi

# Do not change code above this line. Use the PSQL variable above to query your database.

# Path to your CSV file
csv_file="games.csv"

# Read the CSV file line by line
while IFS=',' read -r year round winner opponent winner_goals opponent_goals || [[ -n "$year" ]]
do

    if [[ $year != 'year' ]]
    then
      echo $year $round $winner $opponent $winner_goals $opponent_goals
      # Check if winner team exists in teams table
      winner_id=$($PSQL "SELECT team_id FROM teams WHERE name = '$winner';")
      if [[ -z "$winner_id" ]] 
      then
          $($PSQL "INSERT INTO teams (name) VALUES ('$winner');")
          winner_id=$($PSQL "SELECT team_id FROM teams WHERE name = '$winner';")
      fi

      # Check if opponent team exists in teams table
      opponent_id=$($PSQL "SELECT team_id FROM teams WHERE name = '$opponent';")
      if [[ -z "$opponent_id" ]] 
      then
          $($PSQL "INSERT INTO teams (name) VALUES ('$opponent');")
          opponent_id=$($PSQL "SELECT team_id FROM teams WHERE name = '$opponent';")
      fi

      if ! [[ -z "$winner_id" ]] && ! [[ -z "$opponent_id" ]]
      then
          $PSQL "INSERT INTO games (year, round, winner_id, opponent_id, winner_goals, opponent_goals) VALUES ($year, '$round', $winner_id, $opponent_id, $winner_goals, $opponent_goals);"
      fi

    fi

done < "$csv_file"
