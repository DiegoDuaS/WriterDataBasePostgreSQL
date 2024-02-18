CREATE TABLE leagues (
    leagueID INT,
    name VARCHAR(20),
    understatNotation VARCHAR(20),
	PRIMARY KEY (leagueID)
);

CREATE TABLE players (
    playerID INT,
    name VARCHAR(150),
	PRIMARY KEY (playerID)
);


CREATE TABLE teams (
    teamID INT PRIMARY KEY,
    name VARCHAR(25)
);

CREATE TABLE games (
    gameID INT,
    leagueID INT,
    season INT,
    date varchar(150),
    homeTeamID INT,
    awayTeamID INT,
    homeGoals INT,
    awayGoals INT,
    homeProbability FLOAT,
    drawProbability FLOAT,
    awayProbability FLOAT,
    homeGoalsHalfTime INT,
    awayGoalsHalfTime INT,
    B365H FLOAT,
    B365D FLOAT,
    B365A FLOAT,
    BWH FLOAT,
    BWD FLOAT,
    BWA FLOAT,
    IWH FLOAT,
    IWD FLOAT,
    IWA FLOAT,
    PSH FLOAT,
    PSD FLOAT,
    PSA FLOAT,
    WHH FLOAT,
    WHD FLOAT,
    WHA FLOAT,
    VCH FLOAT,
    VCD FLOAT,
    VCA FLOAT,
    PSCH FLOAT,
    PSCD FLOAT,
    PSCA FLOAT,
	PRIMARY KEY (gameID),
    FOREIGN KEY (leagueID) REFERENCES leagues(leagueID),
    FOREIGN KEY (homeTeamID) REFERENCES teams(teamID),
    FOREIGN KEY (awayTeamID) REFERENCES teams(teamID)
);


CREATE TABLE appearances (
    gameID INT,
    playerID INT,
    goals INT,
    ownGoals INT,
    shots INT,
    xGoals FLOAT,
    xGoalsChain FLOAT,
    xGoalsBuildup FLOAT,
    assists INT,
    keyPasses INT,
    xAssists FLOAT,
    position VARCHAR(4),
    positionOrder INT,
    yellowCard INT,
    redCard INT,
    time INT,
    substituteIn INT,
    substituteOut INT,
    leagueID INT,
    PRIMARY KEY (gameID, playerID),
    FOREIGN KEY (gameID) REFERENCES games(gameID),
    FOREIGN KEY (playerID) REFERENCES players(playerID),
    FOREIGN KEY (leagueID) REFERENCES leagues(leagueID)
);


CREATE TABLE shots (
    gameID INT,
    shooterID INT,
    assisterID INT,
    minute INT,
    situation VARCHAR(15),
    lastAction VARCHAR(15),
    shotType VARCHAR(15),
    shotResult VARCHAR(15),
    xGoal FLOAT,
    positionX FLOAT,
    positionY FLOAT,
    FOREIGN KEY (gameID) REFERENCES games(gameID),
    FOREIGN KEY (shooterID) REFERENCES players(playerID),
    FOREIGN KEY (assisterID) REFERENCES players(playerID)
);


CREATE TABLE teamstats (
    gameID INT,
    teamID INT,
    season INT,
    date varchar(150),
    location VARCHAR(1),
    goals INT,
    xGoals FLOAT,
    shots INT,
    shotsOnTarget INT,
    deep INT,
    ppda FLOAT,
    fouls INT,
    corners INT,
    yellowCards INT,
    redCards INT,
    result VARCHAR(1),
    PRIMARY KEY (gameID, teamID),
    FOREIGN KEY (gameID) REFERENCES games(gameID),
    FOREIGN KEY (teamID) REFERENCES teams(teamID)
);


