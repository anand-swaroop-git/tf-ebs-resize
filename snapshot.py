import json
import boto3

def lambda_handler(event, context):
    print("event => ", event)
    volume_id = json.loads(event['body'])['volume_id']

    session = boto3.Session(region_name="ap-southeast-2")
    ec2 = session.client('ec2')
    
    ec2.create_snapshot(VolumeId=volume_id,Description='Created by Lambda backup function ebs-snapshots')
    
    return {
        'statusCode': 201,
        'body': json.dumps({
            'volume_id': volume_id,
            'status': 'Started the snapshot of the volume.'
        })
    }