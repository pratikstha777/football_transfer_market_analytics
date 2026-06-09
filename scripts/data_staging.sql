-- Create Staging Schema to isolate raw imports
CREATE DATABASE IF NOT EXISTS staging_transfermarkt;
USE staging_transfermarkt;

-- --------------------------------------------------------
-- 1. Table & Load Script: appearances
-- --------------------------------------------------------
ALTER TABLE staging_transfermarkt.appearances 
MODIFY COLUMN appearance_id VARCHAR(255);
CREATE TABLE staging_transfermarkt.appearances (
    appearance_id INT PRIMARY KEY,
    game_id INT,
    player_id INT,
    player_club_id INT,
    player_current_club_id INT,
    date DATE,
    player_name VARCHAR(255),
    competition_id VARCHAR(255),
    yellow_cards INT,
    red_cards INT,
    goals INT,
    assists INT,
    minutes_played INT
);

LOAD DATA INFILE 'C:/ProgramData/MySQL/MySQL Server 8.0/Uploads/appearances.csv'
IGNORE
INTO TABLE staging_transfermarkt.appearances
FIELDS TERMINATED BY ',' 
OPTIONALLY ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 LINES;

-- --------------------------------------------------------
-- 2. Table & Load Script: clubs
-- --------------------------------------------------------
CREATE TABLE staging_transfermarkt.clubs (
    club_id INT PRIMARY KEY,
    club_code VARCHAR(255),
    name VARCHAR(255),
    domestic_competition_id VARCHAR(255),
    total_market_value BIGINT,
    squad_size INT,
    average_age DECIMAL(10,2),
    foreigners_number INT,
    foreigners_percentage DECIMAL(10,2),
    national_team_players INT,
    stadium_name VARCHAR(255),
    stadium_seats INT,
    net_transfer_record VARCHAR(255),
    coach_name VARCHAR(255), -- FIXED: Changed from DECIMAL to VARCHAR
    last_season INT,
    filename VARCHAR(255),
    url VARCHAR(255)
);
-- 3. Load the data using variables to elegantly handle empty strings ('')
LOAD DATA INFILE 'C:/ProgramData/MySQL/MySQL Server 8.0/Uploads/clubs.csv'
INTO TABLE staging_transfermarkt.clubs
FIELDS TERMINATED BY ',' 
OPTIONALLY ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 LINES
-- Map every column from your CSV straight into variables
(
 @v_club_id, 
 @v_club_code, 
 @v_name, 
 @v_domestic_competition_id, 
 @v_total_market_value, 
 @v_squad_size, 
 @v_average_age, 
 @v_foreigners_number, 
 @v_foreigners_percentage, 
 @v_national_team_players, 
 @v_stadium_name, 
 @v_stadium_seats, 
 @v_net_transfer_record, 
 @v_coach_name, 
 @v_last_season, 
 @v_filename, 
 @v_url
)
SET 
    club_id                 = IF(@v_club_id = '', NULL, @v_club_id),
    club_code               = IF(@v_club_code = '', NULL, @v_club_code),
    name                    = IF(@v_name = '', NULL, @v_name),
    domestic_competition_id = IF(@v_domestic_competition_id = '', NULL, @v_domestic_competition_id),
    total_market_value      = IF(@v_total_market_value = '', NULL, @v_total_market_value),
    squad_size              = IF(@v_squad_size = '', NULL, @v_squad_size),
    average_age             = IF(@v_average_age = '', NULL, @v_average_age),
    foreigners_number       = IF(@v_foreigners_number = '', NULL, @v_foreigners_number),
    foreigners_percentage   = IF(@v_foreigners_percentage = '', NULL, @v_foreigners_percentage),
    national_team_players   = IF(@v_national_team_players = '', NULL, @v_national_team_players),
    stadium_name            = IF(@v_stadium_name = '', NULL, @v_stadium_name),
    stadium_seats           = IF(@v_stadium_seats = '', NULL, @v_stadium_seats),
    net_transfer_record     = IF(@v_net_transfer_record = '', NULL, @v_net_transfer_record),
    coach_name              = IF(@v_coach_name = '', NULL, @v_coach_name),
    last_season             = IF(@v_last_season = '', NULL, @v_last_season),
    filename                = IF(@v_filename = '', NULL, @v_filename),
    url                     = IF(@v_url = '', NULL, @v_url);
