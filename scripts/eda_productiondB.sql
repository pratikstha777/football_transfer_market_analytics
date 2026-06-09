
-- PROJECT PHASE: EDA & VALIDATION
-- DESCRIPTION: Baseline footprint validation metrics


SELECT 
    -- Total records across primary tables
    (SELECT COUNT(*) FROM games) AS total_games_migrated,
    (SELECT COUNT(*) FROM players) AS total_unique_players,
    (SELECT COUNT(*) FROM clubs) AS total_clubs,
    (SELECT COUNT(*) FROM appearances) AS total_player_appearances,
    
    -- Timeframe coverage
    (SELECT MIN(date) FROM games) AS data_start_date,
    (SELECT MAX(date) FROM games) AS data_end_date;
    
-- Player Analytics:
with player_career_totals as (
	select 
    p.player_id,
    p.name as player_name,
    sum(a.minutes_played) as total_minutes,
    sum(a.goals) as total_goals,
    sum(a.assists) as total_assists
    from players p
    inner join appearances a on p.player_id = a.player_id
    group by p.player_id, p.name
)
select
	player_name,
    total_minutes,
    total_goals,
    total_assists,
    round(total_minutes/ total_goals,2) as minutes_per_goal,
    round(((total_goals + total_assists)* 90)/ total_minutes,2) as contributions_per_90
    from player_career_totals
    where total_minutes >= 500
		and total_goals > 0
    order by minutes_per_goal asc
    limit 20;
    
-- Management Analytics

select 
	own_manager_name as manager_name,
    count(game_id) as total_games_managed,
    sum(case when is_win = 1 then 1 else 0 end) as total_wins,
    round((sum(case when is_win = 1 then 1 else 0 end)/ count(game_id)) * 100, 2) as overall_win_percentage,
    
    round((sum(case when hosting = 'home' and is_win = 1 then 1 else 0 end)/
		nullif(sum(case when hosting ='home' then 1 else 0 end), 0)) * 100, 2) as home_win_per,
        
    round((sum(case when hosting = 'away' and is_win = 1 then 1 else 0 end)/
		nullif(sum(case when hosting ='away' then 1 else 0 end), 0)) * 100, 2) as away_win_per  
        
from club_games
where own_manager_name is not null
group by own_manager_name
having total_games_managed >=20
order by overall_win_percentage desc;

-- Core stats profile for view

create or replace view v_player_career_profiles as
select
	p.player_id,
    p.name as player_name,
    p.position,
    p.sub_position,
    c.name as current_club_name,
    count(distinct a.game_id) as total_matches_played,
    sum(a.minutes_played) as career_minutes,
    sum(a.goals) as career_goal,
    sum(a.assists) as career_assists,
    sum(a.yellow_cards) as career_yellow_cards,
    sum(a.red_cards) as career_red_cards

from players p
left join appearances a on p.player_id = a.player_id
left join clubs c on p.current_club_id = c.club_id
group by p.player_id, p.name, p.position, p.sub_position, c.name;

	

