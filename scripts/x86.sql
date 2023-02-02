CREATE EXTERNAL TABLE `emr_serverless_spark_x86_detail`(
  `timestamp` bigint COMMENT 'from deserializer', 
  `iteration` int COMMENT 'from deserializer', 
  `tags` struct<standardrun:string> COMMENT 'from deserializer', 
  `results` array<struct<name:string,mode:string,parameters:string,jointypes:array<string>,tables:array<string>,parsingtime:double,analysistime:double,optimizationtime:double,planningtime:double,executiontime:double,breakdown:array<string>>> COMMENT 'from deserializer')
ROW FORMAT SERDE 
  'org.openx.data.jsonserde.JsonSerDe' 
WITH SERDEPROPERTIES ( 
  'paths'='configuration,iteration,results,tags,timestamp') 
STORED AS INPUTFORMAT 
  'org.apache.hadoop.mapred.TextInputFormat' 
OUTPUTFORMAT 
  'org.apache.hadoop.hive.ql.io.HiveIgnoreKeyTextOutputFormat'
LOCATION
  's3://$YOURBUCKET/benchmark/spark-v3-x86'
TBLPROPERTIES (
  'CrawlerSchemaDeserializerVersion'='1.0', 
  'CrawlerSchemaSerializerVersion'='1.0', 
  'averageRecordSize'='1059', 
  'classification'='json', 
  'compressionType'='none', 
  'sizeKey'='1059', 
  'transient_lastDdlTime'='1673017343', 
  'typeOfData'='file')
