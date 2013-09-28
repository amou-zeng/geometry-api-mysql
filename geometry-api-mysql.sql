DELIMITER $$

DROP TABLE IF EXISTS `geo_data`
$$
CREATE TABLE `geo_data` (
	`uid` VARCHAR(255) NOT NULL,
	`latitude` FLOAT(10, 6) NOT NULL,
	`longitude` FLOAT(10, 6) NOT NULL
) ENGINE=MyISAM DEFAULT CHARSET utf8
$$

DROP FUNCTION IF EXISTS `geoDistanceBetween`
$$
-- get distance between two geometry
CREATE FUNCTION `geoDistanceBetween` (lat1 DOUBLE, lon1 DOUBLE, lat2 DOUBLE, lon2 DOUBLE)
	RETURNS DOUBLE
BEGIN
	DECLARE rad1 DOUBLE;
	DECLARE rad2 DOUBLE;
	DECLARE subLat DOUBLE;
	DECLARE subLon DOUBLE;
	
	SET rad1 = radians(lat1);
	SET rad2 = radians(lat2);
	SET subLat = rad1 - rad2;
	SET subLon = radians(lon1) - radians(lon2);
	
	RETURN 6378137 * 2 * ASIN(SQRT( POWER(SIN(subLat/2), 2) + COS(rad1)*COS(rad2)*POWER(SIN(subLon/2),2) ));
END
$$

DROP PROCEDURE IF EXISTS `geoNeighbourhood`
$$
CREATE PROCEDURE `geoNeighbourhood` (IN uid INT, IN meters INT, IN rows INT)
BEGIN
	DECLARE myLon DOUBLE; DECLARE myLat DOUBLE;
	DECLARE lon1  DOUBLE; DECLARE lon2  DOUBLE;
	DECLARE lat1  DOUBLE; DECLARE lat2  DOUBLE;
	
	-- get the original longitude and latitude for the userid
	SELECT `longitude`, `latitude` INTO myLon, myLat 
	FROM `geo_data`
	WHERE `uid` = uid
	LIMIT 1;
	
	-- calculate lon and lat for the rectangle:
	SET lon1 = myLon - meters/abs(cos(radians(myLat))*111044);
	SET lon2 = myLon + meters/abs(cos(radians(myLat))*111044);
	SET lat1 = myLat - (meters/111044);
	SET lat2 = myLat + (meters/111044);
	
	-- run the query:
	SELECT *, geoDistanceBetween(myLat, myLon, `latitude`, `longitude`) AS `distance`
	FROM `geo_data`
	WHERE `longitude` BETWEEN lon1 AND lon2
	AND `latitude` BETWEEN lat1 AND lat2
	HAVING `distance` <= meters
	ORDER BY `distance`
	LIMIT rows;
END
$$

DELIMITER ;