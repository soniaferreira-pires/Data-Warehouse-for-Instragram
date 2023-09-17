CREATE SEQUENCE instagram.time_time_id_seq;

CREATE SEQUENCE instagram.date_date_id_seq;


INSERT INTO instagram.date(date_id, day, month, year, weekday, month_name)
SELECT nextval('instagram.date_date_id_seq'), day, month, year, weekday, month_name
FROM (
    SELECT DISTINCT
        EXTRACT(DAY FROM cts) AS day,
        EXTRACT(MONTH FROM cts) AS month,
        EXTRACT(YEAR FROM cts) AS year,
        to_char(cts, 'Day') AS weekday,
        to_char(cts, 'Month') AS month_name
    FROM dwproject.posts
    UNION ALL
    SELECT DISTINCT
        EXTRACT(DAY FROM cts) AS day,
        EXTRACT(MONTH FROM cts) AS month,
        EXTRACT(YEAR FROM cts) AS year,
        to_char(cts, 'Day') AS weekday,
        to_char(cts, 'Month') AS month_name
    FROM dwproject.profiles
) subq;

SELECT * FROM instagram.date
ORDER BY date_id;


SELECT COUNT(*) FROM instagram.date;


DELETE FROM instagram.time;



INSERT INTO instagram.time(time_id, hour, minute, second, is_night, is_day)
SELECT nextval('instagram.time_time_id_seq'), h.hour, m.minute, s.second,
    CASE WHEN h.hour >= 18 OR h.hour < 6 THEN true ELSE false END AS is_night,
    CASE WHEN h.hour >= 6 AND h.hour < 18 THEN true ELSE false END AS is_day
FROM (SELECT generate_series(0, 23) AS hour) h
CROSS JOIN (SELECT generate_series(0, 59) AS minute) m
CROSS JOIN (SELECT generate_series(0, 59) AS second) s;






DELETE FROM instagram.time t1
WHERE EXISTS (
    SELECT 1
    FROM instagram.time t2
    WHERE t1.hour = t2.hour AND t1.minute = t2.minute AND t1.second = t2.second AND t1.is_night = t2.is_night AND t1.is_day = t2.is_day AND t1.time_id > t2.time_id
);




SELECT hour, minute, second, COUNT(*)
FROM instagram.time
GROUP BY time_id, hour, minute, second
HAVING COUNT(*) > 1;




SELECT * FROM instagram.time limit 100;


SELECT COUNT(*) FROM instagram.time;






SELECT EXTRACT(HOUR FROM cts) AS hour,
       EXTRACT(MINUTE FROM cts) AS minute,
       EXTRACT(SECOND FROM cts) AS second,
       COUNT(*)
FROM (
    SELECT cts FROM dwproject.posts
    UNION ALL
    SELECT cts FROM dwproject.profiles
) subq
GROUP BY hour, minute, second
HAVING COUNT(*) > 1;







INSERT INTO instagram.location(location_id, name, street, zip, city, region, cd, phone)
select distinct
id,
name,
street,
zip,
city,
region,
cd,
phone
from dwproject.locations;

















INSERT INTO instagram.profile (profile_id, profile_name, first_last_name, description, url)
SELECT
  profile_id,
  profile_name,
  firstname_lastname,
  descritpion,
  url
FROM (
  SELECT
    profile_id,
    profile_name,
    firstname_lastname,
    descritpion,
    url,
    ROW_NUMBER() OVER (PARTITION BY profile_id ORDER BY followers_ DESC) AS row_num
  FROM dwproject.profiles
) subquery
WHERE row_num = 1
ON CONFLICT DO NOTHING;


SELECT COUNT(*) FROM instagram.profile;

SELECT COUNT(DISTINCT profile_id) FROM dwproject.posts;







WITH post_stats AS (
    SELECT profile_id, SUM(numbr_likes) AS total_likes, SUM(number_comments) AS total_comments
    FROM dwproject.posts
    GROUP BY profile_id
)
SELECT d.date_id, COUNT(*)
FROM dwproject.profiles
JOIN instagram.profile p ON profiles.profile_id = p.profile_id
JOIN instagram.Time t ON EXTRACT(HOUR FROM profiles.cts) = t.hour AND EXTRACT(MINUTE FROM profiles.cts) = t.minute AND EXTRACT(SECOND FROM profiles.cts)::integer = t.second
JOIN instagram.Date d ON EXTRACT(DAY FROM profiles.cts) = d.day AND EXTRACT(MONTH FROM profiles.cts) = d.month AND EXTRACT(YEAR FROM profiles.cts) = d.year
JOIN post_stats ps ON profiles.profile_id = ps.profile_id
GROUP BY d.date_id;













WITH post_stats AS (
    SELECT profile_id, SUM(numbr_likes) AS total_likes, SUM(number_comments) AS total_comments
    FROM dwproject.posts
    GROUP BY profile_id
)
INSERT INTO instagram.statistics (profile_id, time_id, date_id, number_of_followers, number_of_following, number_of_posts, total_likes, total_comments)
SELECT p.profile_id, MAX(t.time_id), MAX(d.date_id), MAX(profiles.followers_), MAX(profiles.following_), MAX(profiles.n_posts), MAX(ps.total_likes), MAX(ps.total_comments)
FROM dwproject.profiles
JOIN instagram.profile p ON profiles.profile_id = p.profile_id
JOIN instagram.Time t ON EXTRACT(HOUR FROM profiles.cts) = t.hour AND EXTRACT(MINUTE FROM profiles.cts) = t.minute AND EXTRACT(SECOND FROM profiles.cts)::integer = t.second
JOIN instagram.Date d ON EXTRACT(DAY FROM profiles.cts) = d.day AND EXTRACT(MONTH FROM profiles.cts) = d.month AND EXTRACT(YEAR FROM profiles.cts) = d.year
JOIN post_stats ps ON profiles.profile_id = ps.profile_id
GROUP BY p.profile_id;

SELECT * FROM instagram.statistics limit 100;

SELECT COUNT(*) FROM instagram.statistics;



SELECT *
FROM instagram.statistics
ORDER BY date_id;


SELECT COUNT(DISTINCT date_id)
FROM instagram.statistics;


SELECT profile_id, date_id, time_id, COUNT(*)
FROM instagram.statistics
GROUP BY profile_id, date_id, time_id
HAVING COUNT(*) > 1



INSERT INTO instagram.post (profile_id, time_id, date_id, location_id, number_of_likes, number_of_comments, description, post_type)
SELECT MAX(p.profile_id), MAX(t.time_id), MAX(d.date_id), MAX(l.location_id), MAX(posts.numbr_likes), MAX(posts.number_comments), MAX(posts.description), MAX(posts.post_type)
FROM dwproject.posts
JOIN instagram.profile p ON posts.profile_id = p.profile_id
JOIN instagram.Time t ON EXTRACT(HOUR FROM posts.cts) = t.hour AND EXTRACT(MINUTE FROM posts.cts) = t.minute AND EXTRACT(SECOND FROM posts.cts) = t.second
JOIN instagram.Date d ON EXTRACT(DAY FROM posts.cts) = d.day AND EXTRACT(MONTH FROM posts.cts) = d.month AND EXTRACT(YEAR FROM posts.cts) = d.year
JOIN instagram.Location l ON posts.location_id = l.location_id
GROUP BY posts.post_id;



SELECT * FROM instagram.post limit 100;



SELECT COUNT(*) FROM instagram.post;
