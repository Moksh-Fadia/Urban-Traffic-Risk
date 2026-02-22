USE urban_traffic_analytics;

SELECT * FROM violations LIMIT 5;
SELECT * FROM city_violation_fatalities LIMIT 5;
SELECT * FROM state_accidents LIMIT 5;
SELECT * FROM accidents LIMIT 5;


-- Leading causes of road deaths
Select category, Sum(killed_2022) as 2022_deaths, Sum(killed_2023) as 2023_deaths 
From violations
Group by category
Order by 2022_deaths Desc, 2023_deaths Desc;


-- Frequency vs severity of accidents by violation type (for 2023)
SELECT category, accidents_2023, fatality_rate_2023,
    CASE
        WHEN accidents_2023 > 100000 AND fatality_rate_2023 > 4 THEN 'High Frequency – High Severity'
        WHEN accidents_2023 > 100000 THEN 'High Frequency – Low Severity'
        WHEN fatality_rate_2023 > 4 THEN 'Low Frequency – High Severity'
        ELSE 'Low Frequency – Low Severity'
    END AS risk_profile
FROM violations;


-- Rising risk/severity of accidents by violation type from 2022 to 2023
SELECT category, fatality_rate_2022, fatality_rate_2023,
    Round((fatality_rate_2023 - fatality_rate_2022), 2) AS severity_change,
    RANK() OVER (ORDER BY (fatality_rate_2023 - fatality_rate_2022) DESC) AS severity_worsening_rank
FROM violations;


-- Cities contributing to major traffic accidents (ie. high-risk cities)
Select city, total_fatalities as accidents
From city_violation_fatalities
Order by total_fatalities Desc
LIMIT 10;


-- Cause-wise accidents in high-risk cities
SELECT city, overspeeding, drunken_driving_drugs_use, wrong_side_driving, jumping_red_light, using_mobile_phone
FROM city_violation_fatalities
ORDER BY total_fatalities DESC
LIMIT 10;


-- States with most accidents and their national share (in 2023)
SELECT state, accidents,
    ROUND(
        accidents /
        (SELECT SUM(accidents) FROM state_accidents WHERE year = 2023) * 100.0,
        2) AS national_share_percent
FROM state_accidents
WHERE year = 2023
ORDER BY accidents DESC
LIMIT 10;


-- Change in fatality rate over the years (to check whether deaths have increased or reduced over the 5 yrs)
SELECT year, fatality_rate,
	RANK() OVER (ORDER BY fatality_rate DESC) AS danger_rank
FROM accidents
ORDER BY year;


-- Count of national deaths by violation + its national share percentage
SELECT v.category, v.killed_2023 AS violation_deaths, a.fatalities AS total_national_deaths,
    ROUND(v.killed_2023 / a.fatalities * 100, 2) AS share_of_national_deaths_percent
FROM violations v
JOIN accidents a
ON a.year = 2023
ORDER BY share_of_national_deaths_percent DESC;


-- Covid period wise-comparison of accidents
SELECT
    CASE
        WHEN year = 2020 THEN 'Covid Year'
        WHEN year < 2020 THEN 'Pre-Covid'
        ELSE 'Post-Covid'
    END AS period,
    Round(AVG(accidents), 2) AS avg_accidents,
    Round(AVG(fatalities), 2) AS avg_fatalities,
    Round(AVG(fatality_rate), 2) AS avg_fatality_rate
FROM accidents
GROUP BY period;


-- Rank of years based on accidents and fatalities
SELECT year, accidents, fatalities,
	RANK() OVER (ORDER BY accidents DESC) AS accident_rank,
	RANK() OVER (ORDER BY fatalities DESC) AS fatality_rank
FROM accidents;


-- States performance 2023 vs 2022 
SELECT s23.state, s22.accidents AS accidents_2022, s23.accidents AS accidents_2023,
    ROUND(
    ((s23.accidents - s22.accidents) / s22.accidents) * 100, 
    2) AS percentage_growth
FROM state_accidents s23
JOIN state_accidents s22 
ON s23.state = s22.state
WHERE s23.year = 2023 AND s22.year = 2022
ORDER BY percentage_growth DESC;



