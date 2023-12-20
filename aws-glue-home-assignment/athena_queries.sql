
DROP TABLE IF EXISTS `{athenadb_name}`.`{athena_table_input}`
;

CREATE EXTERNAL TABLE IF NOT EXISTS `{athenadb_name}`.`{athena_table_input}` (
`date` string
, `open` double
, `high` double
, `low` double
, `close` double
, `volume` integer
, `ticker` string)
ROW FORMAT DELIMITED
FIELDS TERMINATED BY ','
STORED AS INPUTFORMAT
'org.apache.hadoop.mapred.TextInputFormat'
OUTPUTFORMAT
'org.apache.hadoop.hive.ql.io.HiveIgnoreKeyTextOutputFormat'
LOCATION
'{s3path_input}'
TBLPROPERTIES ("skip.header.line.count"="1")
;

DROP TABLE IF EXISTS `{athenadb_name}`.`{athena_table_report1}`
;

CREATE EXTERNAL TABLE IF NOT EXISTS `{athenadb_name}`.`{athena_table_report1}` (
  `date` date
  , `average_return` double)
ROW FORMAT DELIMITED
FIELDS TERMINATED BY ','
STORED AS INPUTFORMAT
'org.apache.hadoop.mapred.TextInputFormat'
OUTPUTFORMAT
'org.apache.hadoop.hive.ql.io.HiveIgnoreKeyTextOutputFormat'
LOCATION
'{s3path_report1}'
TBLPROPERTIES ("skip.header.line.count"="1")
;

DROP TABLE IF EXISTS `{athenadb_name}`.`{athena_table_report2}`
;

CREATE EXTERNAL TABLE IF NOT EXISTS `{athenadb_name}`.`{athena_table_report2}` (
  `ticker ` string
  ,`frequency` double)
ROW FORMAT DELIMITED
FIELDS TERMINATED BY ','
STORED AS INPUTFORMAT
'org.apache.hadoop.mapred.TextInputFormat'
OUTPUTFORMAT
'org.apache.hadoop.hive.ql.io.HiveIgnoreKeyTextOutputFormat'
LOCATION
'{s3path_report2}'
TBLPROPERTIES ("skip.header.line.count"="1")
;


DROP TABLE IF EXISTS `{athenadb_name}`.`{athena_table_report3}`
;

CREATE EXTERNAL TABLE IF NOT EXISTS `{athenadb_name}`.`{athena_table_report3}` (
  `ticker ` string
  ,`standard_deviation` double)
ROW FORMAT DELIMITED
FIELDS TERMINATED BY ','
STORED AS INPUTFORMAT
'org.apache.hadoop.mapred.TextInputFormat'
OUTPUTFORMAT
'org.apache.hadoop.hive.ql.io.HiveIgnoreKeyTextOutputFormat'
LOCATION
'{s3path_report3}'
TBLPROPERTIES ("skip.header.line.count"="1")
;

DROP TABLE IF EXISTS `{athenadb_name}`.`{athena_table_report4}`
;

CREATE EXTERNAL TABLE IF NOT EXISTS `{athenadb_name}`.`{athena_table_report4}` (
  `ticker ` string,
  `date` date)
ROW FORMAT DELIMITED
FIELDS TERMINATED BY ','
STORED AS INPUTFORMAT
'org.apache.hadoop.mapred.TextInputFormat'
OUTPUTFORMAT
'org.apache.hadoop.hive.ql.io.HiveIgnoreKeyTextOutputFormat'
LOCATION
'{s3path_report4}'
TBLPROPERTIES ("skip.header.line.count"="1")
;
