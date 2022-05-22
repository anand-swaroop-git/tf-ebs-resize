import json

def lambda_handler(event, context):
    payload = json.loads(event['body'])
    first_name = payload['firstname']
    last_name = payload['lastname']
    return {
        'statusCode': 201,
        'body': json.dumps({
            'firstname': first_name,
            'lastname': last_name
        })
    }