INSERT INTO production_transfermarket.competitions (
    competition_id,
    competition_code,
    name,
    sub_type,
    type,
    country_id,
    country_name,
    domestic_league_code,
    confederation,
    total_clubs,
    url
)
SELECT 
    competition_id,
    competition_code,
    name,
    sub_type,
    type,
    country_id,
    country_name,
    domestic_league_code,
    confederation,
    CAST(ROUND(total_clubs, 0) AS SIGNED) AS total_clubs, -- Formats DECIMAL(10,2) cleanly into an INT
    url
FROM staging_transfermarkt.competitions;

INSERT INTO production_transfermarket.clubs (
    club_id,
    club_code,
    name,
    domestic_competition_id,
    total_market_value,
    squad_size,
    average_age,
    foreigners_number,
    foreigners_percentage,
    national_team_players,
    stadium_name,
    stadium_seats,
    net_transfer_record,
    coach_name,
    last_season,
    filename,
    url
)
SELECT 
    club_id,
    club_code,
    name,
    domestic_competition_id,
    CAST(total_market_value AS CHAR(100)) AS total_market_value, -- Safe BIGINT to VARCHAR conversion
    squad_size,
    CAST(average_age AS DECIMAL(4,2)) AS average_age,            -- Safe down-casting
    foreigners_number,
    CAST(foreigners_percentage AS DECIMAL(5,2)) AS foreigners_percentage, -- Safe down-casting
    national_team_players,
    stadium_name,
    stadium_seats,
    net_transfer_record,
    coach_name,
    last_season,
    filename,
    url
FROM staging_transfermarkt.clubs;

INSERT INTO production_transfermarket.players (
    player_id,
    first_name,
    last_name,
    name,
    last_season,
    current_club_id,
    player_code,
    country_of_birth,
    city_of_birth,
    country_of_citizenship,
    date_of_birth,
    sub_position,
    position,
    foot,
    height_in_cm,
    contract_expiration_date,
    agent_name,
    image_url,
    international_caps,
    international_goals,
    current_national_team_id,
    url,
    current_club_domestic_competition_id,
    current_club_name,
    market_value_in_eur,
    highest_market_value_in_eur
)
SELECT 
    player_id,
    LEFT(first_name, 150) AS first_name,   -- Narrowed from VARCHAR(255)
    LEFT(last_name, 150) AS last_name,     -- Narrowed from VARCHAR(255)
    name,                                  -- Mandatory production NOT NULL field
    last_season,
    current_club_id,
    LEFT(player_code, 150) AS player_code, -- Narrowed from VARCHAR(255)
    LEFT(country_of_birth, 150) AS country_of_birth,
    LEFT(city_of_birth, 150) AS city_of_birth,
    LEFT(country_of_citizenship, 150) AS country_of_citizenship,
    date_of_birth,
    LEFT(sub_position, 100) AS sub_position,
    LEFT(position, 100) AS position,
    LEFT(foot, 20) AS foot,                 -- Narrowed from VARCHAR(255) to VARCHAR(20)
    height_in_cm,
    contract_expiration_date,
    agent_name,
    LEFT(image_url, 500) AS image_url,     -- Expanded safely up to 500 characters
    CAST(ROUND(COALESCE(international_caps, 0), 0) AS SIGNED) AS international_caps, -- DECIMAL(10,2) to INT
    CAST(ROUND(COALESCE(international_goals, 0), 0) AS SIGNED) AS international_goals, -- DECIMAL(10,2) to INT
    current_national_team_id,
    LEFT(url, 500) AS url,                 -- Expanded safely up to 500 characters
    LEFT(current_club_domestic_competition_id, 50) AS current_club_domestic_competition_id, -- Narrowed to VARCHAR(50)
    current_club_name,
    CAST(market_value_in_eur AS DECIMAL(15,2)) AS market_value_in_eur,                 -- INT to DECIMAL(15,2)
    CAST(highest_market_value_in_eur AS DECIMAL(15,2)) AS highest_market_value_in_eur   -- INT to DECIMAL(15,2)
