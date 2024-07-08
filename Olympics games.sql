/* The primary goal was to utilize SQL queries to extract and analyze pertinent information from the comprehensive Olympic Games data set. 
This task involved understanding the data set, identifying relevant information, and then implementing SQL queries to fetch this information effectively. 
This process enabled me to gain valuable insights into various aspects of the Olympic Games, contributing to a deeper understanding of this global sporting event.*/


CREATE TABLE athhlete_games
(
	id        int,
	name 	  varchar(255),
	sex 	  varchar(255),
	age		  varchar(255),
    height	  varchar(255),
	weight	  varchar(255),
	team	  varchar(255),
	noc 	  varchar(255),
	games	  varchar(255),
	year	  int,
	season	  varchar(255),
	city	  varchar(255),
	sport	  varchar(255),
	event	  varchar(255),
	medal     varchar(255)
)
;

CREATE TABLE noc_regions 
(
	noc       varchar(255),
	region	  varchar(255),
	notes 	  varchar(255)
)
;

SELECT * 
FROM athlete_games;

SELECT *
FROM noc_regions;

-- Total numbers of olumpic games held --
SELECT COUNT(DISTINCT games)
FROM athlete_games;

-- All olympic games held --
SELECT DISTINCT year, season, city 
FROM athlete_games
ORDER BY year ASC;

-- Total number of countries participated in each games --
SELECT DISTINCT games, COUNT(DISTINCT region) AS total_number_of_countries
FROM athlete_games AS ag
INNER JOIN noc_regions AS nr
ON ag.noc = nr.noc
GROUP BY games;
 
-- Showing olympic games with the highest and lowest participating countries --
WITH b1 AS 
	(SELECT DISTINCT games, region
FROM athlete_games AS ag
JOIN noc_regions AS nr
ON ag.noc = nr.noc
GROUP BY games, region
ORDER BY games),
b2 AS
(SELECT games, COUNT(DISTINCT region) AS no_of_countries
FROM b1
GROUP BY games)
	SELECT DISTINCT
	CONCAT(first_value(games) OVER(ORDER BY no_of_countries), ' - ',
first_value(no_of_countries) OVER(ORDER BY no_of_countries)) AS lowest_countries,
CONCAT(first_value(games) OVER(ORDER BY no_of_countries DESC), ' - ',
first_value(no_of_countries) OVER(ORDER BY no_of_countries DESC))AS highest_countries
FROM b2
GROUP BY games, no_of_countries;

-- Showing nations that have particpated in all the olympic games --
WITH b3 AS
	(SELECT COUNT(DISTINCT games) AS total_games
FROM athlete_games),
b4 AS 
	(SELECT DISTINCT region, COUNT(DISTINCT games) AS total_participated_games
FROM athlete_games AS ag
JOIN noc_regions AS nr
ON ag.noc = nr.noc
	GROUP BY region)
SELECT region, total_participated_games
FROM b4
JOIN b3 
	ON b4.total_participated_games = b3.total_games

-- Showing sports that have played in all summer olympic games --
WITH b5 AS 
	(SELECT COUNT(DISTINCT games) AS total_summer_games
FROM athlete_games
WHERE season = 'Summer'),
b6 AS 
	(SELECT sport, COUNT(DISTINCT games) AS summer_total_games
FROM athlete_games
GROUP BY sport)
SELECT sport, total_summer_games
FROM b6
JOIN b5 
ON b5.total_summer_games = b6.summer_total_games
GROUP BY sport, total_summer_games;

-- Showing sports that was played only once in the olympics --
WITH b7 AS
	(SELECT sport, COUNT(DISTINCT games) AS no_of_games
FROM athlete_games
GROUP BY sport),
b8 AS
	(SELECT DISTINCT games, sport
FROM athlete_games)
SELECT b7.sport, b7.no_of_games, b8.games
FROM b7
JOIN b8
ON b7.sport = b8.sport
WHERE no_of_games = '1'

-- Showing number of sports played in each olympic -- 
WITH b9 AS 
	(SELECT DISTINCT games, COUNT(sport) AS sport
FROM athlete_games
GROUP BY games
ORDER BY games),
c1 AS 
	(SELECT COUNT(DISTINCT sport) AS sport, games
FROM athlete_games
GROUP BY games
ORDER BY games)
SELECT b9.games, c1.sport
FROM b9
JOIN C1
ON b9.games = C1.games
ORDER BY sport DESC

-- Showing oldest athletes to win a gold medal --
WITH c3 AS 
	(SELECT name, sex, age, medal, team, sport,
DENSE_RANK() OVER(ORDER BY age DESC) AS rnk
FROM athlete_games
WHERE age <> 'NA' AND medal ='Gold'
GROUP BY age, name, medal, sex, sport, team
ORDER BY age DESC)
	SELECT name, sex, age, medal, team, sport
	FROM c3
	WHERE rnk = '1'

-- Showing top five athletes who have won the most gold medals --
WITH a1 AS 
	(SELECT name, team, medal
FROM athlete_games
WHERE medal = 'Gold'),
a2 AS 
	(SELECT name, team, COUNT(medal) OVER(PARTITION BY name ORDER BY medal) AS medal
FROM a1)
	SELECT name, team, medal
FROM a2
GROUP BY name, team, medal
ORDER by medal DESC
LIMIT 5;

