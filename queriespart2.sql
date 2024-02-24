----------------------------INCISO 6----------------------------------
SELECT leagueID, season, player_name, total_goals, total_assists, total_shots, total_keyPasses, total_all_attributes
FROM (
    SELECT 
        a.leagueID, 
        g.season, 
        p.name AS player_name, 
        SUM(a.goals) AS total_goals, 
        SUM(a.assists) AS total_assists, 
        SUM(a.shots) AS total_shots, 
        SUM(a.keyPasses) AS total_keyPasses,
        SUM(a.goals + a.assists + a.shots + a.keyPasses) AS total_all_attributes,
        ROW_NUMBER() OVER(PARTITION BY a.leagueID, g.season ORDER BY SUM(a.goals + a.assists + a.shots + a.keyPasses) DESC) AS row_num
    FROM appearances a
    INNER JOIN players p ON a.playerID = p.playerID
    INNER JOIN games g ON a.gameID = g.gameID
    GROUP BY a.leagueID, g.season, p.name
) AS ranked_players
WHERE 
    row_num = 1;

----------------------------INCISO 7----------------------------------
WITH TeamPerformance AS (
    SELECT gameID, homeTeamID AS teamID, 'home' AS location, homeGoals AS goals, homeProbability AS expected_goals
    FROM games
    UNION ALL
    SELECT gameID, awayTeamID AS teamID, 'away' AS location, awayGoals AS goals, awayProbability AS expected_goals
    FROM games
),
TeamStats AS (
    SELECT t.teamID, t.name AS team_name, tp.location, AVG(tp.goals) AS average_goals, AVG(tp.expected_goals) AS average_expected_goals
    FROM TeamPerformance tp
    INNER JOIN teams t ON tp.teamID = t.teamID
    GROUP BY t.teamID, t.name, tp.location
)
SELECT team_name, location, AVG(average_goals) AS average_goals, AVG(average_expected_goals) AS average_expected_goals, AVG(average_goals - average_expected_goals) AS average_xgoals
FROM TeamStats
GROUP BY team_name, location
ORDER BY average_xgoals DESC;

----------------------------INCISO 8----------------------------------
WITH Leaders AS (
    SELECT
        c.leagueID,
        a.name AS TeamName,
        a.teamID,
        c.season,
        SUM(CASE WHEN c.homeTeamID = a.teamID THEN c.homeGoals ELSE c.awayGoals END) AS GoalsFor,
        SUM(CASE WHEN c.homeTeamID = a.teamID THEN c.awayGoals ELSE c.homeGoals END) AS GoalsAgainst,
        SUM(CASE WHEN c.homeTeamID = a.teamID THEN c.homeGoals ELSE c.awayGoals END) -
        SUM(CASE WHEN c.homeTeamID = a.teamID THEN c.awayGoals ELSE c.homeGoals END) AS GoalDifference,
        RANK() OVER (PARTITION BY c.leagueID, c.season ORDER BY SUM(CASE WHEN c.homeTeamID = a.teamID THEN c.homeGoals ELSE c.awayGoals END) -
        SUM(CASE WHEN c.homeTeamID = a.teamID THEN c.awayGoals ELSE c.homeGoals END) DESC) AS Ranking
    FROM teams a
    JOIN games c ON a.teamID = c.homeTeamID OR a.teamID = c.awayTeamID
    GROUP BY c.leagueID, a.name, c.season, a.teamID
)
SELECT DISTINCT
    b.name as League,
    a.TeamName,
    AVG(d.goals) as avg_goals,
	AVG(d.shots) as avg_shots,
	AVG(d.fouls) as avg_fouls,
	AVG(d.yellowcards) as avg_yellowcards,
	AVG(d.redcards) as avg_redcards
FROM Leaders a
JOIN leagues b on a.leagueid = b.leagueid
JOIN teamstats d on a.teamid = d.teamid
where a.Ranking= 1
GROUP BY b.name, a.TeamName, a.season
ORDER BY b.name;

----------------------------INCISO 9----------------------------------
WITH WinningTeams AS (
    SELECT leagueID, season,
        CASE
            WHEN b365h >= b365d AND b365h >= b365a THEN homeTeamID
            WHEN b365d >= b365h AND b365d >= b365a THEN NULL  
            ELSE awayTeamID
        END AS WinningTeamID
    FROM games
    WHERE b365d < b365h OR b365d < b365a 
)
SELECT RankedTeams.season, l.name AS LeagueName, t.name AS WinningTeamName, RankedTeams.TotalPredictedWins
FROM (
    SELECT season, leagueID, WinningTeamID,
        COUNT(*) AS TotalPredictedWins,
        ROW_NUMBER() OVER(PARTITION BY season, leagueID ORDER BY COUNT(*) DESC) AS RowNumber
    FROM WinningTeams
    WHERE WinningTeamID IS NOT NULL
    GROUP BY season, leagueID, WinningTeamID
) AS RankedTeams
JOIN leagues l ON RankedTeams.leagueID = l.leagueID
JOIN teams t ON RankedTeams.WinningTeamID = t.teamID
WHERE RowNumber = 1
ORDER BY RankedTeams.leagueID DESC, RankedTeams.season ASC;

----------------------------INCISO 10----------------------------------
-- Top 10 mas limpios --
WITH TeamStats AS (
    SELECT
        teamID,
        SUM(fouls) AS total_fouls,
        SUM(yellowCards) AS total_yellow_cards,
        SUM(redCards) AS total_red_cards
    FROM
        teamstats
    GROUP BY
        teamID
)
SELECT
    t.name AS team_name,
    ts.total_fouls,
    ts.total_yellow_cards,
    ts.total_red_cards
FROM
    TeamStats ts
INNER JOIN
    teams t ON ts.teamID = t.teamID
ORDER BY
    ts.total_fouls ASC,
    ts.total_yellow_cards ASC,
    ts.total_red_cards ASC
LIMIT 10;

-- Top 10 mas sucios --
WITH TeamStats AS (
    SELECT
        teamID,
        SUM(fouls) AS total_fouls,
        SUM(yellowCards) AS total_yellow_cards,
        SUM(redCards) AS total_red_cards
    FROM
        teamstats
    GROUP BY
        teamID
)
SELECT
    t.name AS team_name,
    ts.total_fouls,
    ts.total_yellow_cards,
    ts.total_red_cards
FROM
    TeamStats ts
INNER JOIN
    teams t ON ts.teamID = t.teamID
ORDER BY
    ts.total_fouls DESC,
    ts.total_yellow_cards DESC,
    ts.total_red_cards DESC
LIMIT 10;
