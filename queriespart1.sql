----------------------------INCISO 1----------------------------------
SELECT a.name AS TeamName, b.name AS LeagueName,c.season as season, count(c.gameid) as Appearance
FROM teams a
JOIN games c ON a.teamID = c.homeTeamID OR a.teamID = c.awayTeamID
JOIN leagues b ON c.leagueID = b.leagueID
where c.leagueid = 5
group by a.name, b.name, c.season
order by c.season desc;

----------------------------INCISO 2----------------------------------

WITH TeamStats AS (
	SELECT
		c.leagueID,
		a.name AS TeamName,
		c.season,
		SUM(CASE WHEN c.homeTeamID = a.teamID THEN c.homeGoals ELSE c.awayGoals END) AS GoalsFor,
		SUM(CASE WHEN c.homeTeamID = a.teamID THEN c.awayGoals ELSE c.homeGoals END) AS GoalsAgainst,
		SUM(CASE WHEN c.homeTeamID = a.teamID THEN c.homeGoals ELSE c.awayGoals END) -
		SUM(CASE WHEN c.homeTeamID = a.teamID THEN c.awayGoals ELSE c.homeGoals END) AS GoalDifference,
	    RANK() OVER (PARTITION BY c.leagueID, c.season ORDER BY SUM(CASE WHEN c.homeTeamID = a.teamID THEN c.homeGoals ELSE c.awayGoals END) -
        SUM(CASE WHEN c.homeTeamID = a.teamID THEN c.awayGoals ELSE c.homeGoals END) DESC) AS Ranking
	FROM teams a
	JOIN games c ON a.teamID = c.homeTeamID OR a.teamID = c.awayTeamID
	GROUP BY c.leagueID, a.name, c.season
)
SELECT
	a.Ranking,
	a.season,
    b.name as League,
    a.TeamName,
    a.GoalDifference
FROM TeamStats a
JOIN leagues b on a.leagueid = b.leagueid	
where Ranking= 1
ORDER BY b.name, a.season desc;

----------------------------INCISO 3----------------------------------
select a.name, sum(b.goals) as Goals
from players a
join appearances b on a.playerid = b.playerid
group by a.name
order by Goals desc
limit 5;

select 
	b.name, 
	a.lastaction, 
	sum(case when a.shottype = 'RightFoot' then 1 else 0 end) as RightFoot,
	sum(case when a.shottype = 'LeftFoot' then 1 else 0 end) as LeftFoot,
	a.shotresult
from shots a
join players b on a.assisterid = b.playerid
where 
	a.assisterid is not null
	and a.lastaction = 'Pass'
	and a.shotresult = 'Goal'
group by b.name, a.lastaction, a.shotresult
order by RightFoot DESC, LeftFoot DESC;

----------------------------INCISO 4----------------------------------

WITH Probabilities AS (
    SELECT 
        gameID,
        leagueID,
        season,
        homeTeamID,
        awayTeamID,
        MAX(GREATEST(
            1 / NULLIF(B365H, 0), 1 / NULLIF(BWH, 0), 1 / NULLIF(IWH, 0), 
            1 / NULLIF(PSH, 0), 1 / NULLIF(WHH, 0), 1 / NULLIF(VCH, 0), 
            1 / NULLIF(PSCH, 0)
        )) AS MaxHomeWinProb,
        MAX(GREATEST(
            1 / NULLIF(B365D, 0), 1 / NULLIF(BWD, 0), 1 / NULLIF(IWD, 0), 
            1 / NULLIF(PSD, 0), 1 / NULLIF(WHD, 0), 1 / NULLIF(VCD, 0), 
            1 / NULLIF(PSCD, 0)
        )) AS MaxDrawProb,
        MAX(GREATEST(
            1 / NULLIF(B365A, 0), 1 / NULLIF(BWA, 0), 1 / NULLIF(IWA, 0), 
            1 / NULLIF(PSA, 0), 1 / NULLIF(WHA, 0), 1 / NULLIF(VCA, 0), 
            1 / NULLIF(PSCA, 0)
        )) AS MaxAwayWinProb
    FROM games
    GROUP BY gameID, leagueID, season, homeTeamID, awayTeamID
),
MaxProbabilities AS (
    SELECT 
        p.leagueID,
        p.season,
        p.homeTeamID AS teamID,
        'Home' AS HomeOrAway,
        MAX(p.MaxHomeWinProb) AS MaxWinProb
    FROM Probabilities p
    GROUP BY p.leagueID, p.season, p.homeTeamID
    UNION ALL
    SELECT 
        p.leagueID,
        p.season,
        p.awayTeamID AS teamID,
        'Away' AS HomeOrAway,
        MAX(p.MaxAwayWinProb) AS MaxWinProb
    FROM Probabilities p
    GROUP BY p.leagueID, p.season, p.awayTeamID
)
SELECT 
    m.season,
    l.name AS League,
    t.name AS Name,
    m.HomeOrAway as Location,
    MAX(m.MaxWinProb) AS WinProbability
FROM MaxProbabilities m
JOIN leagues l ON m.leagueID = l.leagueID
JOIN teams t ON m.teamID = t.teamID
GROUP BY m.season, l.name, t.name, m.HomeOrAway
ORDER BY m.season, l.name, MAX(m.MaxWinProb) DESC;


