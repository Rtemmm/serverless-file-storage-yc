import boto3
import os

s3 = boto3.client(
    's3',
    endpoint_url='https://storage.yandexcloud.net',
    aws_access_key_id=os.environ['AWS_ACCESS_KEY_ID'],
    aws_secret_access_key=os.environ['AWS_SECRET_ACCESS_KEY'],
)

def handler(event, context):
    filename = event['queryStringParameters'].get('filename')
    
    if not filename:
        return {"statusCode": 400, "body": "Missing 'filename'"}
    
    s3.delete_object(Bucket=os.environ['BUCKET_NAME'], Key=filename)
    return {"statusCode": 200, "body": f"{filename} deleted"}