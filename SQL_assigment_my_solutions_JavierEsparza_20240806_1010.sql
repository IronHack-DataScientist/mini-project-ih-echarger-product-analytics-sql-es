-- LEVEL 1

-- Question 1: Number of users with sessions
SELECT COUNT(DISTINCT user_id) AS number_of_users_with_sessions
FROM Sessions;

-- Question 2: Number of chargers used by user with id 1
SELECT COUNT(DISTINCT charger_id) AS number_of_chargers_used
FROM Sessions
WHERE user_id = 1;


-- LEVEL 2

-- Question 3: Number of sessions per charger type (AC/DC):
SELECT c.type, COUNT(s.id) AS session_count
FROM Chargers c
JOIN Sessions s ON c.id = s.charger_id
GROUP BY c.type;

-- Question 4: Chargers being used by more than one user
SELECT charger_id
FROM Sessions
GROUP BY charger_id
HAVING COUNT(DISTINCT user_id) > 1;

-- Question 5: Average session time per charger
SELECT charger_id, AVG(strftime('%s', end_time) - strftime('%s', start_time)) AS average_session_time_seconds
FROM Sessions
GROUP BY charger_id;


-- LEVEL 3

-- Question 6: Full username of users that have used more than one charger in one day (NOTE: for date only consider start_time)
SELECT DISTINCT u.name || ' ' || u.surname AS full_name
FROM Users u
JOIN (
    SELECT user_id, date(start_time) AS session_date
    FROM Sessions
    GROUP BY user_id, date(start_time)
    HAVING COUNT(DISTINCT charger_id) > 1
) filtered ON u.id = filtered.user_id;

-- Question 7: Top 3 chargers with longer sessions
SELECT charger_id, AVG(strftime('%s', end_time) - strftime('%s', start_time)) AS average_session_length
FROM Sessions
GROUP BY charger_id
ORDER BY average_session_length DESC
LIMIT 3;

-- Question 8: Average number of users per charger (per charger in general, not per charger_id specifically)
SELECT AVG(user_count) AS average_users_per_charger
FROM (
    SELECT charger_id, COUNT(DISTINCT user_id) AS user_count
    FROM Sessions
    GROUP BY charger_id
) AS counts;

-- Question 9: Top 3 users with more chargers being used
SELECT user_id, COUNT(DISTINCT charger_id) AS chargers_count
FROM Sessions
GROUP BY user_id
ORDER BY chargers_count DESC
LIMIT 3;


-- LEVEL 4

-- Question 10: Number of users that have used only AC chargers, DC chargers or both
SELECT 
    user_id,
    SUM(CASE WHEN c.type = 'AC' THEN 1 ELSE 0 END) AS AC_Usage_Count,
    SUM(CASE WHEN c.type = 'DC' THEN 1 ELSE 0 END) AS DC_Usage_Count,
    COUNT(*) AS Total_Usage_Count
FROM Sessions s
JOIN Chargers c ON s.charger_id = c.id
GROUP BY user_id;


-- Question 11: Monthly average number of users per charger
SELECT strftime('%Y-%m', start_time) AS month, charger_id, AVG(user_count) AS average_users
FROM (
    SELECT start_time, charger_id, COUNT(DISTINCT user_id) AS user_count
    FROM Sessions
    GROUP BY charger_id, strftime('%Y-%m', start_time)
) GROUPED
GROUP BY charger_id;

-- Question 12: Top 3 users per charger (for each charger, number of sessions)
SELECT charger_id, user_id, COUNT(id) AS session_count
FROM Sessions
GROUP BY charger_id, user_id
ORDER BY charger_id, session_count DESC;


-- LEVEL 5

-- Question 13: Top 3 users with longest sessions per month (consider the month of start_time)
SELECT strftime('%Y-%m', start_time) AS month, user_id, MAX(session_length) AS longest_session
FROM (
    SELECT start_time, user_id, (strftime('%s', end_time) - strftime('%s', start_time)) AS session_length
    FROM Sessions
) AS session_lengths
GROUP BY month, user_id
ORDER BY month, longest_session DESC
LIMIT 3;
    
-- Question 14. Average time between sessions for each charger for each month (consider the month of start_time)
SELECT charger_id, strftime('%Y-%m', start_time) AS month, AVG(time_diff) AS average_time_between_sessions
FROM (
    SELECT charger_id, start_time,
           (strftime('%s', start_time) - strftime('%s', LAG(end_time) OVER (PARTITION BY charger_id ORDER BY start_time))) AS time_diff
    FROM Sessions
) WHERE time_diff IS NOT NULL
GROUP BY charger_id, month;
