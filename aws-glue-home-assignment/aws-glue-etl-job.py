
import sys
import math
import json
import datetime
from awsglue.utils import getResolvedOptions
from pyspark.context import SparkContext
from awsglue.context import GlueContext
from awsglue.job import Job
from pyspark.sql import SparkSession
from pyspark.sql.window import Window
from pyspark.sql import functions as F
#import logging
#logging.basicConfig(level=logging.INFO)

def load_data(spark, config: dict) -> F.DataFrame:
    # Load the CSV file into a DataFrame
    stock_prices_df = spark.read.csv(
        f's3://{config["s3bucket"]}/{config["s3_key_src"]}',
        header=True,
        inferSchema=True
        )
    # Convert the date column to date type
    sp_df = (
        stock_prices_df
        .withColumn("date", F.to_date(F.col("date"), "M/d/yyyy"))
        .select("date", "ticker", "volume", "close")
        )
    sp_df.printSchema()
    #sp_df.show()
    return sp_df


def report1_get_average_return(df: F.DataFrame):
    # Calculate the daily return for each stock and date
    window_spec = (
        Window
        .partitionBy("ticker")
        .orderBy("date")
        )
    df_daily_returns = (
        df.withColumn("lag_close", F.lag("close").over(window_spec))
        .withColumn(
            "daily_return",
            100 * (F.col("close") - F.col("lag_close")) / F.col("lag_close")
            )
        .drop("lag_close")
        )
    # Calculate the average daily return for each date
    df_avg_daily_return = (
        df_daily_returns
        .groupBy("date")
        .agg(F.avg("daily_return").alias("average_return"))
        .orderBy("date")
        )
    df_avg_daily_return = df_avg_daily_return.withColumn(
        "average_return",
        F.when(F.col("average_return").isNull(), 0)
        .otherwise(F.col("average_return"))
        )
    print("# 1 - average daily return of all stocks for every date")
    df_avg_daily_return.show(truncate=False)
    return df_avg_daily_return


def report2_get_frequency(df: F.DataFrame):
    # Calculate closing price * volume
    df = (
        df
        .withColumn("close_volume", F.col("close") * F.col("volume"))
        .drop("close")
        .drop("volume")
        )
    # Identify the highest closing price * volume for each day
    window_spec = Window.partitionBy("date").orderBy(F.desc("close_volume"))
    df = df.withColumn("rank", F.rank().over(window_spec))
    df = df.filter("rank == 1").drop("rank")

    # Count the frequency for each stock
    frequency_df = df.groupBy("ticker").agg(F.count("date").alias("frequency"))
    # Calculate the total number of days in the chosen timeframe
    total_days = df.select("date").distinct().count()
    # Calculate the average frequency
    frequency_df = (
        frequency_df
        .withColumn("frequency", F.col("frequency") / total_days)
        )
    # Identify the stock with the highest average frequency
    result_df = frequency_df.orderBy(F.desc("frequency")).limit(1)
    print('# 2 - most frequency over time')
    result_df.select("ticker", "frequency").show(truncate=False)
    return result_df


def report3_get_stddev(df: F.DataFrame):
    # Calculate the daily return for each stock
    window_spec = Window.partitionBy("ticker").orderBy("date")
    df_daily_returns = (
        df.withColumn("lag_close", F.lag("close").over(window_spec))
        .withColumn(
            "daily_return",
            (F.col("close") - F.col("lag_close")) / F.col("lag_close") * 100
            )
        .drop("lag_close")
    )
    df_daily_returns = df_daily_returns.withColumn(
        "daily_return",
        F.when(F.col("daily_return").isNull(), 0)
        .otherwise(F.col("daily_return"))
        )
    # Calculate the standard deviation of daily returns for each stock
    df_std_daily_returns = (
        df_daily_returns
        .groupBy("ticker")
        .agg(F.stddev("daily_return").alias("std_daily_return"))
    )
    # Annualize the standard deviation of daily returns
    trading_days_per_year = 252
    df_annualized_std = (
        df_std_daily_returns
        .withColumn(
            "standard_deviation",
            F.col("std_daily_return") * math.sqrt(trading_days_per_year)
            )
        .orderBy(F.desc("standard_deviation"))
        .select("ticker", "standard_deviation")
        .limit(1)
    )
    print("# 3 - most volatile stock:")
    df_annualized_std.show(truncate=False)
    return df_annualized_std


def report4_get_30_days_return(df: F.DataFrame):
    # Calculate the 30-day percentage change for each closing price
    window_spec = Window.partitionBy("ticker").orderBy("date")
    df_30day_returns = (
        df.withColumn("lag_close", F.lag("close", 30).over(window_spec))
        .withColumn("lag_date", F.lag("date", 30).over(window_spec))
        .withColumn(
            "daily_return",
            ((F.col("close") - F.col("lag_close")) / F.col("lag_close")) * 100
            )
        .drop("lag_close")
    )
    # Rank daily returns by percentage increase for each stock
    window_spec_top3 = Window.partitionBy("ticker").orderBy(
        F.desc("daily_return")
        )
    df_ranked_returns = (
        df_30day_returns
        .withColumn("rank", F.rank().over(window_spec_top3))
        .filter(F.col("rank") <= 3)
        .orderBy("ticker", F.desc("rank"))
        .select("ticker", "date")
    )
    print("# 4 - top three 30-day return dates, per ticker:")
    df_ranked_returns.show(truncate=False)
    return df_ranked_returns


def main():
    # Script generated for node aws-glue-glue-home-assignment-serverless
    args = getResolvedOptions(sys.argv, ["JOB_NAME", "config"])
    config = json.loads(args["config"])
    sc = SparkContext()
    glue_context = GlueContext(sc)
    spark = glue_context.spark_session
    job = Job(glue_context)
    job.init(args['JOB_NAME'], args)
    spark = (
        SparkSession
        .builder.appName("StockPrices")
        .config("spark.sql.legacy.timeParserPolicy", "LEGACY")
        .getOrCreate()
        )
    #result = run_tasks(spark, config)
    timestamp = datetime.datetime.today().strftime('%Y%m%d')
    sp_df = load_data(spark, config)
    average_return = report1_get_average_return(sp_df)
    dst_report1 = f's3//:{config["s3bucket"]}' \
                  f'/{config["s3_key_dst"]["report1"]}' \
                  f'/{timestamp}.csv'
    average_return.write.csv(
        dst_report1,
        header=True,
        mode="overwrite"
        )
    frequency= report2_get_frequency(sp_df)
    dst_report2 = f's3//:{config["s3bucket"]}' \
                  f'/{config["s3_key_dst"]["report2"]}' \
                  f'/{timestamp}.csv'
    frequency.write.csv(
        dst_report2,
        header=True,
        mode="overwrite"
        )
    stddev = report3_get_stddev(sp_df)
    dst_report3 = f's3//:{config["s3bucket"]}' \
                  f'/{config["s3_key_dst"]["report3"]}' \
                  f'/{timestamp}.csv'
    stddev.write.csv(
        dst_report3,
        header=True,
        mode="overwrite")
    report4_get_30_days = report4_get_30_days_return(sp_df)
    dst_report4 = f's3//:{config["s3bucket"]}' \
                  f'/{config["s3_key_dst"]["report4"]}' \
                  f'/{timestamp}.csv'
    report4_get_30_days.write.csv(
        dst_report4,
        header=True,
        mode="overwrite")
    job.commit()
    spark.stop()

if __name__ == "__main__":
    main()
