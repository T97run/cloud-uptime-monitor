import os
import boto3

S3_BUCKET = os.environ["DATA_BUCKET"]

def handler(event, context):
    s3 = boto3.client("s3")
    obj = s3.get_object(Bucket=S3_BUCKET, Key="status.json")
    body = obj["Body"].read().decode("utf-8")

    return {
        "statusCode": 200,
        "headers": {
            "Content-Type": "application/json",
            "Access-Control-Allow-Origin": "*",
        },
        "body": body,
    }