-- --------------------------------------------------------
-- 3. Table & Load Script: club_games
-- --------------------------------------------------------
CREATE TABLE staging_transfermarkt.club_games (
    game_id INT,
    club_id INT,
    own_goals INT,
    own_position DECIMAL(10,2),
    own_manager_name VARCHAR(255),
    opponent_id INT,
    opponent_goals INT,
    opponent_position DECIMAL(10,2),
    opponent_manager_name VARCHAR(255),
    hosting VARCHAR(255),
    is_win INT
);

LOAD DATA INFILE 'C:/ProgramData/MySQL/MySQL Server 8.0/Uploads/club_games.csv' 
INTO TABLE staging_transfermarkt.club_games 
FIELDS TERMINATED BY ','  
OPTIONALLY ENCLOSED BY '"' 
LINES TERMINATED BY '\n' 
IGNORE 1 LINES
(
  @v_game_id,
  @v_club_id,
  @v_own_goals,
  @v_own_position,
  @v_own_manager_name,
  @v_opponent_id,
  @v_opponent_goals,
  @v_opponent_position,
  @v_opponent_manager_name,
  @v_hosting,
  @v_is_win
)
SET 
    game_id               = IF(@v_game_id = '', NULL, @v_game_id),
    club_id               = IF(@v_club_id = '', NULL, @v_club_id),
    own_goals             = IF(@v_own_goals = '', NULL, @v_own_goals),
    -- Intercept the empty values for league positions here:
    own_position          = IF(@v_own_position = '', NULL, @v_own_position),
    own_manager_name      = IF(@v_own_manager_name = '', NULL, @v_own_manager_name),
    opponent_id           = IF(@v_opponent_id = '', NULL, @v_opponent_id),
    opponent_goals        = IF(@v_opponent_goals = '', NULL, @v_opponent_goals),
    -- And here:
    opponent_position     = IF(@v_opponent_position = '', NULL, @v_opponent_position),
    opponent_manager_name = IF(@v_opponent_manager_name = '', NULL, @v_opponent_manager_name),
    hosting               = IF(@v_hosting = '', NULL, @v_hosting),
    is_win                = IF(@v_is_win = '', NULL, @v_is_win);

-- --------------------------------------------------------
-- 4. Table & Load Script: competitions
-- --------------------------------------------------------
CREATE TABLE staging_transfermarkt.competitions (
    competition_id VARCHAR(255) PRIMARY KEY,
    competition_code VARCHAR(255),
    name VARCHAR(255),
    sub_type VARCHAR(255),
    type VARCHAR(255),
    country_id INT,
    country_name VARCHAR(255),
    domestic_league_code VARCHAR(255),
    confederation VARCHAR(255),
    total_clubs DECIMAL(10,2),
    url VARCHAR(255)
);


LOAD DATA INFILE 'C:/ProgramData/MySQL/MySQL Server 8.0/Uploads/competitions.csv'
INTO TABLE staging_transfermarkt.competitions
FIELDS TERMINATED BY ',' 
OPTIONALLY ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 LINES
-- Map every column from the CSV into a variable (Adjust names/order if your CSV is different!)
(    
  @v_competition_id,
  @v_competition_code,
  @v_name,
  @v_type,
  @v_sub_type,
  @v_country_id,
  @v_country_name,
  @v_domestic_league_code,
  @v_confederation,
  @v_url,
  @v_extra1, -- Catch-all for extra column 11
  @v_extra2, -- Catch-all for extra column 12
  @v_extra3
)
SET 
  competition_id       = IF(@v_competition_id = '', NULL, @v_competition_id),
  competition_code     = IF(@v_competition_code = '', NULL, @v_competition_code),
  name                 = IF(@v_name = '', NULL, @v_name),
  type                 = IF(@v_type = '', NULL, @v_type),
  sub_type             = IF(@v_sub_type = '', NULL, @v_sub_type),
  country_id           = IF(@v_country_id = '', NULL, @v_country_id),
  country_name         = IF(@v_country_name = '', NULL, @v_country_name),
  domestic_league_code = IF(@v_domestic_league_code = '', NULL, @v_domestic_league_code),
  confederation        = IF(@v_confederation = '', NULL, @v_confederation),
  url                  = IF(@v_url = '', NULL, @v_url);

