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
    raw = event['body']
    if event.get('isBase64Encoded'):
        data = base64.b64decode(raw)
    else:
        data = raw.encode('utf-8')

    filename = (event.get('queryStringParameters') or {}).get('filename')
    if not filename:
        return {"statusCode": 400, "body": "Missing 'filename'"}

    s3.put_object(Bucket=os.environ['BUCKET_NAME'], Key=filename, Body=data)
    return {"statusCode": 200, "body": f"{filename} загружен"}