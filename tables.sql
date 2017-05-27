CREATE TABLE `stationaryradar` (
  `x` double(8,2) NOT NULL,
  `y` double(8,2) NOT NULL,
  `z` double(8,2) NOT NULL,
  `maxspeed` int(11) NOT NULL
);

CREATE TABLE `stationaryradar_permissions` (
  `steamid` varchar(255) NOT NULL,
  `name` varchar(255) NOT NULL,
  `permission_level` int(11) NOT NULL,
  PRIMARY KEY (`steamid`)
);