-- --------------------------------------------------------
-- 5. Table & Load Script: countries
-- --------------------------------------------------------
CREATE TABLE staging_transfermarkt.countries (
    country_id INT,
    country_name VARCHAR(255),
    country_code VARCHAR(255),
    confederation VARCHAR(255),
    total_clubs INT,
    total_players INT,
    average_age DECIMAL(10,2),
    url VARCHAR(255)
);

LOAD DATA INFILE 'C:/ProgramData/MySQL/MySQL Server 8.0/Uploads/countries.csv'
INTO TABLE staging_transfermarkt.countries
FIELDS TERMINATED BY ',' 
OPTIONALLY ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 LINES;

-- --------------------------------------------------------
-- 6. Table & Load Script: games
CREATE TABLE staging_transfermarkt.games (
    game_id INT PRIMARY KEY,
    competition_id VARCHAR(255),
    season INT,
    round VARCHAR(255),
    date VARCHAR(255),             -- Staged as text to prevent format crashes
    home_club_id INT,
    away_club_id INT,
    home_club_goals INT,
    away_club_goals INT,
    home_club_position VARCHAR(50), 
    away_club_position VARCHAR(50),
    home_club_manager_name VARCHAR(255),
    away_club_manager_name VARCHAR(255),
    stadium VARCHAR(255),
    attendance VARCHAR(50),       
    referee VARCHAR(255),
    url TEXT,
    home_club_name VARCHAR(255),
    away_club_name VARCHAR(255),
    aggregate VARCHAR(50),
    competition_type VARCHAR(255)
);
LOAD DATA INFILE 'C:/ProgramData/MySQL/MySQL Server 8.0/Uploads/games.csv' 
INTO TABLE staging_transfermarkt.games 
FIELDS TERMINATED BY ','  
OPTIONALLY ENCLOSED BY '"' 
LINES TERMINATED BY '\n' 
IGNORE 1 LINES
(
  @v_game_id,
  @v_competition_id,
  @v_season,
  @v_round,
  @v_date,
  @v_home_club_id,
  @v_away_club_id,
  @v_home_club_goals,
  @v_away_club_goals,
  @v_home_club_position,
  @v_away_club_position,
  @v_home_club_manager_name,
  @v_away_club_manager_name,
  @v_stadium,
  @v_attendance,
  @v_referee,
  @v_url,
  @v_home_club_formation, -- Parsed from CSV, but skipped in SET block
  @v_away_club_formation, -- Parsed from CSV, but skipped in SET block
  @v_home_club_name,
  @v_away_club_name,
  @v_aggregate,
  @v_competition_type
)
SET 
  game_id                = IF(@v_game_id = '', NULL, @v_game_id),
  competition_id         = IF(@v_competition_id = '', NULL, @v_competition_id),
  season                 = IF(@v_season = '', NULL, @v_season),
  round                  = IF(@v_round = '', NULL, @v_round),
  date                   = IF(@v_date = '', NULL, @v_date),
  home_club_id           = IF(@v_home_club_id = '', NULL, @v_home_club_id),
  away_club_id           = IF(@v_away_club_id = '', NULL, @v_away_club_id),
  home_club_goals        = IF(@v_home_club_goals = '', NULL, @v_home_club_goals),
  away_club_goals        = IF(@v_away_club_goals = '', NULL, @v_away_club_goals),
  home_club_position     = IF(@v_home_club_position = '', NULL, @v_home_club_position),
  away_club_position     = IF(@v_away_club_position = '', NULL, @v_away_club_position),
  home_club_manager_name = IF(@v_home_club_manager_name = '', NULL, @v_home_club_manager_name),
  away_club_manager_name = IF(@v_away_club_manager_name = '', NULL, @v_away_club_manager_name),
  stadium                = IF(@v_stadium = '', NULL, @v_stadium),
  attendance             = IF(@v_attendance = '', NULL, @v_attendance),
  referee                = IF(@v_referee = '', NULL, @v_referee),
  url                    = IF(@v_url = '', NULL, @v_url),
  home_club_name         = IF(@v_home_club_name = '', NULL, @v_home_club_name),
  away_club_name         = IF(@v_away_club_name = '', NULL, @v_away_club_name),
  aggregate              = IF(@v_aggregate = '', NULL, @v_aggregate),
  competition_type       = IF(@v_competition_type = '', NULL, @v_competition_type);

