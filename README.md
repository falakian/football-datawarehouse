# Introduction
This project involves the design and implementation of a data warehouse specifically for European football. The data warehouse consolidates and organizes vast amounts of match and player data from various European leagues. It provides a robust structure for efficient querying and analysis, enabling users to gain insights into team performance, player statistics, and historical trends. This repository includes the schema design, ETL processes, and sample queries to demonstrate the capabilities of the data warehouse.

### Source Table Descriptions

This database contains information related to European football matches. The structure of the tables is as follows:

#### Table: `players`
This table is used to store information about players. The structure of this table is as follows:

| Column Name             | Data Type              | Description                           |
|-------------------------|------------------------|---------------------------------------|
| `player_id`             | `integer`              | Player's unique identifier            |
| `current_club_id`       | `integer`              | Identifier for the player's current club |
| `player_code`           | `character varying(64)`| Player code (full name of the player) |
| `country_of_birth`      | `character varying(32)`| Country of birth                      |
| `city_of_birth`         | `character varying(64)`| City of birth                         |
| `country_of_citizenship`| `character varying(32)`| Country of citizenship                |
| `date_of_birth`         | `date`                 | Date of birth                         |
| `sub_position`          | `character varying(32)`| Player's secondary position           |
| `position`              | `character varying(16)`| Player's primary position             |
| `foot`                  | `character varying(8)` | Player's preferred foot               |
| `height_in_cm`          | `integer`              | Player's height in centimeters        |
| `contract_expiration_date` | `date`             | Contract expiration date              |

#### Table: `clubs`
This table is used to store information about clubs. The structure of this table is as follows:

| Column Name             | Data Type              | Description                           |
|-------------------------|------------------------|---------------------------------------|
| `club_id`               | `integer`              | Club's unique identifier              |
| `name`                  | `character varying(64)`| Club's name                           |
| `domestic_competition_id`| `character varying(4)` | Domestic league identifier            |
| `squad_size`            | `integer`              | Squad size                            |
| `foreigners_number`     | `integer`              | Number of foreign players             |
| `national_team_players` | `integer`              | Number of national team players       |
| `stadium_name`          | `character varying(64)`| Stadium name                          |
| `stadium_seats`         | `integer`              | Stadium seating capacity              |
| `net_transfer_record`   | `character varying(16)`| Net transfer record                   |

#### Table: `competitions`
This table is used to store information about competitions. The structure of this table is as follows:

| Column Name             | Data Type              | Description                           |
|-------------------------|------------------------|---------------------------------------|
| `competition_id`        | `character varying(4)` | Competition's unique identifier       |
| `name`                  | `character varying(64)`| Competition's name                    |
| `type`                  | `character varying(32)`| Type of competition                   |
| `country_name`          | `character varying(16)`| Country where the competition is held |

#### Table: `games`
This table is used to store information about games. The structure of this table is as follows:

| Column Name             | Data Type              | Description                           |
|-------------------------|------------------------|---------------------------------------|
| `game_id`               | `integer`              | Game's unique identifier              |
| `competition_id`        | `character varying(4)` | Competition series identifier         |
| `season`                | `integer`              | Season in which the game was held     |
| `date`                  | `date`                 | Date of the game                      |
| `home_club_id`          | `integer`              | Home team's club identifier           |
| `away_club_id`          | `integer`              | Away team's club identifier           |
| `home_club_goals`       | `integer`              | Number of goals scored by the home team|
| `away_club_goals`       | `integer`              | Number of goals scored by the away team|
| `stadium`               | `character varying(64)`| Name of the stadium where the game was held |
| `attendance`            | `integer`              | Number of spectators                  |

#### Table: `appearances`
This table is used to store information about player appearances in games. The structure of this table is as follows:

| Column Name             | Data Type              | Description                           |
|-------------------------|------------------------|---------------------------------------|
| `appearance_id`         | `character varying(16)`| Appearance's unique identifier        |
| `game_id`               | `integer`              | Game's unique identifier              |
| `player_id`             | `integer`              | Player's unique identifier            |
| `yellow_cards`          | `integer`              | Number of yellow cards received by the player |
| `red_cards`             | `integer`              | Number of red cards received by the player   |
| `goals`                 | `integer`              | Number of goals scored by the player       |
| `assists`               | `integer`              | Number of assists made by the player       |
| `minutes_played`        | `integer`              | Number of minutes played by the player     |

#### Table: `game_events`
This table is used to store information about events during the games (e.g., goals, goal opportunities, penalties, etc.). The structure of this table is as follows:

| Column Name             | Data Type              | Description                           |
|-------------------------|------------------------|---------------------------------------|
| `game_event_id`         | `integer`              | Event's unique identifier             |
| `game_id`               | `integer`              | Game's unique identifier              |
| `minute`                | `integer`              | Minute when the event occurred        |
| `type`                  | `character varying(16)`| Type of event                         |
| `player_id`             | `integer`              | Identifier of the player involved in the event |
| `player_in_id`          | `integer`              | Identifier of the player who substituted in   |
| `player_assist_id`      | `integer`              | Identifier of the player who assisted the goal |


### Dimension Tables

#### Player Dimension:
This dimension, created with a table named `dimPlayers` in the `dim` schema, stores information related to players. The fields in this table are as follows:

- **[id]:** SURROGATE Key of the table (INT).  
  This field is automatically populated in the PROCEDURE because the `current_club_id` field is an SCD Type 2, and we maintain a history of the player's clubs.

- **[player_id]:** Player ID (INT).  
  This field is populated from the `PLAYERS` table in the `STAGINGAREA` during the PROCEDURE.

- **[current_club_id]:** Current Club ID (INT).  
  This field is populated from the `PLAYERS` table in the `STAGINGAREA` during the PROCEDURE. It is an SCD Type 2 field, and we maintain the player's club history.

- **[player_code]:** Player code (full name) (VARCHAR(70)).  
  This field is populated from the `PLAYERS` table in the `STAGINGAREA` during the PROCEDURE.

- **[country_of_birth]:** Player's country of birth (VARCHAR(40)).  
  This field is populated from the `PLAYERS` table in the `STAGINGAREA` during the PROCEDURE.

- **[city_of_birth]:** Player's city of birth (VARCHAR(70)).  
  This field is populated from the `PLAYERS` table in the `STAGINGAREA` during the PROCEDURE.

- **[country_of_citizenship]:** Player's country of citizenship (VARCHAR(40)).  
  This field is populated from the `PLAYERS` table in the `STAGINGAREA` during the PROCEDURE.

- **[date_of_birth]:** Player's date of birth (DATE).  
  This field is populated from the `PLAYERS` table in the `STAGINGAREA` during the PROCEDURE.

- **[sub_position]:** Player's secondary position (VARCHAR(40)).  
  This field is populated from the `PLAYERS` table in the `STAGINGAREA` during the PROCEDURE.

- **[position]:** Player's primary position (VARCHAR(20)).  
  This field is populated from the `PLAYERS` table in the `STAGINGAREA` during the PROCEDURE.

- **[foot]:** Player's preferred foot (VARCHAR(10)).  
  This field is populated from the `PLAYERS` table in the `STAGINGAREA` during the PROCEDURE.

- **[height_in_cm]:** Player's height in centimeters (INT).  
  This field is populated from the `PLAYERS` table in the `STAGINGAREA` during the PROCEDURE.

- **[contract_expiration_date]:** Player's contract expiration date (DATE).  
  This field is populated from the `PLAYERS` table in the `STAGINGAREA` during the PROCEDURE.

