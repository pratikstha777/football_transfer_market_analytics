CREATE DATABASE IF NOT EXISTS production_transfermarket;
USE production_transfermarket;

-- BASE DIMENSION TABLES

CREATE TABLE countries (
    country_id INT PRIMARY KEY,
    country_name VARCHAR(150) NOT NULL,
    country_code VARCHAR(10),
    confederation VARCHAR(50),
    total_clubs INT DEFAULT 0,
    total_players INT DEFAULT 0,
    average_age DECIMAL(4,2),
    url VARCHAR(500)
);
CREATE TABLE competitions (
    competition_id VARCHAR(50) PRIMARY KEY,
    competition_code VARCHAR(100) NOT NULL,
    name VARCHAR(255) NOT NULL,
    sub_type VARCHAR(100),
    type VARCHAR(100),
    country_id INT,
    country_name VARCHAR(150),
    domestic_league_code VARCHAR(50),
    confederation VARCHAR(50),
    total_clubs INT DEFAULT 0,
    url VARCHAR(500),
    FOREIGN KEY (country_id) REFERENCES countries(country_id)
);
CREATE TABLE clubs (
    club_id INT PRIMARY KEY,
    club_code VARCHAR(150) NOT NULL,
    name VARCHAR(255) NOT NULL,
    domestic_competition_id VARCHAR(50),
    total_market_value VARCHAR(100),    
    squad_size INT,
    average_age DECIMAL(4,2),
    foreigners_number INT,
    foreigners_percentage DECIMAL(5,2),
    national_team_players INT,
    stadium_name VARCHAR(255),
    stadium_seats INT,
    net_transfer_record VARCHAR(100),
    coach_name VARCHAR(255),
    last_season INT,
    filename VARCHAR(255),
    url VARCHAR(500),
    FOREIGN KEY (domestic_competition_id) REFERENCES competitions(competition_id)
);
CREATE TABLE national_teams (
    national_team_id INT PRIMARY KEY,
    name VARCHAR(255) NOT NULL,
    team_code VARCHAR(100),
    country_id INT,
    country_name VARCHAR(150),
    country_code VARCHAR(10),
    confederation VARCHAR(50),
    team_image_url VARCHAR(500),
    squad_size INT,
    average_age DECIMAL(4,2),
    foreigners_number INT,
    foreigners_percentage DECIMAL(5,2),
    total_market_value BIGINT,
    coach_name VARCHAR(255),
    fifa_ranking INT,
    last_season INT,
    url VARCHAR(500),
    FOREIGN KEY (country_id) REFERENCES countries(country_id)
);

CREATE TABLE players (
    player_id INT PRIMARY KEY,
    first_name VARCHAR(150),
    last_name VARCHAR(150),
    name VARCHAR(255) NOT NULL,
    last_season INT,
    current_club_id INT,
    player_code VARCHAR(150),
    country_of_birth VARCHAR(150),
    city_of_birth VARCHAR(150),
    country_of_citizenship VARCHAR(150),
    date_of_birth DATE,
    sub_position VARCHAR(100),
    position VARCHAR(100),
    foot VARCHAR(20),
    height_in_cm INT,
    contract_expiration_date DATE,
    agent_name VARCHAR(255),
    image_url VARCHAR(500),
    international_caps INT DEFAULT 0,
    international_goals INT DEFAULT 0,
    current_national_team_id INT,
    url VARCHAR(500),
    current_club_domestic_competition_id VARCHAR(50),
    current_club_name VARCHAR(255),
    market_value_in_eur DECIMAL(15,2),
    highest_market_value_in_eur DECIMAL(15,2),
    FOREIGN KEY (current_club_id) REFERENCES clubs(club_id),
    FOREIGN KEY (current_national_team_id) REFERENCES national_teams(national_team_id),
    FOREIGN KEY (current_club_domestic_competition_id) REFERENCES competitions(competition_id)
);

-- FACT AND LOGS TABLES
CREATE TABLE player_valuations (
    valuation_id INT AUTO_INCREMENT PRIMARY KEY, -- Artificial surrogate primary tracking key
    player_id INT NOT NULL,
    date DATE NOT NULL,
    market_value_in_eur DECIMAL(15,2) NOT NULL,
    current_club_name VARCHAR(255),
    current_club_id INT,
    player_club_domestic_competition_id VARCHAR(50),
    FOREIGN KEY (player_id) REFERENCES players(player_id),
    FOREIGN KEY (current_club_id) REFERENCES clubs(club_id),
    FOREIGN KEY (player_club_domestic_competition_id) REFERENCES competitions(competition_id)
);

