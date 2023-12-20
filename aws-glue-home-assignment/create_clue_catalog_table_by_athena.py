
import os
import boto3
import pathlib
import yaml
import datetime
from botocore.exceptions import ClientError
from pyathena.connection import Connection
from pyathena.async_cursor import AsyncDictCursor

def get_queries_sql(queries_text):
    for query in queries_text.split(";"):
        query = query.strip()
        if query:
            yield query


def file_queries_reader(filename):
    "file content reader"
    with open(filename, "r", encoding='utf-8') as freader:
        return freader.read()

def load_config_from_yaml(filename):
    """load configuration from yaml file"""
    with open(filename, "r", encoding="utf-8") as fd_reader:
        return yaml.full_load(fd_reader)

def query_formater(query, config):
    return query.format(
        athenadb_name=config["athenadb_name"],
        athena_table_input=config["athena_tables"]["input"]["table_name"],
        s3path_input=f's3://{config["s3bucket"]}/{config["s3_key_dst"]["input"]}',
        athena_table_report1=config["athena_tables"]["report1"]["table_name"],
        s3path_report1=f's3://{config["s3bucket"]}/{config["s3_key_dst"]["report1"]}',
        athena_table_report2=config["athena_tables"]["report2"]["table_name"],
        s3path_report2=f's3://{config["s3bucket"]}/{config["s3_key_dst"]["report2"]}',
        athena_table_report3=config["athena_tables"]["report3"]["table_name"],
        s3path_report3=f's3://{config["s3bucket"]}/{config["s3_key_dst"]["report3"]}',
        athena_table_report4=config["athena_tables"]["report4"]["table_name"],
        s3path_report4=f's3://{config["s3bucket"]}/{config["s3_key_dst"]["report4"]}',
        timestamp=datetime.datetime.today().strftime('%Y%m%d')
        )


def execute_queries(
    query: str,
    s3_staging_dir: str,
    region: str,
    athenadb_name: str
    ):
    """athena execute sql queries"""
    result_set, result_set_text = None, None
    try:
        cursor = Connection(
            s3_staging_dir=s3_staging_dir,
            region_name=region,
            cursor_class=AsyncDictCursor,
            schema_name=athenadb_name
            ).cursor()
        query_id, future = cursor.execute(query)
        result_set = future.result()
        result_set_text = f"""state:{result_set.state}
            state_change_reason:{result_set.state_change_reason}
            completion_date_time:{result_set.completion_date_time}
            submission_date_time:{result_set.submission_date_time}
            data_scanned_in_bytes:{result_set.data_scanned_in_bytes}
            engine_execution_time_in_millis:{result_set.engine_execution_time_in_millis}
            query_queue_time_in_millis:{result_set.query_queue_time_in_millis}
            total_execution_time_in_millis:{result_set.total_execution_time_in_millis}
            query_planning_time_in_millis:{result_set.query_planning_time_in_millis}
            service_processing_time_in_millis:{result_set.service_processing_time_in_millis}
            output_location:{result_set.output_location}
            description:{result_set.description}"""
        if result_set.state == "FAILED":
            text = str(
                f'in file:{result_set_text}{query_id}print(text)SQL:print(text){query}'
                )
            print(text)
    except BaseException as ex:
        text = str(f"""error in function execute_queries:{ex}{query}""")
        print(text)
        raise ex
    return result_set_text




def main():
    service_conf = pathlib.Path(__file__).parent / os.getenv(
        "CONFIGS_FILE" ,"configs-dev.yml"
        )
    queryes_sql = pathlib.Path(__file__).parent / os.getenv(
        "QUERIES_FILE" ,"athena_queries.sql"
        )
    queries_job = pathlib.Path(__file__).parent / os.getenv(
        "QUERIES_FILE" , "aws_glue_jobs_queries.sql"
        )
    config = load_config_from_yaml(service_conf)
    queries_text = file_queries_reader(queryes_sql)
    queries = []
    for query in get_queries_sql(queries_text):
        queries.append(query_formater(query, config))
    queries_jobs = file_queries_reader(queries_job)
    for query in get_queries_sql(queries_jobs):
        queries.append(query_formater(query, config))
    for query in queries:
        res = execute_queries(
            query,
            s3_staging_dir=f's3://{config["s3bucket"]}/{config["s3_key_athena"]}',
            region=config["region"],
            athenadb_name=config["athenadb_name"]
            )
        print(res)

if __name__ == "__main__":
    main()
