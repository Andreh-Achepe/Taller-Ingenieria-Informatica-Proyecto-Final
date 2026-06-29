import json, boto3, os, uuid
from datetime import datetime

s3 = boto3.client("s3")
dynamodb = boto3.resource("dynamodb")
table = dynamodb.Table(os.environ["TABLE_NAME"])
bucket = os.environ["BUCKET_NAME"]


def handler(event, context):
    for record in event["Records"]:
        key = record["s3"]["object"]["key"]
        obj = s3.get_object(Bucket=bucket, Key=key)

        table.put_item(
            Item={
                "id": int(datetime.now().timestamp() * 1000),
                "s3_key": key,
                "filename": key.split("/")[-1],
                "created_at": datetime.now().isoformat(),
            }
        )

    return {"statusCode": 200}
