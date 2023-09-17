DROP table if exists instagram.location cascade;
create table instagram.location(
	location_id bigint primary key,
	name varchar(255) not null,
	street varchar(255),
	zip varchar(255),
	city varchar(255),
	region varchar(255),
	cd varchar(16),
	phone varchar(255)
);

DROP table if exists instagram.profile cascade;
create table instagram.profile(
	profile_id bigint primary key,
	profile_name varchar(255) not null,
	first_last_name varchar(255),
	description text,
	url text
);

DROP table if exists instagram.date cascade;
create table instagram.date(
	date_id bigint primary key,
	day integer,
	month integer,
	year integer,
	weekday varchar(16),
	month_name varchar(16)
);

DROP table if exists instagram.time cascade;
create table instagram.time(
	time_id bigint primary key,
	hour integer,
	minute integer,
	second integer,
	is_night boolean,
	is_day boolean
);

DROP table if exists instagram.post;
CREATE TABLE instagram.post (
    profile_id bigint,
    time_id bigint,
    date_id bigint,
    location_id bigint,
    number_of_likes bigint,
    number_of_comments bigint,
    description TEXT,
    post_type TEXT,
    FOREIGN KEY (profile_id) REFERENCES instagram.profile(profile_id) on delete set null on update cascade,
    FOREIGN KEY (time_id) REFERENCES instagram.time(time_id) on delete set null on update cascade,
    FOREIGN KEY (date_id) REFERENCES instagram.date(date_id) on delete set null on update cascade,
    FOREIGN KEY (location_id) REFERENCES instagram.location(location_id) on delete set null on update cascade
);

DROP table if exists instagram.statistics;
CREATE TABLE instagram.statistics (
    profile_id bigint,
    time_id bigint,
    date_id bigint,
    number_of_followers bigint,
    number_of_following bigint,
    number_of_posts bigint,
    total_likes bigint,
    total_comments bigint,
    FOREIGN KEY (profile_id) REFERENCES instagram.profile(profile_id) on delete set null on update cascade,
    FOREIGN KEY (time_id) REFERENCES instagram.time(time_id) on delete set null on update cascade,
    FOREIGN KEY (date_id) REFERENCES instagram.date(date_id) on delete set null on update cascade
);
