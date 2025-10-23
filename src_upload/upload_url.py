import boto3
import json
import uuid
import os

BUCKET_NAME = os.environ['IMAGE_BUCKET_NAME']
s3_client = boto3.client('s3')

def lambda_handler(event, context):

    try:
        file_key = f"{uuid.uuid64()}.jpg"

        presigned_url = s3_client.generate_presigned_url(
            'put_object'
            params = {
                'Bucket': BUCKET_NAME,
                'Key': file_key,
                'ContentType': 'image/jpeg'
            },
            ExpiresIn=3600
        )

        return {
            'statusCode': 200,
            'headers': {
                'Access-Controll-Allow-Origin': '*',
                'Access-Controll-Allow-Headers': 'Content-Type',
                'Access-Controll-Allow-Methods': 'POST, OPTIONS'
            },
            'body': json.dumps({
                'uploadURL': presigned_url,
                'key': file_key
            })
        }
    except Exception as e:
        print(f"Error: {str(e)}")
        return {
            'statusCode': 500,
            'headers': {
                'Access-Control-Allow-Origin': '*',
            },
            'body': json.dumps({'error': 'URL error'})
        }