-- Showing top five athletes who have won the most medals --SELECT name, team, medal
SELECT name, team, COUNT(medal) as total_medals
FROM athlete_games
WHERE medal != 'NA'
GROUP BY name, team
ORDER BY total_medals DESC
LIMIT 5;

-- Showing top five countries with the most medals --
SELECT region, COUNT(medal) AS total_medals 
FROM athlete_games AS ag
JOIN noc_regions AS nr
ON ag.noc = nr.noc
WHERE medal != 'NA'
GROUP BY region
ORDER BY total_medals DESC
LIMIT 5

-- Showing sport where India has won the most medals --
SELECT sport, COUNT(medal) AS total_medals
FROM athlete_games AS ag
JOIN noc_regions AS nr
ON ag.noc = nr.noc
WHERE region = 'India' AND medal != 'NA'
GROUP BY sport 
ORDER BY total_medals DESC
LIMIT 1

-- Showing olympic games where India won a medal in hockey --
WITH c1 AS 
	(SELECT games, region, sport, COUNT(medal) AS total_medals
FROM athlete_games AS ag 
JOIN noc_regions AS nr
ON ag.noc = nr.noc
WHERE medal != 'NA'
GROUP BY games, region, sport)
	SELECT games, region, sport, total_medals
FROM c1
WHERE region = 'India' AND sport = 'Hockey'
ORDER BY total_medals DESC;

-- Showing total bronze, gold and silver won by each country -- 
SELECT region,
	COALESCE(bronze, 0) AS bronze,
	COALESCE(gold, 0) AS gold,
	COALESCE(silver, 0) AS silver
FROM CROSSTAB('SELECT region, medal, COUNT(medal) as total_medals
	FROM athlete_games AS ag
	JOIN noc_regions AS nr
	ON ag.noc = nr.noc
	WHERE medal != ''NA''
	GROUP BY region, medal',
'VALUES (''Bronze''), (''Gold''), (''Silver'')')
AS RESULT(region varchar,bronze bigint, gold bigint, silver bigint)
	ORDER BY bronze DESC, gold DESC, silver DESC;

-- Showing total bronze, gold and silver won by each country corresponding to each olumpic games --
SELECT SUBSTRING (games, 1, POSITION(' - ' IN games) - 1) AS games,
	SUBSTRING (games, POSITION(' - ' IN games) + 3) AS region,
	COALESCE(bronze, 0) AS bronze,
	COALESCE(gold, 0) AS gold,
	COALESCE(silver, 0) AS silver
FROM CROSSTAB('SELECT CONCAT(games, '' - '', region) AS games, medal, COUNT(medal) as total_medals
	FROM athlete_games AS ag
	JOIN noc_regions AS nr
	ON ag.noc = nr.noc
	WHERE medal != ''NA''
	GROUP BY games, region, medal
	ORDER BY games',
'VALUES (''Bronze''), (''Gold''), (''Silver'')')
AS RESULT(games varchar,bronze bigint, gold bigint, silver bigint);

-- Showing countries that have never won gold medal but have won silver and bronze medals --
WITH a1 AS	
(SELECT region,
	COALESCE(bronze, 0) AS bronze,
	COALESCE(gold, 0) AS gold,
	COALESCE(silver, 0) AS silver
FROM CROSSTAB('SELECT region, medal, COUNT(medal) as total_medals
	FROM athlete_games AS ag
	JOIN noc_regions AS nr
	ON ag.noc = nr.noc
	WHERE medal != ''NA''
	GROUP BY region, medal',
'VALUES (''Bronze''), (''Gold''), (''Silver'')')
AS RESULT(region varchar, gold bigint, bronze bigint, silver bigint))
SELECT region, gold, bronze, silver
FROM a1 
WHERE gold = '0'
GROUP BY region, gold, bronze, silver;

-- Identify which country won the most gold, most silver and most bronze medals in each olympic games --
WITH b1 AS (SELECT SUBSTRING (games, 1, POSITION(' - ' IN games) - 1) AS games,
	SUBSTRING (games, POSITION(' - ' IN games) + 3) AS region,
	COALESCE(bronze, 0) AS bronze,
	COALESCE(gold, 0) AS gold,
	COALESCE(silver, 0) AS silver
FROM CROSSTAB('SELECT CONCAT(games, '' - '', region) AS games, medal, COUNT(medal) as total_medals
	FROM athlete_games AS ag
	JOIN noc_regions AS nr
	ON ag.noc = nr.noc
	WHERE medal != ''NA''
	GROUP BY games, region, medal
	ORDER BY games',
'VALUES (''Bronze''), (''Gold''), (''Silver'')')
AS RESULT(games varchar,bronze bigint, gold bigint, silver bigint))
SELECT DISTINCT games,
	CONCAT(FIRST_VALUE(region) OVER(PARTITION BY games ORDER BY bronze DESC), 
	' - ', 
FIRST_VALUE(bronze) OVER(PARTITION BY games ORDER BY bronze DESC)) AS bronze,
	CONCAT(FIRST_VALUE(region) OVER(PARTITION BY games ORDER BY gold DESC),
	' - ', 
FIRST_VALUE(gold) OVER(PARTITION BY games ORDER BY gold DESC)) AS gold,
	CONCAT(FIRST_VALUE(region) OVER(PARTITION BY games ORDER BY region DESC), 
	' - ', 
FIRST_VALUE(silver) OVER(PARTITION BY games ORDER BY silver DESC)) AS silver
FROM b1
ORDER BY games, bronze DESC, gold DESC, silver DESC 















