import boto3
import os
import json

s3 = boto3.client(
    's3',
    endpoint_url='https://storage.yandexcloud.net',
    aws_access_key_id=os.environ['AWS_ACCESS_KEY_ID'],
    aws_secret_access_key=os.environ['AWS_SECRET_ACCESS_KEY'],
)

def handler(event, context):
    resp = s3.list_objects_v2(Bucket=os.environ['BUCKET_NAME'])
    files = [obj['Key'] for obj in resp.get('Contents', [])]
    
    return {"statusCode": 200, "body": json.dumps(files)}