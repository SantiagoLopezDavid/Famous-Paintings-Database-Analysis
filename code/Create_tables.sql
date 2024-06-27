/*Create tables*/

CREATE TABLE artist (
 	artist_id INT,
 	full_name VARCHAR(50),
	first_name VARCHAR(50),
	middle_names VARCHAR(50),
	last_name VARCHAR(50),
	nationality VARCHAR(50),
	style VARCHAR(50),
	birth INT,
	death INT);

CREATE TABLE canvas_size (
 	size_ide INT,
 	width INT,
	height INT,
	label VARCHAR(50);
	
CREATE TABLE image_link (
 	work_id INT,
 	url VARCHAR(1000),
	thumbnail_small_url VARCHAR(1000),
	thumbnail_large_url VARCHAR(1000),
	label VARCHAR(50);
	
CREATE TABLE museum (
 	museum_id INT,
 	name VARCHAR(100),
	address VARCHAR(100),
	city VARCHAR(50),
	state VARCHAR(50),
	postal VARCHAR(50),
	country VARCHAR(50),
	phone VARCHAR(50),
	url VARCHAR(50);

CREATE TABLE museum_hours (
 	museum_id INT,
 	day VARCHAR(50),
	open VARCHAR(50),
	close VARCHAR(50);

CREATE TABLE product_size (
 	work_id INT,
 	size_id INT,
	sale_price INT,
	regular_price INT;
	
CREATE TABLE museum (
 	work_id INT,
 	subject VARCHAR(50);

CREATE TABLE work (
 	work_id INT,
 	name VARCHAR(50),
	artist_id INT,
	style VARCHAR(50),
	museum_id INT;
	