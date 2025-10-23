import boto3
import json
import os

# Leemos el nombre del bucket de la variable de entorno
BUCKET_NAME = os.environ['IMAGE_BUCKET_NAME']
rekognition_client = boto3.client('rekognition')

def lambda_handler(event, context):
    """
    Analiza una imagen en S3 usando Rekognition.
    Espera un JSON en el body: {"key": "nombre-del-archivo.jpg"}
    """
    try:
        # 1. Obtener la 'key' del archivo desde el body del POST
        body = json.loads(event['body'])
        file_key = body['key']

        if not file_key:
            raise ValueError("El 'key' del archivo es requerido en el body")

        # 2. Llamar a Rekognition
        response = rekognition_client.detect_labels(
            Image={
                'S3Object': {
                    'Bucket': BUCKET_NAME,
                    'Name': file_key
                }
            },
            MaxLabels=10,
            MinConfidence=80 # Filtramos etiquetas con baja confianza
        )

        # 3. Procesar y devolver las etiquetas
        labels = [label['Name'] for label in response['Labels']]

        return {
            'statusCode': 200,
            # Importante: Incluir headers CORS
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
            'body': json.dumps({'error': 'No se pudo analizar la imagen'})
        }