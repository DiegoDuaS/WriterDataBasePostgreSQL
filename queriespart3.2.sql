----------------------------QUERY 3----------------------------------
WITH TeamPerformance AS (
    SELECT
        t.name,
        SUM(CASE WHEN g.homeTeamID = t.teamID THEN g.homeGoals ELSE g.awayGoals END) AS goals_scored,
        SUM(CASE WHEN g.homeTeamID = t.teamID THEN g.awayGoals ELSE g.homeGoals END) AS goals_conceded,
        CASE WHEN g.homeTeamID = t.teamID THEN 'Home' ELSE 'Away' END AS location,
        ROW_NUMBER() OVER(PARTITION BY CASE WHEN g.homeTeamID = t.teamID THEN 'Home' ELSE 'Away' END ORDER BY SUM(CASE WHEN g.homeTeamID = t.teamID THEN g.homeGoals ELSE g.awayGoals END) DESC) AS ranking
    FROM
        teams t
    JOIN
        games g ON t.teamID = g.homeTeamID OR t.teamID = g.awayTeamID
    GROUP BY
        t.name, location
)
SELECT
    location,
    name,
    SUM(goals_scored) AS total_goals_scored,
    SUM(goals_conceded) AS total_goals_conceded,
    SUM(goals_scored) - SUM(goals_conceded) AS goal_difference
FROM
    TeamPerformance
WHERE
    ranking <= 5
GROUP BY
    location, name
ORDER BY
    location, goal_difference DESC;
	
----------------------------QUERY 4----------------------------------
SELECT 
    p.name AS player_name,
    COUNT(DISTINCT a.gameID) AS total_games_played,
    SUM(a.yellowcard) AS total_yellow,
    SUM(a.redcard) AS total_red,
    (SUM(a.yellowcard) + SUM(a.redcard)) / CAST(COUNT(DISTINCT a.gameID) AS FLOAT) AS average_cards_per_game
FROM 
    appearances a
INNER JOIN 
    players p ON a.playerID = p.playerID
GROUP BY 
    p.name
HAVING 
    COUNT(DISTINCT a.gameID) > 50
ORDER BY 
    average_cards_per_game DESC;








