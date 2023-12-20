DROP TABLE IF EXISTS {athenadb_name}.report1
;

CREATE TABLE IF NOT EXISTS {athenadb_name}.report1
WITH (
    format = 'PARQUET',
    external_location = '{s3path_report1}{timestamp}/'
    ) AS
SELECT
a.date,
coalesce(avg(a.daily_return), 0) as average_return
from ( SELECT
b.date
, b.close
, lag(b.close, 1) over (partition BY b.ticker ORDER BY b.date) AS lag_close
, 100 * (b.close - lag(b.close, 1) over (partition BY b.ticker ORDER BY b.date)) / lag(b.close, 1) over (partition BY b.ticker ORDER BY b.date) as daily_return
, b.ticker
FROM (select date(date_parse("date", '%c/%e/%Y')) as date , close, ticker from  {athenadb_name}.{athena_table_input} ) b
order by date, ticker ) a
group by a.date
order by a.date
;

with totals as (
select count(distinct date) as total_days
from stock_prices
),
closing_volumes as (
select
date
,close * volume as close_volume
,ticker
, rank()  over (partition BY date ORDER BY close * volume desc) AS ranks
from stock_prices
),
highest as (
select
 ticker
, count(ranks) as max_close_val
from closing_volumes
where ranks = 1
group by ticker
)
select a.ticker, cast(a.max_close_val as double) / b.total_days as frequncy
from highest a, totals b
order by frequncy desc
limit 1
;

with astdd as (
select
      a.ticker
      , coalesce(stddev(a.daily_return), 0) as std_daily_return

from (
      SELECT
           b.date
           , b.close
           , lag(b.close, 1) over (partition BY b.ticker ORDER BY b.date) AS lag_close
           , (100 * (b.close - lag(b.close, 1) over (partition BY b.ticker ORDER BY b.date)) / lag(b.close, 1) over (partition BY b.ticker ORDER BY b.date)) as daily_return
           , b.ticker
      FROM (
             select date(date_parse("date", '%c/%e/%Y')) as date , close, ticker
             from  "aws_glue_home_assignment_serverless"."stock_prices" ) b
             ) a
    group by a.ticker
    )
    select  ticker
      , std_daily_return * 15.874507866 as annualized_std
      from astdd
      order by annualized_std desc
      limit 1
      ;


with df_30day_returns as (
    SELECT
           b.date
           , b.close
           , lag(b.close, 30) over (partition BY b.ticker ORDER BY b.date) AS lag_close
           , (100 * (b.close - lag(b.close, 30) over (partition BY b.ticker ORDER BY b.date)) / lag(b.close, 30) over (partition BY b.ticker ORDER BY b.date)) as daily_return
           , b.ticker
      FROM (
             select date(date_parse("date", '%c/%e/%Y')) as date , close, ticker
             from  "aws_glue_home_assignment_serverless"."stock_prices" ) b
),
df_ranked_returns as (
select date
,  daily_return
, ticker
, rank()  over (partition BY ticker ORDER BY daily_return desc) AS ranks
from df_30day_returns
)
select ticker,  date from df_ranked_returns where ranks <= 3
;