-- --------------------------------------------------------
-- 7. Table & Load Script: game_events
-- --------------------------------------------------------
CREATE TABLE staging_transfermarkt.game_events (
    game_event_id VARCHAR(255) PRIMARY KEY,    
    date DATE,
    game_id BIGINT,                      
    minute INT,
    type VARCHAR(255),
    club_id INT,
    club_name VARCHAR(255),
    player_id BIGINT,                    
    description VARCHAR(255),
    player_in_id BIGINT,               
    player_assist_id BIGINT              
);

LOAD DATA INFILE 'C:/ProgramData/MySQL/MySQL Server 8.0/Uploads/game_events.csv'
INTO TABLE staging_transfermarkt.game_events
FIELDS TERMINATED BY ',' 
OPTIONALLY ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 LINES
(
  @v_game_event_id, 
  @v_date,           
  @v_game_id,
  @v_minute,
  @v_type,
  @v_club_id,
  @v_club_name,
  @v_player_id,
  @v_description,
  @v_player_in_id,
  @v_player_assist_id,
  @v_leftovers
)
SET 
  game_event_id    = IF(@v_game_event_id = '', NULL, TRIM(@v_game_event_id)),
  date             = IF(@v_date = '', NULL, STR_TO_DATE(@v_date, '%c/%e/%Y')),
  game_id          = IF(@v_game_id = '', NULL, @v_game_id),
  minute           = IF(@v_minute = '', NULL, @v_minute),
  type             = IF(@v_type = '', NULL, @v_type),
  club_id          = IF(@v_club_id = '', NULL, @v_club_id),
  club_name        = IF(@v_club_name = '', NULL, @v_club_name),
  player_id        = IF(@v_player_id = '', NULL, @v_player_id),
  description      = IF(@v_description = '', NULL, @v_description),
  player_in_id     = IF(REGEXP_REPLACE(@v_player_in_id, '[^0-9]', '') = '', NULL, REGEXP_REPLACE(@v_player_in_id, '[^0-9]', '')),
  player_assist_id = IF(REGEXP_REPLACE(@v_player_assist_id, '[^0-9]', '') = '', NULL, REGEXP_REPLACE(@v_player_assist_id, '[^0-9]', ''));

-- --------------------------------------------------------
-- 8. Table & Load Script: game_lineups
-- --------------------------------------------------------
CREATE TABLE staging_transfermarkt.game_lineups (
    game_lineups_id VARCHAR(255) PRIMARY KEY,
    date DATE,
    game_id BIGINT,
    player_id BIGINT,
    club_id INT,
    player_name VARCHAR(255),
    type VARCHAR(255),
    position VARCHAR(255),
    number INT,
    team_captain INT
);

