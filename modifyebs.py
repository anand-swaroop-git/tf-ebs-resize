import json
import boto3

def lambda_handler(event, context):
    print("event => ", event)
    volume_id = json.loads(event['body'])['volume_id']

    # TODO: Remove hardcoded region from all the functions
    session = boto3.Session(region_name="ap-southeast-2")
    ec2 = session.client('ec2')
    
    # TODO: Remove hardcoded size
    ec2.modify_volume(
        VolumeId = volume_id,
        Size = 24,
    )
    
    return {
        'statusCode': 201,
        'body': json.dumps({
            'volume_id': volume_id,
            'status': 'Expanded the volume.'
        })
    }