FROM staging_transfermarkt.players
WHERE name IS NOT NULL;

INSERT INTO production_transfermarket.player_valuations (
    player_id,
    date,
    market_value_in_eur,
    current_club_name,
    current_club_id,
    player_club_domestic_competition_id
)
SELECT 
    player_id,
    date,
    CAST(market_value_in_eur AS DECIMAL(15,2)) AS market_value_in_eur, -- Upgrades INT to DECIMAL(15,2)
    current_club_name,
    current_club_id,
    LEFT(player_club_domestic_competition_id, 50) AS player_club_domestic_competition_id -- Clips safely to target constraint
FROM staging_transfermarkt.player_valuations
WHERE player_id IS NOT NULL 
  AND date IS NOT NULL 
  AND market_value_in_eur IS NOT NULL;
  
  INSERT INTO production_transfermarket.transfers (
    player_id,
    transfer_date,
    transfer_season,
    from_club_id,
    to_club_id,
    from_club_name,
    to_club_name,
    transfer_fee,
    market_value_in_eur,
    player_name
)
SELECT 
    player_id,
    transfer_date,
    LEFT(transfer_season, 20) AS transfer_season, -- Narrowed from staging's broad VARCHAR(255)
    from_club_id,
    to_club_id,
    from_club_name,
    to_club_name,
    transfer_fee, -- Standard direct mapping (already structured as DECIMAL)
    CAST(market_value_in_eur AS DECIMAL(15,2)) AS market_value_in_eur, -- Converts INT to production DECIMAL
    player_name
FROM staging_transfermarkt.transfers
WHERE player_id IS NOT NULL; -- Safeguards strict production foreign key constraint


INSERT INTO production_transfermarket.games (
    game_id,
    competition_id,
    season,
    round,
    date,
    home_club_id,
    away_club_id,
    home_club_goals,
    away_club_goals,
    home_club_position,
    away_club_position,
    home_club_manager_name,
    away_club_manager_name,
    stadium,
    attendance,
    referee,
    url,
    home_club_formation, -- Absent in staging; populated as NULL
    away_club_formation, -- Absent in staging; populated as NULL
    home_club_name,
    away_club_name,
    aggregate,
    competition_type
)
SELECT 
    game_id,
    LEFT(competition_id, 50) AS competition_id,               -- Truncated from VARCHAR(255) to VARCHAR(50)
    season,
    LEFT(round, 100) AS round,                                 -- Truncated from VARCHAR(255) to VARCHAR(100)
    STR_TO_DATE(date, '%Y-%m-%d') AS date,                     -- Cleanses dirty text format into strict DATE
    home_club_id,
    away_club_id,
    COALESCE(home_club_goals, 0) AS home_club_goals,           -- Fallback matching default value constraint
    COALESCE(away_club_goals, 0) AS away_club_goals,           -- Fallback matching default value constraint
    CAST(NULLIF(home_club_position, '') AS SIGNED) AS home_club_position, -- Safely converts text positions to INT
    CAST(NULLIF(away_club_position, '') AS SIGNED) AS away_club_position, -- Safely converts text positions to INT
    home_club_manager_name,
    away_club_manager_name,
    stadium,
    CAST(NULLIF(REGEXP_REPLACE(attendance, '[^0-9]', ''), '') AS SIGNED) AS attendance, -- Strips non-numeric chars (commas/spaces) before casting to INT
    referee,
    LEFT(url, 500) AS url,                                     -- Safeguards TEXT down to VARCHAR(500)
    NULL AS home_club_formation,                               -- Explicit placeholder for target column alignment
    NULL AS away_club_formation,                               -- Explicit placeholder for target column alignment
    home_club_name,
    away_club_name,
    LEFT(aggregate, 50) AS aggregate,
    LEFT(competition_type, 100) AS competition_type            -- Truncated from VARCHAR(255) to VARCHAR(100)
FROM staging_transfermarkt.games
WHERE game_id IS NOT NULL;