- **[start_date]:** Start date (because it's an SCD Type 2) (DATE).  
  This field is automatically populated in the PROCEDURE.

- **[end_date]:** End date (because it's an SCD Type 2) (DATE).  
  This field is automatically populated in the PROCEDURE.

- **[current_flag]:** Flag (because it's an SCD Type 2) (BIT).  
  This field is automatically populated in the PROCEDURE.

#### Club Dimension:
This dimension, created with a table named `dimClubs` in the `dim` schema, stores information related to clubs. The fields in this table are as follows:

- **[sec_id]:** SURROGATE Key of the table (INT).  
  This field is automatically populated in the PROCEDURE because the `name` field is an SCD Type 2, and we maintain a history of club names.

- **[club_id]:** Club ID (INT).  
  This field is populated from the `CLUBS` table in the `STAGINGAREA` during the PROCEDURE.

- **[name]:** Club name (VARCHAR(70)).  
  This field is populated from the `CLUBS` table in the `STAGINGAREA` during the PROCEDURE. It is an SCD Type 2 field, and we maintain the history of club names.

- **[domestic_competition_id]:** Domestic league ID where the club participates (VARCHAR(10)).  
  This field is populated from the `CLUBS` table in the `STAGINGAREA` during the PROCEDURE.

- **[squad_size]:** Squad size (INT).  
  This field is populated from the `CLUBS` table in the `STAGINGAREA` during the PROCEDURE.

- **[foreigners_number]:** Number of foreign players in the team (INT).  
  This field is populated from the `CLUBS` table in the `STAGINGAREA` during the PROCEDURE.

- **[national_team_players]:** Number of national team players in the club (INT).  
  This field is populated from the `CLUBS` table in the `STAGINGAREA` during the PROCEDURE.

- **[stadium_name]:** Club's stadium name (VARCHAR(70)).  
  This field is populated from the `CLUBS` table in the `STAGINGAREA` during the PROCEDURE.

- **[stadium_seats]:** Stadium seating capacity (INT).  
  This field is populated from the `CLUBS` table in the `STAGINGAREA` during the PROCEDURE.

- **[net_transfer_record]:** Club's net transfer record (VARCHAR(20)).  
  This field is populated from the `CLUBS` table in the `STAGINGAREA` during the PROCEDURE.

- **[start_date]:** Start date (because it's an SCD Type 2) (DATE).  
  This field is automatically populated in the PROCEDURE.

- **[end_date]:** End date (because it's an SCD Type 2) (DATE).  
  This field is automatically populated in the PROCEDURE.

- **[flag]:** Flag (because it's an SCD Type 2) (BIT).  
  This field is automatically populated in the PROCEDURE.

#### Competition Dimension:
This dimension, created with a table named `dimCompetitions` in the `dim` schema, stores information related to competitions. The fields in this table are as follows:

- **[competition_id]:** Competition ID (INT).  
  This field is populated from the `competitions` table in the `STAGING AREA` during the PROCEDURE.

- **[competition_name_orginal]:** Previous competition name (as it is an SCD Type 3 field).  
  This field is populated in the PROCEDURE when the competition name changes. The `name_current` field is set to this field's value, and the new competition name is stored in the `name_current` field (VARCHAR(70)).

- **[competition_name_current]:** Current competition name (VARCHAR(70)).  
  This field is populated from the `competitions` table in the `STAGING AREA` during the PROCEDURE.

- **[effective_date]:** Date of competition name change (DATE).  
  This field is automatically populated in the PROCEDURE.

- **[type]:** Type of competition (VARCHAR(40)).  
  This field is populated from the `competitions` table in the `STAGING AREA` during the PROCEDURE.

- **[country_name]:** Country of the competition (VARCHAR(20)).  
  This field is populated from the `competitions` table in the `STAGING AREA` during the PROCEDURE.

#### Game Dimension:
This dimension, created with a table named `dimGames` in the `dim` schema, stores information related to games. The fields in this table are as follows:

- **[game_id]:** Game ID (INT).  
  This field is populated from the `GAMES` table in the `STAGING AREA` during the PROCEDURE.

- **[competition_id]:** Competition ID where the game was held (VARCHAR(10)).  
  This field is populated from the `GAMES` table in the `STAGING AREA` during the PROCEDURE.

- **[competition_name]:** Competition name where the game was held (VARCHAR(70)).  
  This field is populated from the join of the `GAMES` and `competitions` tables in the `STAGING AREA` during the PROCEDURE.

- **[competition_type]:** Type of competition where the game was held (VARCHAR(40)).  
  This field is populated from the join of the `GAMES` and `competitions` tables in the `STAGING AREA` during the PROCEDURE.

- **[competition_country_name]:** Country of the competition where the game was held (VARCHAR(20)).  
  This field is populated from the join of the `GAMES` and `competitions` tables in the `STAGING AREA` during the PROCEDURE.

- **[season]:** Season in which the game was held (INT).  
  This field is populated from the `GAMES` table in the `STAGING AREA` during the PROCEDURE.

- **[date]:** Date of the game (DATE).  
  This field is populated from the `GAMES` table in the `STAGING AREA` during the PROCEDURE.

- **[home_club_id]:** Home team ID (INT).  
  This field is populated from the `GAMES` table in the `STAGING AREA` during the PROCEDURE.

- **[away_club_id]:** Away team ID (INT).  
  This field is populated from the `GAMES` table in the `STAGING AREA` during the PROCEDURE.

- **[home_club

_goals]:** Home team goals (INT).  
  This field is populated from the `GAMES` table in the `STAGING AREA` during the PROCEDURE.

- **[away_club_goals]:** Away team goals (INT).  
  This field is populated from the `GAMES` table in the `STAGING AREA` during the PROCEDURE.

- **[stadium]:** Stadium where the game was held (VARCHAR(70)).  
  This field is populated from the `GAMES` table in the `STAGING AREA` during the PROCEDURE.

- **[attendance]:** Attendance of the game (INT).  
  This field is populated from the `GAMES` table in the `STAGING AREA` during the PROCEDURE.

#### Player Relationship Dimension:
This dimension, created with a table named `dimGames` in the `dim` schema, stores information related to the relationship between players and clubs (e.g., defense, attack, etc.). The fields in this table are as follows:

- **[Type]:** Player relationship type (INT).  
  This is a numeric field and is automatically populated in the PROCEDURE.

- **[TypeDescription]:** Description of the relationship (VARCHAR(20)).  
  This field is populated from the `PLAYERS` table in the `STAGING AREA` through a GROUP BY on the `POSITION` field.


### Player Data Mart Tables

#### Transactional Fact Table:
The transactional fact table for the player data mart, named `FactPlayersTransactional` in the `fact` schema, captures events that occur during a game involving players, such as substitutions, cards, goals, shots, and assists. The data for this fact table is derived from a join between the `games` and `events_games` tables located in the `STAGING AREA`. The fields and their descriptions are as follows:

- **[key_player]:** Player dimension key.
- **[key_time]:** Time dimension key.
- **[key_competition]:** Competition dimension key.
- **[key_club]:** Club dimension key.
- **[key_game]:** Game dimension key.
- **[type]:** Type of event that occurred.
- **[minute]:** Minute of the game when the event occurred.

#### Daily Fact Table:
The daily fact table for the player data mart, named `FactPlayersDaily` in the `fact` schema, records daily statistics for players, such as the number of goals, assists, red cards, yellow cards, and minutes played. This data is obtained from a join between the `appearances` and `games` tables in the `STAGING AREA`. The fields and their descriptions are as follows:

- **[Player_key]:** Player dimension key.
- **[Time_key]:** Date dimension key.
- **[Competition_key]:** Competition dimension key.
- **[Club_key]:** Club dimension key.
- **[goalCount]:** Number of goals scored.
- **[assistCount]:** Number of assists.
- **[redCardCount]:** Number of red cards.
- **[yellowCardCount]:** Number of yellow cards.
- **[playMinute]:** Number of minutes played.

#### Accumulated Fact Table:
The accumulated fact table for the player data mart, named `FactPlayersAcc` in the `fact` schema, aggregates daily statistics for players over time, including the number of goals, assists, red cards, yellow cards, and minutes played. This data is also derived from a join between the `appearances` and `games` tables in the `STAGING AREA`. The fields and their descriptions are as follows:

- **[Player_key]:** Player dimension key.
- **[Time_key]:** Date dimension key.
- **[Competition_key]:** Competition dimension key.
- **[Club_key]:** Club dimension key.
- **[goalCount]:** Number of goals scored.
- **[assistCount]:** Number of assists.
- **[redCardCount]:** Number of red cards.
- **[yellowCardCount]:** Number of yellow cards.
- **[playMinute]:** Number of minutes played.

### Club Data Mart

#### Transactional Fact Table :
This fact table, named `fact_club_transactional` in the `fact` schema, records events that occurred during a game for a club. The data is sourced from the `games` table in the STAGING AREA. Below are the fields and their descriptions:

- **time_key**: Key to the time dimension.
- **competition_key**: Key to the competition dimension.
- **game_key**: Key to the game dimension.
- **club_key**: Key to the club dimension.
- **type**: Indicates whether the team was home or away.
- **goals_scored**: Number of goals scored by the club.
- **goals_conceded**: Number of goals conceded by the club.

#### Daily Fact Table :
This fact table, named `FactClubDaily` in the `fact` schema, captures daily information for each club. The data is sourced from the `games` table in the STAGING AREA. Below are the fields and their descriptions:

- **time_key**: Key to the time dimension.
- **competition_key**: Key to the competition dimension.
- **club_key**: Key to the club dimension.
- **winCount**: Number of wins.
- **loseCount**: Number of losses.
- **drawCount**: Number of draws.
- **totalPlays**: Total number of games played.
- **awayPlays**: Number of away games.
- **homePlays**: Number of home games.
- **goalCount**: Number of goals scored.

#### Accumulated Fact Table :
This fact table, named `FactClubAcc` in the `fact` schema, captures the most recent daily information for each club. The data is sourced from the `games` table in the STAGING AREA. Below are the fields and their descriptions:

- **competition_key**: Key to the competition dimension.
- **club_key**: Key to the club dimension.
- **winCount**: Number of wins.
- **loseCount**: Number of losses.
- **drawCount**: Number of draws.
- **totalPlays**: Total number of games played.
- **awayPlays**: Number of away games.
- **homePlays**: Number of home games.
- **goalCount**: Number of goals scored.