LOAD DATA INFILE 'C:/ProgramData/MySQL/MySQL Server 8.0/Uploads/game_lineups.csv' 
INTO TABLE staging_transfermarkt.game_lineups 
FIELDS TERMINATED BY ','  
OPTIONALLY ENCLOSED BY '"' 
LINES TERMINATED BY '\n' 
IGNORE 1 LINES
(
  @v_game_lineups_id,
  @v_date,              -- Maps perfectly to your table's 2nd column
  @v_game_id,           -- Maps perfectly to your table's 3rd column
  @v_player_id,
  @v_club_id,
  @v_player_name,
  @v_type,
  @v_position,
  @v_number,            -- Captured to clean out dashboard dashes
  @v_team_captain,
  @v_leftovers          -- Dynamic row-ending catchall
)
SET 
  game_lineups_id = IF(@v_game_lineups_id = '', NULL, TRIM(@v_game_lineups_id)),
  game_id         = IF(REGEXP_REPLACE(@v_game_id, '[^0-9]', '') = '', NULL, REGEXP_REPLACE(@v_game_id, '[^0-9]', '')),
  player_id       = IF(REGEXP_REPLACE(@v_player_id, '[^0-9]', '') = '', NULL, REGEXP_REPLACE(@v_player_id, '[^0-9]', '')),
  club_id         = IF(REGEXP_REPLACE(@v_club_id, '[^0-9]', '') = '', NULL, REGEXP_REPLACE(@v_club_id, '[^0-9]', '')),
  player_name     = IF(@v_player_name = '', NULL, @v_player_name),
  type            = IF(@v_type = '', NULL, @v_type),
  position        = IF(@v_position = '', NULL, @v_position),
  date            = IF(@v_date = '', NULL, IF(@v_date LIKE '%-%', STR_TO_DATE(@v_date, '%Y-%m-%d'), STR_TO_DATE(@v_date, '%c/%e/%Y'))),
  number          = IF(TRIM(@v_number) = '-' OR REGEXP_REPLACE(@v_number, '[^0-9]', '') = '', NULL, REGEXP_REPLACE(@v_number, '[^0-9]', '')),
  team_captain    = IF(REGEXP_REPLACE(@v_team_captain, '[^0-9]', '') = '', NULL, REGEXP_REPLACE(@v_team_captain, '[^0-9]', ''));
-- --------------------------------------------------------
-- 9. Table & Load Script: national_teams
-- --------------------------------------------------------
CREATE TABLE staging_transfermarkt.national_teams (
    national_team_id INT PRIMARY KEY,
    name VARCHAR(255),
    team_code VARCHAR(255),
    country_id INT,
    country_name VARCHAR(255),
    country_code VARCHAR(255),
    confederation VARCHAR(255),
    team_image_url VARCHAR(255),
    squad_size INT,
    average_age DECIMAL(10,2),
    foreigners_number INT,
    foreigners_percentage DECIMAL(10,2),
    total_market_value BIGINT,
    coach_name VARCHAR(255), -- FIXED: Switched from DECIMAL to VARCHAR
    fifa_ranking INT,
    last_season INT,
    url VARCHAR(255)
);