INSERT INTO club_games (
    game_id,
    club_id,
    own_goals,
    own_position,
    own_manager_name,
    opponent_id,
    opponent_goals,
    opponent_position,
    opponent_manager_name,
    hosting,
    is_win
)
SELECT 
    game_id,
    club_id,
    COALESCE(own_goals, 0) AS own_goals,
    CAST(FLOOR(own_position) AS SIGNED) AS own_position, -- Strips decimal tail into INT
    own_manager_name,
    opponent_id,
    COALESCE(opponent_goals, 0) AS opponent_goals,
    CAST(FLOOR(opponent_position) AS SIGNED) AS opponent_position, -- Strips decimal tail into INT
    opponent_manager_name,
    LEFT(hosting, 50) AS hosting,                        -- Safely bound to VARCHAR(50)
    is_win
FROM staging_transfermarkt.club_games
WHERE game_id IS NOT NULL 
  AND club_id IS NOT NULL;
  
  INSERT INTO appearances (
    appearance_id,
    game_id,
    player_id,
    player_club_id,
    player_current_club_id,
    date,
    player_name,
    competition_id,
    yellow_cards,
    red_cards,
    goals,
    assists,
    minutes_played
)
SELECT 
    CAST(appearance_id AS CHAR(100)) AS appearance_id, -- Maps INT over to a unique VARCHAR index
    game_id,
    player_id,
    player_club_id,
    player_current_club_id,
    date,
    player_name,
    LEFT(competition_id, 50) AS competition_id,        -- Limits string bounds to match VARCHAR(50)
    COALESCE(yellow_cards, 0) AS yellow_cards,
    COALESCE(red_cards, 0) AS red_cards,
    COALESCE(goals, 0) AS goals,
    COALESCE(assists, 0) AS assists,
    COALESCE(minutes_played, 0) AS minutes_played
FROM staging_transfermarkt.appearances
WHERE appearance_id IS NOT NULL
  AND game_id IS NOT NULL
  AND player_id IS NOT NULL;
  
  
INSERT INTO game_events (
    game_event_id,
    date,
    game_id,
    minute,
    type,
    club_id,
    club_name,
    player_id,
    description,
    player_in_id,
    player_assist_id
)
SELECT 
    LEFT(game_event_id, 100) AS game_event_id, -- Caps string structure to VARCHAR(100)
    date,
    CAST(game_id AS SIGNED) AS game_id,         -- Safely maps down BIGINT to INT
    minute,
    LEFT(type, 100) AS type,                   -- Truncates text down to VARCHAR(100)
    club_id,
    club_name,
    CAST(player_id AS SIGNED) AS player_id,
    description,                               -- Transitions seamlessly from VARCHAR(255) to TEXT
    CAST(player_in_id AS SIGNED) AS player_in_id,
    CAST(player_assist_id AS SIGNED) AS player_assist_id
FROM staging_transfermarkt.game_events
WHERE game_event_id IS NOT NULL
  AND game_id IS NOT NULL 
  AND minute IS NOT NULL;

INSERT INTO game_lineups (
    game_lineups_id,
    date,
    game_id,
    player_id,
    club_id,
    player_name,
    type,
    position,
    number,
    team_captain
)
SELECT 
    LEFT(game_lineups_id, 100) AS game_lineups_id, -- Fits string index inside production bounds
    date,
    CAST(game_id AS SIGNED) AS game_id,             -- Downcasts system IDs into INT boundaries
    CAST(player_id AS SIGNED) AS player_id,
    club_id,
    player_name,
    LEFT(type, 100) AS type,                       -- Standardizes size for lineup categories
    LEFT(position, 100) AS position,               -- Caps long player position texts
    number,
    CASE 
        WHEN team_captain = 1 THEN 1 
        ELSE 0 
    END AS team_captain                            -- Standardizes integer values into TINYINT(1)
FROM staging_transfermarkt.game_lineups
WHERE game_lineups_id IS NOT NULL
  AND game_id IS NOT NULL
  AND player_id IS NOT NULL
  AND club_id IS NOT NULL;