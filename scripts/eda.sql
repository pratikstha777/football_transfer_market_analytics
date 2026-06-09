-- Check total volume across key tables
SELECT 'games' AS table_name, COUNT(*) AS row_count FROM staging_transfermarkt.games
UNION ALL
SELECT 'transfers', COUNT(*) FROM staging_transfermarkt.transfers
UNION ALL
SELECT 'game_events', COUNT(*) FROM staging_transfermarkt.game_events;

-- Verify your date transformation worked (Should look like YYYY-MM-DD and not be NULL)
SELECT transfer_date, player_name, transfer_fee 
FROM staging_transfermarkt.transfers 
WHERE transfer_date IS NOT NULL 
LIMIT 100;

-- EDA(Exploratory Data Analysis)
SELECT 
    player_name,
    transfer_season,
    from_club_name,
    to_club_name,
    market_value_in_eur,
    transfer_fee,
    (transfer_fee - market_value_in_eur) AS premium_paid_eur
FROM staging_transfermarkt.transfers
WHERE transfer_fee IS NOT NULL AND market_value_in_eur IS NOT NULL
ORDER BY premium_paid_eur DESC -- Top overpaid transfers
LIMIT 10;


SELECT 
    transfer_season,
    to_club_name AS club_name,
    SUM(transfer_fee) AS total_spent_eur,
    COUNT(player_id) AS total_players_signed
FROM staging_transfermarkt.transfers
WHERE transfer_fee IS NOT NULL AND to_club_name IS NOT NULL
GROUP BY transfer_season, to_club_name
ORDER BY total_spent_eur DESC
LIMIT 15;


SELECT 
    stadium,
    home_club_name,
    away_club_name,
    CAST(REPLACE(attendance, ',', '') AS UNSIGNED) AS clean_attendance, -- Cast string to number if needed
    (home_club_goals + away_club_goals) AS total_goals
FROM staging_transfermarkt.games
WHERE attendance IS NOT NULL
ORDER BY clean_attendance DESC
LIMIT 10;