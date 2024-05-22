/* Football Player Analysis

*/


-- Create a database to start

CREATE DATABASE project
CHARACTER SET utf8mb4
COLLATE utf8mb4_unicode_ci;


USE project;


-- Create a table

CREATE TABLE players (
	PlayerID INT,
    PlayerName VARCHAR(255),
    PlayerAge INT,
    ValuePlayer INT,
    Team VARCHAR(255),
    Nationality VARCHAR(255),
    Position VARCHAR(100)
) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;


-- Show my folder to save my file

SHOW VARIABLES LIKE 'secure_file_priv';

LOAD DATA INFILE 'C:\\ProgramData\\MySQL\\MySQL Server 8.0\\Uploads\\transfermarkt_players_data.csv'
INTO TABLE players
CHARACTER SET utf8mb4
FIELDS TERMINATED BY ',' OPTIONALLY ENCLOSED BY '"' ESCAPED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 ROWS
(Playerid, PlayerName, PlayerAge, @ValuePlayer, Team, Nationality, Position)
SET ValuePlayer = NULLIF(TRIM(@ValuePlayer), '');


-- Show Table

SELECT *
FROM project.players;


-- Top 10 highest valued players

SELECT *
FROM project.players
ORDER BY ValuePlayer DESC
LIMIT 10;


-- Search for players from my country

SELECT PlayerName, PlayerAge, Team, ValuePlayer
FROM project.players
WHERE Nationality='Greece' AND valuePlayer IS NOT NULL
ORDER BY ValuePlayer DESC;


-- Player value analysis by age category

SELECT 
	PlayerAge AS Age,
	AVG(valueplayer) AS AverageValue,
    MAX(ValuePlayer) AS Max_Value, 
    MIN(ValuePlayer) AS Min_Value
FROM project.players
GROUP BY PlayerAge
ORDER BY PlayerAge;


-- Analysis of Player Value Ratio by Nationality

SELECT Nationality, ROUND(AVG(ValuePlayer))AS AverageValue
FROM project.players
GROUP BY Nationality
ORDER BY AverageValue DESC
LIMIT 10;


-- Analysis of Teams with the Highest Total Player Value Over One Billion

SELECT Team, SUM(ValuePlayer) AS TotalValue
FROM project.players
GROUP BY Team
HAVING SUM(ValuePlayer) > 1000000000
ORDER BY TotalValue DESC;


-- Talent Search (U21) High Value Players

SELECT PlayerName, PlayerAge AS Age, ValuePlayer, Nationality, Team
FROM project.players
WHERE PlayerAge < 21 AND ValuePlayer > 10000000
ORDER BY ValuePlayer DESC;


-- Analysis of the Top 10 Teams by Total Value Featuring Their Three Highest-Paid Players

WITH TopTeams AS(
	SELECT 
		Team, 
        SUM(ValuePlayer) AS TotalValue
	FROM project.players
	GROUP BY Team
	ORDER BY TotalValue DESC
	LIMIT 10
)
, TopPlayers AS (
	SELECT tt.Team, tt.TotalValue, pp.PlayerName, pp.ValuePlayer,
		ROW_NUMBER() OVER (PARTITION BY tt.Team ORDER BY pp.ValuePlayer DESC) AS PlayerRank
    FROM project.players AS pp
    INNER JOIN TopTeams tt ON pp.Team=tt.Team
)
SELECT Team, PlayerName, ValuePlayer
FROM TopPlayers
WHERE PlayerRank<=3
ORDER BY TotalValue DESC, ValuePlayer DESC;


-- Using TEMP TABLE to perform calculation on Partition By in previous query 

-- Create TEMP Table for the Top 10 Teams by Total values

CREATE TEMPORARY TABLE IF NOT EXISTS TopTeams AS
SELECT Team, SUM(ValuePlayer) AS TotalValue
FROM project.players
GROUP BY Team
ORDER BY TotalValue DESC
LIMIT 10;

-- Create TEMP Table for Highest Players

CREATE TEMPORARY TABLE IF NOT EXISTS TopPlayers AS
SELECT 
    tt.Team, 
    tt.TotalValue,
    pp.PlayerName, 
    pp.ValuePlayer,
    ROW_NUMBER() OVER (PARTITION BY tt.Team ORDER BY pp.ValuePlayer DESC) AS PlayerRank
FROM project.players pp
INNER JOIN TopTeams tt ON pp.Team = tt.Team;

-- Display Results by Team
SELECT Team, PlayerName, ValuePlayer
FROM TopPlayers
WHERE PlayerRank <= 3
ORDER BY TotalValue DESC, ValuePlayer DESC;

-- Delete Temponary Table After Use

DROP TABLE IF EXISTS TopTeams;
DROP TABLE IF EXISTS TopPlayers;


-- Creating View to store data for later visualisations

CREATE VIEW SimplePlayerView AS
SELECT PlayerName, Team, ValuePlayer
FROM players
WHERE ValuePlayer > 1000000;


