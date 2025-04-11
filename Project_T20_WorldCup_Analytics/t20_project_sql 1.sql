CREATE DATABASE t20_worldcup;
USE t20_worldcup;
CREATE TABLE matches (
    match_number INT,
    team1 VARCHAR(255),
    team2 VARCHAR(255),
    date VARCHAR(255),
    match_id INT,
    venue VARCHAR(255),
    city VARCHAR(255),
    toss_winner VARCHAR(255),
    toss_decision VARCHAR(255),
    player_of_match VARCHAR(255),
    umpire1 VARCHAR(255),
    umpire2 VARCHAR(255),
    reserve_umpire VARCHAR(255),
    match_referee VARCHAR(255),
    winner VARCHAR(255),
    winner_runs INT,
    winner_wickets INT,
    match_type VARCHAR(255),
    is_close_match int
);
CREATE TABLE deliveries (
    match_number INT,
    innings INT,
    balls FLOAT,
    batting_team VARCHAR(255),
    bowling_team VARCHAR(255),
    striker VARCHAR(255),
    non_striker VARCHAR(255),
    runs_off_bat INT,
    extras INT,
    running_runs INT,
    fours INT,
    sixes INT,
    total_runs INT,
    bowler VARCHAR(255),
    wicket_type VARCHAR(255),
    caught INT,
    bowled INT,
    lbw INT,
    run_out INT,
    total_wickets INT,
    is_boundary VARCHAR(255),
    player_dismissed VARCHAR(255),
    team1 VARCHAR(255),
    team2 VARCHAR(255),
    date VARCHAR(255),
    venue VARCHAR(255),
    city VARCHAR(255),
    toss_winner VARCHAR(255),
    toss_decision VARCHAR(255),
    player_of_match VARCHAR(255),
    umpire1 VARCHAR(255),
    umpire2 VARCHAR(255),
    reserve_umpire VARCHAR(255),
    match_referee VARCHAR(255),
    winner VARCHAR(255),
    winner_runs INT,
    winner_wickets INT,
    match_type VARCHAR(255),
    match_id INT,
    is_wickets int
);
select * from deliveries;
select * from matches;

/*1. Top 10 Consistent Run Scorers (Batter Strategy)*/
SELECT striker,
       SUM(runs_off_bat) AS total_runs,
       COUNT(DISTINCT match_id) AS matches_played,
       ROUND(SUM(runs_off_bat) / COUNT(DISTINCT match_id), 2) AS avg_runs_per_match
FROM deliveries
GROUP BY striker
ORDER BY total_runs DESC
LIMIT 50;

/*2. Most Destructive Batters (High Strike Rate Min 200 Balls)*/
SELECT striker,
       SUM(runs_off_bat) AS total_runs,
       COUNT(*) AS balls_faced,
       ROUND(SUM(runs_off_bat) * 100.0 / COUNT(*), 2) AS strike_rate
FROM deliveries
GROUP BY striker
HAVING COUNT(*) >= 200
ORDER BY strike_rate DESC
LIMIT 10;

/*3. Best Economical Bowlers (Min 200 Balls)*/
SELECT bowler,
       COUNT(*) AS legal_deliveries,
       SUM(total_runs) AS total_runs_conceded,
       ROUND(SUM(total_runs) * 6.0 / COUNT(*), 2) AS economy_rate
FROM deliveries
GROUP BY bowler
HAVING COUNT(*) >= 200
ORDER BY economy_rate ASC
LIMIT 10;

/*4. Most Wicket-Taking Bowlers*/
SELECT bowler,
       COUNT(CASE 
           WHEN wicket_type IS NOT NULL AND wicket_type NOT IN ('run out', 'retired hurt', 'obstructing the field') THEN 1 
       END) AS wickets
FROM deliveries
GROUP BY bowler
ORDER BY wickets DESC
LIMIT 10;

/*5. Team Win Percentage*/
SELECT team_name,
       COUNT(*) AS matches_played,
       SUM(CASE WHEN team_name = winner THEN 1 ELSE 0 END) AS matches_won,
       ROUND(SUM(CASE WHEN team_name = winner THEN 1 ELSE 0 END) * 100.0 / COUNT(*), 2) AS win_percentage
FROM (
    SELECT team1 AS team_name, match_id, winner FROM matches
    UNION ALL
    SELECT team2 AS team_name, match_id, winner FROM matches
) AS all_matches
GROUP BY team_name
ORDER BY win_percentage DESC;

/*6. Best Opening Pairs (Top Partnerships from Ball 1)*/
SELECT
  FLOOR(balls) AS over_no,
  ROUND((balls - FLOOR(balls)) * 10) AS ball_no
FROM deliveries
LIMIT 10;

SELECT
    striker,
    non_striker,
    COUNT(*) AS balls_played,
    SUM(runs_off_bat) AS partnership_runs
FROM deliveries
WHERE FLOOR(balls) = 0 AND ROUND((balls - FLOOR(balls)) * 10) = 1
GROUP BY striker, non_striker
ORDER BY partnership_runs DESC
LIMIT 10;

/*7. Who Performs in Pressure (Chasing Matches Only)*/
SELECT 
    striker,
    SUM(runs_off_bat) AS runs_chasing,
    COUNT(DISTINCT d.match_id) AS innings_played,
    ROUND(SUM(runs_off_bat) * 1.0 / COUNT(DISTINCT d.match_id), 2) AS avg_chasing
FROM deliveries d
JOIN matches m ON d.match_id = m.match_id
WHERE m.winner_wickets IS NOT NULL
GROUP BY striker
ORDER BY avg_chasing DESC
LIMIT 10;

/*8. Impactful Performers in Knockouts*/
SELECT striker,
       SUM(runs_off_bat) AS total_runs
FROM deliveries d
JOIN matches m ON d.match_id = m.match_id
WHERE m.match_type IN ('Final', 'Semi Final')
GROUP BY striker
ORDER BY total_runs DESC
LIMIT 10;

 /*9. Toss Impact Analysis – Does Toss Matter?*/
SELECT toss_winner,
       COUNT(*) AS toss_won,
       SUM(CASE WHEN toss_winner = winner THEN 1 ELSE 0 END) AS match_won,
       ROUND(SUM(CASE WHEN toss_winner = winner THEN 1 ELSE 0 END) * 100.0 / COUNT(*), 2) AS toss_win_match_win_percent
FROM matches
GROUP BY toss_winner
ORDER BY toss_win_match_win_percent DESC;

/*10. Death Overs Specialists (Overs 16-20)*/
SELECT bowler,
       COUNT(*) AS balls_bowled,
       SUM(total_runs) AS runs_conceded,
       ROUND(SUM(total_runs) * 6.0 / COUNT(*), 2) AS death_economy
FROM deliveries
WHERE FLOOR(balls) BETWEEN 16 AND 20
GROUP BY bowler
HAVING balls_bowled >= 60
ORDER BY death_economy ASC
LIMIT 10;