----------------------------INCISO 5----------------------------------
WITH Probabilities AS (
    SELECT 
        gameID,
        leagueID,
        season,
        homeTeamID,
        awayTeamID,
        MAX(GREATEST(
            1 / NULLIF(B365H, 0), 1 / NULLIF(BWH, 0), 1 / NULLIF(IWH, 0), 
            1 / NULLIF(PSH, 0), 1 / NULLIF(WHH, 0), 1 / NULLIF(VCH, 0), 
            1 / NULLIF(PSCH, 0)
        )) AS MaxHomeWinProb,
        MAX(GREATEST(
            1 / NULLIF(B365D, 0), 1 / NULLIF(BWD, 0), 1 / NULLIF(IWD, 0), 
            1 / NULLIF(PSD, 0), 1 / NULLIF(WHD, 0), 1 / NULLIF(VCD, 0), 
            1 / NULLIF(PSCD, 0)
        )) AS MaxDrawProb,
        MAX(GREATEST(
            1 / NULLIF(B365A, 0), 1 / NULLIF(BWA, 0), 1 / NULLIF(IWA, 0), 
            1 / NULLIF(PSA, 0), 1 / NULLIF(WHA, 0), 1 / NULLIF(VCA, 0), 
            1 / NULLIF(PSCA, 0)
        )) AS MaxAwayWinProb
    FROM games
    GROUP BY gameID, leagueID, season, homeTeamID, awayTeamID
),
MaxProbabilities AS (
    SELECT 
        p.leagueID,
        p.season,
        p.homeTeamID AS teamID,
        'Home' AS HomeOrAway,
        MAX(p.MaxHomeWinProb) AS MaxWinProb
    FROM Probabilities p
    GROUP BY p.leagueID, p.season, p.homeTeamID
    UNION ALL
    SELECT 
        p.leagueID,
        p.season,
        p.awayTeamID AS teamID,
        'Away' AS HomeOrAway,
        MAX(p.MaxAwayWinProb) AS MaxWinProb
    FROM Probabilities p
    GROUP BY p.leagueID, p.season, p.awayTeamID
),
RankedProbabilities AS (
    SELECT 
        m.season,
        l.name AS League,
        t.name AS TeamName,
        m.HomeOrAway,
        MAX(m.MaxWinProb) AS WinProbability,
        RANK() OVER (PARTITION BY m.season, l.name ORDER BY MAX(m.MaxWinProb) DESC) AS Rank
    FROM MaxProbabilities m
    JOIN leagues l ON m.leagueID = l.leagueID
    JOIN teams t ON m.teamID = t.teamID
    GROUP BY m.season, l.name, t.name, m.HomeOrAway
)
SELECT 
    season,
    League,
    TeamName,
    WinProbability,
    Rank
FROM RankedProbabilities
where Rank =1
ORDER BY WinProbability desc;

----------------------------------------QUERIES ADICIONALES------------------
--Suma de puntos en todas las temporadas--
WITH TeamTotalPoints AS (
    SELECT
        t.teamID,
        t.name AS TeamName,
        g.season,
        SUM(CASE WHEN ts.result = 'W' THEN 3 WHEN ts.result = 'D' THEN 1 ELSE 0 END) AS SeasonPoints
    FROM teams t
    JOIN games g ON t.teamID = g.homeTeamID OR t.teamID = g.awayTeamID
    JOIN teamstats ts ON t.teamID = ts.teamID AND g.gameID = ts.gameID
    GROUP BY t.teamID, TeamName, g.season
)
SELECT
    TeamName,
    MAX(CASE WHEN season = '2014' THEN SeasonPoints END) AS Points_2014,
    MAX(CASE WHEN season = '2015' THEN SeasonPoints END) AS Points_2015,
    MAX(CASE WHEN season = '2016' THEN SeasonPoints END) AS Points_2016,
    MAX(CASE WHEN season = '2017' THEN SeasonPoints END) AS Points_2017,
    MAX(CASE WHEN season = '2018' THEN SeasonPoints END) AS Points_2018,
    MAX(CASE WHEN season = '2019' THEN SeasonPoints END) AS Points_2019,
    MAX(CASE WHEN season = '2020' THEN SeasonPoints END) AS Points_2020
FROM TeamTotalPoints
GROUP BY TeamName
ORDER BY SUM(SeasonPoints) desc;


--Mejora en goles de la primera temporada comparado con la ultima--
WITH TeamGoals AS (
    SELECT
        t.teamID,
        t.name AS TeamName,
        g.season,
        COALESCE(SUM(CASE WHEN t.teamID = g.homeTeamID THEN g.homeGoals ELSE g.awayGoals END), 0) AS GoalsScored
    FROM teams t
    LEFT JOIN games g ON t.teamID = g.homeTeamID OR t.teamID = g.awayTeamID
    GROUP BY t.teamID, TeamName, g.season
)
SELECT
    TeamName,
    COALESCE(SUM(CASE WHEN season = '2014' THEN GoalsScored END), 0) AS GoalsScoredin2014,
    COALESCE(SUM(CASE WHEN season = '2015' THEN GoalsScored END), 0) AS GoalsScoredin2015,
    COALESCE(SUM(CASE WHEN season = '2016' THEN GoalsScored END), 0) AS GoalsScoredin2016,
    COALESCE(SUM(CASE WHEN season = '2017' THEN GoalsScored END), 0) AS GoalsScoredin2017,
    COALESCE(SUM(CASE WHEN season = '2018' THEN GoalsScored END), 0) AS GoalsScoredin2018,
    COALESCE(SUM(CASE WHEN season = '2019' THEN GoalsScored END), 0) AS GoalsScoredin2019,
    COALESCE(SUM(CASE WHEN season = '2020' THEN GoalsScored END), 0) AS GoalsScoredin2020,
    COALESCE(SUM(GoalsScored), 0) AS TotalGoals
FROM TeamGoals
GROUP BY TeamName
ORDER BY TotalGoals DESC;

































		
		
		
		
		
		