CREATE TABLE transfers (
    transfer_id INT AUTO_INCREMENT PRIMARY KEY,
    player_id INT NOT NULL,
    transfer_date DATE,
    transfer_season VARCHAR(20),
    from_club_id INT,
    to_club_id INT,
    from_club_name VARCHAR(255),
    to_club_name VARCHAR(255),
    transfer_fee DECIMAL(15,2),
    market_value_in_eur DECIMAL(15,2),
    player_name VARCHAR(255),
    FOREIGN KEY (player_id) REFERENCES players(player_id),
    FOREIGN KEY (from_club_id) REFERENCES clubs(club_id),
    FOREIGN KEY (to_club_id) REFERENCES clubs(club_id)
);

CREATE TABLE games (
    game_id INT PRIMARY KEY,
    competition_id VARCHAR(50),
    season INT,
    round VARCHAR(100),
    date DATE,
    home_club_id INT,
    away_club_id INT,
    home_club_goals INT DEFAULT 0,
    away_club_goals INT DEFAULT 0,
    home_club_position INT,
    away_club_position INT,
    home_club_manager_name VARCHAR(255),
    away_club_manager_name VARCHAR(255),
    stadium VARCHAR(255),
    attendance INT,
    referee VARCHAR(255),
    url VARCHAR(500),
    home_club_formation VARCHAR(50),
    away_club_formation VARCHAR(50),
    home_club_name VARCHAR(255),
    away_club_name VARCHAR(255),
    aggregate VARCHAR(50),
    competition_type VARCHAR(100),
    FOREIGN KEY (competition_id) REFERENCES competitions(competition_id),
    FOREIGN KEY (home_club_id) REFERENCES clubs(club_id),
    FOREIGN KEY (away_club_id) REFERENCES clubs(club_id)
);

-- GRANULARTRANSACTIONAL SUB-FACT TABLES(DEPEND ON GAMES)
CREATE TABLE appearances (
    appearance_id VARCHAR(100) PRIMARY KEY, -- Provided combined alphanumeric unique key
    game_id INT NOT NULL,
    player_id INT NOT NULL,
    player_club_id INT,
    player_current_club_id INT,
    date DATE,
    player_name VARCHAR(255),
    competition_id VARCHAR(50),
    yellow_cards INT DEFAULT 0,
    red_cards INT DEFAULT 0,
    goals INT DEFAULT 0,
    assists INT DEFAULT 0,
    minutes_played INT DEFAULT 0,
    FOREIGN KEY (game_id) REFERENCES games(game_id),
    FOREIGN KEY (player_id) REFERENCES players(player_id),
    FOREIGN KEY (player_club_id) REFERENCES clubs(club_id),
    FOREIGN KEY (player_current_club_id) REFERENCES clubs(club_id),
    FOREIGN KEY (competition_id) REFERENCES competitions(competition_id)
);

CREATE TABLE club_games (
    club_game_id INT AUTO_INCREMENT PRIMARY KEY,
    game_id INT NOT NULL,
    club_id INT NOT NULL,
    own_goals INT DEFAULT 0,
    own_position INT,
    own_manager_name VARCHAR(255),
    opponent_id INT,
    opponent_goals INT DEFAULT 0,
    opponent_position INT,
    opponent_manager_name VARCHAR(255),
    hosting VARCHAR(50),
    is_win INT,
    FOREIGN KEY (game_id) REFERENCES games(game_id),
    FOREIGN KEY (club_id) REFERENCES clubs(club_id),
    FOREIGN KEY (opponent_id) REFERENCES clubs(club_id)
);

CREATE TABLE game_events (
    game_event_id VARCHAR(100) PRIMARY KEY, -- MD5 Hex String Unique Entry Tracker
    date DATE,
    game_id INT NOT NULL,
    minute INT NOT NULL,
    type VARCHAR(100),
    club_id INT,
    club_name VARCHAR(255),
    player_id INT,
    description TEXT,
    player_in_id INT,
    player_assist_id INT,
    FOREIGN KEY (game_id) REFERENCES games(game_id),
    FOREIGN KEY (club_id) REFERENCES clubs(club_id),
    FOREIGN KEY (player_id) REFERENCES players(player_id),
    FOREIGN KEY (player_in_id) REFERENCES players(player_id),
    FOREIGN KEY (player_assist_id) REFERENCES players(player_id)
);

CREATE TABLE game_lineups (
    game_lineups_id VARCHAR(100) PRIMARY KEY, -- Alphanumeric unique key
    date DATE,
    game_id INT NOT NULL,
    player_id INT NOT NULL,
    club_id INT NOT NULL,
    player_name VARCHAR(255),
    type VARCHAR(100),                       -- 'starting_lineup', 'substitutes'
    position VARCHAR(100),
    number INT,
    team_captain TINYINT(1) DEFAULT 0,
    FOREIGN KEY (game_id) REFERENCES games(game_id),
    FOREIGN KEY (player_id) REFERENCES players(player_id),
    FOREIGN KEY (club_id) REFERENCES clubs(club_id)
);