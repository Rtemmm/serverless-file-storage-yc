import boto3
import os
import base64
import mimetypes

s3 = boto3.client(
    's3',
    endpoint_url='https://storage.yandexcloud.net',
    aws_access_key_id=os.environ['AWS_ACCESS_KEY_ID'],
    aws_secret_access_key=os.environ['AWS_SECRET_ACCESS_KEY'],
)

BUCKET = os.environ['BUCKET_NAME']

def handler(event, context):
    filename = event['queryStringParameters'].get('filename')
    if not filename:
        return {"statusCode": 400, "body": "Missing 'filename'"}

    try:
        obj = s3.get_object(Bucket=BUCKET, Key=filename)
        content = obj['Body'].read()
        content_type = mimetypes.guess_type(filename)[0] or 'application/octet-stream'

        return {
            "statusCode": 200,
            "isBase64Encoded": True,
            "headers": {
                "Content-Type": content_type,
                "Content-Disposition": f'attachment; filename="{filename}"'
            },
            "body": base64.b64encode(content).decode()
        }
    except s3.exceptions.NoSuchKey:
        return {"statusCode": 404, "body": f"File '{filename}' not found"}
