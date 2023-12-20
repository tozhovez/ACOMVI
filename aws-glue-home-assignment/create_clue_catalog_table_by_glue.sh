athenadb_name="aws_glue_home_assignment_serverless"

aws glue create-table --database-name $athenadb_name --table-input '
{
  "Name": "stock_prices",
  "Owner": "hadoop",
  "Retention": 0,
  "StorageDescriptor": {
    "Columns": [
      {
        "Name": "date",
        "Type": "string"
      },
      {
        "Name": "open",
        "Type": "double"
      },
      {
        "Name": "high",
        "Type": "double"
      },
      {
        "Name": "low",
        "Type": "double"
      },
      {
        "Name": "close",
        "Type": "double"
      },
      {
        "Name": "volume",
        "Type": "int"
      },
      {
        "Name": "ticker",
        "Type": "string"
      }
    ],
    "Location": "s3://aws-glue-home-assignment-serverless/data/input",
    "InputFormat": "org.apache.hadoop.mapred.TextInputFormat",
    "OutputFormat": "org.apache.hadoop.hive.ql.io.HiveIgnoreKeyTextOutputFormat",
    "Compressed": false,
    "NumberOfBuckets": -1,
    "SerdeInfo": {
      "SerializationLibrary": "org.apache.hadoop.hive.serde2.lazy.LazySimpleSerDe",
      "Parameters": {
        "serialization.format": ",",
        "field.delim": ","
      }
    },
    "BucketColumns": [],
    "SortColumns": [],
    "Parameters": {},
    "SkewedInfo": {
      "SkewedColumnNames": [],
      "SkewedColumnValues": [],
      "SkewedColumnValueLocationMaps": {}
    },
    "StoredAsSubDirectories": false
  },
  "PartitionKeys": [],
  "TableType": "EXTERNAL_TABLE",
  "Parameters": {
    "EXTERNAL": "TRUE",
    "skip.header.line.count": "1"
  }
}
'

aws glue create-table --database-name $athenadb_name --table-input '
{
  "Name": "average_return_tmp",
  "Owner": "hadoop",
  "Retention": 0,
  "StorageDescriptor": {
    "Columns": [
      {
        "Name": "date",
        "Type": "date"
      },
      {
        "Name": "average_return",
        "Type": "double"
      }
    ],
    "Location": "s3://aws-glue-home-assignment-serverless/data/report1",
    "InputFormat": "org.apache.hadoop.mapred.TextInputFormat",
    "OutputFormat": "org.apache.hadoop.hive.ql.io.HiveIgnoreKeyTextOutputFormat",
    "Compressed": false,
    "NumberOfBuckets": -1,
    "SerdeInfo": {
      "SerializationLibrary": "org.apache.hadoop.hive.serde2.lazy.LazySimpleSerDe",
      "Parameters": {
        "serialization.format": ",",
        "field.delim": ","
      }
    },
    "BucketColumns": [],
    "SortColumns": [],
    "Parameters": {},
    "SkewedInfo": {
      "SkewedColumnNames": [],
      "SkewedColumnValues": [],
      "SkewedColumnValueLocationMaps": {}
    },
    "StoredAsSubDirectories": false
  },
  "PartitionKeys": [],
  "TableType": "EXTERNAL_TABLE",
  "Parameters": {
    "EXTERNAL": "TRUE",
    "skip.header.line.count": "1"
  }
}
'
aws glue create-table --database-name $athenadb_name --table-input '
{
  "Name": "frequency",
  "Owner": "hadoop",
  "Retention": 0,
  "StorageDescriptor": {
    "Columns": [
      {
        "Name": "ticker ",
        "Type": "string"
      },
      {
        "Name": "frequency",
        "Type": "double"
      }
    ],
    "Location": "s3://aws-glue-home-assignment-serverless/data/report2",
    "InputFormat": "org.apache.hadoop.mapred.TextInputFormat",
    "OutputFormat": "org.apache.hadoop.hive.ql.io.HiveIgnoreKeyTextOutputFormat",
    "Compressed": false,
    "NumberOfBuckets": -1,
    "SerdeInfo": {
      "SerializationLibrary": "org.apache.hadoop.hive.serde2.lazy.LazySimpleSerDe",
      "Parameters": {
        "serialization.format": ",",
        "field.delim": ","
      }
    },
    "BucketColumns": [],
    "SortColumns": [],
    "Parameters": {},
    "SkewedInfo": {
      "SkewedColumnNames": [],
      "SkewedColumnValues": [],
      "SkewedColumnValueLocationMaps": {}
    },
    "StoredAsSubDirectories": false
  },
  "PartitionKeys": [],
  "TableType": "EXTERNAL_TABLE",
  "Parameters": {
    "EXTERNAL": "TRUE",
    "skip.header.line.count": "1"
  }
}
'
aws glue create-table --database-name $athenadb_name --table-input '
{
  "Name": "stddev",
  "Owner": "hadoop",
  "Retention": 0,
  "StorageDescriptor": {
    "Columns": [
      {
        "Name": "ticker ",
        "Type": "string"
      },
      {
        "Name": "standard_deviation",
        "Type": "double"
      }
    ],
    "Location": "s3://aws-glue-home-assignment-serverless/data/report3",
    "InputFormat": "org.apache.hadoop.mapred.TextInputFormat",
    "OutputFormat": "org.apache.hadoop.hive.ql.io.HiveIgnoreKeyTextOutputFormat",
    "Compressed": false,
    "NumberOfBuckets": -1,
    "SerdeInfo": {
      "SerializationLibrary": "org.apache.hadoop.hive.serde2.lazy.LazySimpleSerDe",
      "Parameters": {
        "serialization.format": ",",
        "field.delim": ","
      }
    },
    "BucketColumns": [],
    "SortColumns": [],
    "Parameters": {},
    "SkewedInfo": {
      "SkewedColumnNames": [],
      "SkewedColumnValues": [],
      "SkewedColumnValueLocationMaps": {}
    },
    "StoredAsSubDirectories": false
  },
  "PartitionKeys": [],
  "TableType": "EXTERNAL_TABLE",
  "Parameters": {
    "EXTERNAL": "TRUE",
    "skip.header.line.count": "1"
  }
}
'

aws glue create-table --database-name $athenadb_name --table-input '
{
  "Name": "top3_30_day_return_dates",
  "Owner": "hadoop",
  "Retention": 0,
  "StorageDescriptor": {
    "Columns": [
      {
        "Name": "ticker ",
        "Type": "string"
      },
      {
        "Name": "date",
        "Type": "date"
      }
    ],
    "Location": "s3://aws-glue-home-assignment-serverless/data/report4",
    "InputFormat": "org.apache.hadoop.mapred.TextInputFormat",
    "OutputFormat": "org.apache.hadoop.hive.ql.io.HiveIgnoreKeyTextOutputFormat",
    "Compressed": false,
    "NumberOfBuckets": -1,
    "SerdeInfo": {
      "SerializationLibrary": "org.apache.hadoop.hive.serde2.lazy.LazySimpleSerDe",
      "Parameters": {
        "serialization.format": ",",
        "field.delim": ","
      }
    },
    "BucketColumns": [],
    "SortColumns": [],
    "Parameters": {},
    "SkewedInfo": {
      "SkewedColumnNames": [],
      "SkewedColumnValues": [],
      "SkewedColumnValueLocationMaps": {}
    },
    "StoredAsSubDirectories": false
  },
  "PartitionKeys": [],
  "TableType": "EXTERNAL_TABLE",
  "Parameters": {
    "EXTERNAL": "TRUE",
    "skip.header.line.count": "1"
  }
}
'