LOAD DATA INFILE 'C:/ProgramData/MySQL/MySQL Server 8.0/Uploads/national_teams.csv'
INTO TABLE staging_transfermarkt.national_teams
FIELDS TERMINATED BY ',' 
OPTIONALLY ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 LINES
(
  @v_national_team_id,
  @v_name,
  @v_team_code,
  @v_country_id,
  @v_country_name,
  @v_country_code,
  @v_confederation,
  @v_team_image_url,
  @v_squad_size,
  @v_average_age,
  @v_foreigners_number,
  @v_foreigners_percentage,
  @v_total_market_value,
  @v_coach_name,
  @v_fifa_ranking,
  @v_last_season,
  @v_url
)
SET
  national_team_id      = IF(@v_national_team_id = '', NULL, @v_national_team_id),
  name                  = IF(@v_name = '', NULL, @v_name),
  team_code             = IF(@v_team_code = '', NULL, @v_team_code),
  country_id            = IF(@v_country_id = '', NULL, @v_country_id),
  country_name          = IF(@v_country_name = '', NULL, @v_country_name),
  country_code          = IF(@v_country_code = '', NULL, @v_country_code),
  confederation         = IF(@v_confederation = '', NULL, @v_confederation),
  team_image_url        = IF(@v_team_image_url = '', NULL, @v_team_image_url),
  squad_size            = IF(REGEXP_REPLACE(@v_squad_size, '[^0-9]', '') = '', NULL, @v_squad_size),
  average_age           = IF(@v_average_age = '', NULL, @v_average_age),
  foreigners_number     = IF(REGEXP_REPLACE(@v_foreigners_number, '[^0-9]', '') = '', NULL, @v_foreigners_number),
  foreigners_percentage = IF(@v_foreigners_percentage = '', NULL, @v_foreigners_percentage),
  total_market_value    = IF(REGEXP_REPLACE(@v_total_market_value, '[^0-9]', '') = '', NULL, REGEXP_REPLACE(@v_total_market_value, '[^0-9]', '')),
  coach_name            = IF(@v_coach_name = '', NULL, TRIM(@v_coach_name)),
  fifa_ranking          = IF(REGEXP_REPLACE(@v_fifa_ranking, '[^0-9]', '') = '', NULL, @v_fifa_ranking),
  last_season           = IF(REGEXP_REPLACE(@v_last_season, '[^0-9]', '') = '', NULL, @v_last_season),
  url                   = IF(TRIM(@v_url) = '', NULL, TRIM(@v_url));
  
  
-- --------------------------------------------------------
-- 10. Table & Load Script: players
-- --------------------------------------------------------
CREATE TABLE staging_transfermarkt.players (
    player_id INT PRIMARY KEY,
    first_name VARCHAR(255),
    last_name VARCHAR(255),
    name VARCHAR(255),
    last_season INT,
    current_club_id INT,
    player_code VARCHAR(255),
    country_of_birth VARCHAR(255),
    city_of_birth VARCHAR(255),
    country_of_citizenship VARCHAR(255),
    date_of_birth DATE,
    sub_position VARCHAR(255),
    position VARCHAR(255),
    foot VARCHAR(255),
    height_in_cm INT,
    contract_expiration_date DATE,
    agent_name VARCHAR(255),
    image_url VARCHAR(255),
    international_caps DECIMAL(10,2),
    international_goals DECIMAL(10,2),
    current_national_team_id INT,
    url VARCHAR(255),
    current_club_domestic_competition_id VARCHAR(255),
    current_club_name VARCHAR(255),
    market_value_in_eur INT,
    highest_market_value_in_eur INT
);

