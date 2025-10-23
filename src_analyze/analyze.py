import boto3
import json
import os

BUCKET_NAME = os.environ['IMAGE_BUCKET_NAME']
rekognition_client = boto3.client('rekognition')

def lambda_handler(event, context):
    try:
        body = json.loads(event['body'])
        file_key = body['key']

        if not file_key:
            raise ValueError("The file 'key' is required in the body")

        response = rekognition_client.detect_labels(
            Image={
                'S3Object': {
                    'Bucket': BUCKET_NAME,
                    'Name': file_key
                }
            },
            MaxLabels=10,
            MinConfidence=80 
        )

        labels = [label['Name'] for label in response['Labels']]

        return {
            'statusCode': 200,
            'headers': {
                'Access-Control-Allow-Origin': '*',
                'Access-Control-Allow-Headers': 'Content-Type',
                'Access-Control-Allow-Methods': 'POST, OPTIONS'
            },
            'body': json.dumps({'labels': labels})
        }

    except Exception as e:
        print(f"Error: {str(e)}")
        return {
            'statusCode': 500,
            'headers': {
                'Access-Control-Allow-Origin': '*',
            },
            'body': json.dumps({'error': 'Could not analyze the image'})
        }