import boto3
import base64
import os

s3 = boto3.client(
    's3',
    endpoint_url='https://storage.yandexcloud.net',
    aws_access_key_id=os.environ['AWS_ACCESS_KEY_ID'],
    aws_secret_access_key=os.environ['AWS_SECRET_ACCESS_KEY'],
)

def handler(event, context):
    file_content = base64.b64decode(event['body'])
    filename = event['queryStringParameters'].get('filename', 'uploaded_file')
    s3.put_object(Bucket=os.environ['BUCKET_NAME'], Key=filename, Body=file_content)
    
    return {"statusCode": 200, "body": f"{filename} uploaded"}