LOAD DATA INFILE 'C:/ProgramData/MySQL/MySQL Server 8.0/Uploads/players.csv'
INTO TABLE staging_transfermarkt.players
CHARACTER SET utf8mb4 -- FIXED: Prevents corrupted characters like 'SocietÃ '
FIELDS TERMINATED BY ',' 
OPTIONALLY ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 LINES
(
  @v_player_id,
  @v_first_name,
  @v_last_name,
  @v_name,
  @v_last_season,
  @v_current_club_id,
  @v_player_code,
  @v_country_of_birth,
  @v_city_of_birth,
  @v_country_of_citizenship,
  @v_date_of_birth, -- '6/9/1978 0:00'
  @v_sub_position,
  @v_position,
  @v_foot,
  @v_height_in_cm,
  @v_contract_expiration_date,
  @v_agent_name,
  @v_image_url,
  @v_international_caps,
  @v_international_goals,
  @v_current_national_team_id,
  @v_url,
  @v_current_club_domestic_competition_id,
  @v_current_club_name,
  @v_market_value_in_eur,
  @v_highest_market_value_in_eur,
  @v_leftovers
)
SET
  player_id            = IF(@v_player_id = '', NULL, @v_player_id),
  first_name           = IF(@v_first_name = '', NULL, @v_first_name),
  last_name            = IF(@v_last_name = '', NULL, @v_last_name),
  name                 = IF(@v_name = '', NULL, @v_name),
  last_season          = IF(REGEXP_REPLACE(@v_last_season, '[^0-9]', '') = '', NULL, @v_last_season),
  current_club_id      = IF(REGEXP_REPLACE(@v_current_club_id, '[^0-9]', '') = '', NULL, @v_current_club_id),
  player_code          = IF(@v_player_code = '', NULL, @v_player_code),
  country_of_birth     = IF(@v_country_of_birth = '', NULL, @v_country_of_birth),
  city_of_birth        = IF(@v_city_of_birth = '', NULL, @v_city_of_birth),
  country_of_citizenship = IF(@v_country_of_citizenship = '', NULL, @v_country_of_citizenship),
  date_of_birth        = IF(@v_date_of_birth = '', NULL, STR_TO_DATE(SUBSTRING_INDEX(@v_date_of_birth, ' ', 1), '%c/%e/%Y')),
  sub_position         = IF(@v_sub_position = '', NULL, @v_sub_position),
  position             = IF(@v_position = '', NULL, @v_position),
  foot                 = IF(@v_foot = '', NULL, @v_foot),
  height_in_cm         = IF(REGEXP_REPLACE(@v_height_in_cm, '[^0-9]', '') = '', NULL, @v_height_in_cm),
  contract_expiration_date = IF(@v_contract_expiration_date = '', NULL, STR_TO_DATE(SUBSTRING_INDEX(@v_contract_expiration_date, ' ', 1), '%c/%e/%Y')),
  agent_name           = IF(@v_agent_name = '', NULL, @v_agent_name),
  image_url            = IF(@v_image_url = '', NULL, @v_image_url),
  international_caps   = IF(REGEXP_REPLACE(@v_international_caps, '[^0-9]', '') = '', NULL, REGEXP_REPLACE(@v_international_caps, '[^0-9]', '')),
  international_goals  = IF(REGEXP_REPLACE(@v_international_goals, '[^0-9]', '') = '', NULL, REGEXP_REPLACE(@v_international_goals, '[^0-9]', '')),
  current_national_team_id = IF(REGEXP_REPLACE(@v_current_national_team_id, '[^0-9]', '') = '', NULL, @v_current_national_team_id),
  url                  = IF(TRIM(@v_url) = '', NULL, TRIM(@v_url)),
  current_club_domestic_competition_id = IF(@v_current_club_domestic_competition_id = '', NULL, @v_current_club_domestic_competition_id),
  current_club_name    = IF(@v_current_club_name = '', NULL, @v_current_club_name),
  market_value_in_eur  = IF(REGEXP_REPLACE(@v_market_value_in_eur, '[^0-9]', '') = '', NULL, REGEXP_REPLACE(@v_market_value_in_eur, '[^0-9]', '')),
  highest_market_value_in_eur = IF(REGEXP_REPLACE(@v_highest_market_value_in_eur, '[^0-9]', '') = '', NULL, REGEXP_REPLACE(@v_highest_market_value_in_eur, '[^0-9]', ''));

-- --------------------------------------------------------
-- 11. Table & Load Script: player_valuations
-- --------------------------------------------------------
CREATE TABLE staging_transfermarkt.player_valuations (
    player_id INT,
    date DATE,
    market_value_in_eur INT,
    current_club_name VARCHAR(255),
    current_club_id INT,
    player_club_domestic_competition_id VARCHAR(255),
    PRIMARY KEY (player_id, date) -- Added to map historical valuation entries uniquely
);

LOAD DATA INFILE 'C:/ProgramData/MySQL/MySQL Server 8.0/Uploads/player_valuations.csv'
INTO TABLE staging_transfermarkt.player_valuations
CHARACTER SET utf8mb4
FIELDS TERMINATED BY ',' 
OPTIONALLY ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 LINES
(
  @v_player_id,
  @v_date,            -- Captures '1/20/2000' safely as a text variable
  @v_market_value_in_eur,
  @v_current_club_name,
  @v_current_club_id,
  @v_player_club_domestic_competition_id,
  @v_leftovers        -- Catch-all for row-ending format shifts
)
SET
  player_id           = IF(REGEXP_REPLACE(@v_player_id, '[^0-9]', '') = '', NULL, @v_player_id),
  date                = IF(@v_date = '', NULL, IF(@v_date LIKE '%-%', STR_TO_DATE(@v_date, '%Y-%m-%d'), STR_TO_DATE(@v_date, '%c/%e/%Y'))),
  market_value_in_eur = IF(REGEXP_REPLACE(@v_market_value_in_eur, '[^0-9]', '') = '', NULL, @v_market_value_in_eur),
  current_club_name   = IF(@v_current_club_name = '' OR @v_current_club_name = 'Unknown', NULL, TRIM(@v_current_club_name)),
  current_club_id     = IF(REGEXP_REPLACE(@v_current_club_id, '[^0-9]', '') = '', NULL, @v_current_club_id),
  player_club_domestic_competition_id = IF(TRIM(@v_player_club_domestic_competition_id) = '', NULL, TRIM(@v_player_club_domestic_competition_id));

COMMIT;

-- --------------------------------------------------------
-- 12. Table & Load Script: transfers
-- --------------------------------------------------------
CREATE TABLE staging_transfermarkt.transfers (
    player_id INT,
    transfer_date DATE,
    transfer_season VARCHAR(255),
    from_club_id INT,
    to_club_id INT,
    from_club_name VARCHAR(255),
    to_club_name VARCHAR(255),
    transfer_fee DECIMAL(15,2), -- Increased scale slightly just in case of record-breaking mega-transfers
    market_value_in_eur INT,
    player_name VARCHAR(255)
);

LOAD DATA INFILE 'C:/ProgramData/MySQL/MySQL Server 8.0/Uploads/transfers.csv'
INTO TABLE staging_transfermarkt.transfers
CHARACTER SET utf8mb4
FIELDS TERMINATED BY ',' 
OPTIONALLY ENCLOSED BY '"'
LINES TERMINATED BY '\r\n'
IGNORE 1 LINES
(
  @v_player_id,
  @v_transfer_date,     
  @v_transfer_season,
  @v_from_club_id,
  @v_to_club_id,
  @v_from_club_name,
  @v_to_club_name,
  @v_transfer_fee,    
  @v_market_value_in_eur,
  @v_player_name,
  @v_leftovers     
)
SET
  player_id         = IF(REGEXP_REPLACE(@v_player_id, '[^0-9]', '') = '', NULL, @v_player_id),
  transfer_date     = IF(@v_transfer_date = '', NULL, IF(@v_transfer_date LIKE '%-%', STR_TO_DATE(@v_transfer_date, '%Y-%m-%d'), STR_TO_DATE(@v_transfer_date, '%c/%e/%Y'))),
  transfer_season   = IF(@v_transfer_season = '', NULL, TRIM(@v_transfer_season)),
  from_club_id      = IF(REGEXP_REPLACE(@v_from_club_id, '[^0-9]', '') = '', NULL, @v_from_club_id),
  to_club_id        = IF(REGEXP_REPLACE(@v_to_club_id, '[^0-9]', '') = '', NULL, @v_to_club_id),
  from_club_name    = IF(@v_from_club_name = '', NULL, TRIM(@v_from_club_name)),
  to_club_name      = IF(@v_to_club_name = '', NULL, TRIM(@v_to_club_name)),
  transfer_fee      = IF(REGEXP_REPLACE(@v_transfer_fee, '[^0-9.]', '') = '', NULL, REGEXP_REPLACE(@v_transfer_fee, '[^0-9.]', '')),
  market_value_in_eur = IF(REGEXP_REPLACE(@v_market_value_in_eur, '[^0-9]', '') = '', NULL, @v_market_value_in_eur),
  player_name       = IF(@v_player_name = '', NULL, TRIM(@v_player_name));
COMMIT;