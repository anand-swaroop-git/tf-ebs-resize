import json
import boto3
import os
final_ebs_size = int(os.environ['FINAL_EBS_SIZE'])
aws_region = os.environ['REGION']

def lambda_handler(event, context):
    print("event => ", event)
    instance_id = json.loads(event['body'])['instance_id']
    volume_id = json.loads(event['body'])['volume_id']

    session = boto3.Session(region_name=aws_region)
    ec2 = session.client('ec2')
    
    # TODO: Remove hardcoded size
    ec2.modify_volume(
        VolumeId = volume_id,
        Size = final_ebs_size,
    )
    
    return {
        'statusCode': 201,
        'body': json.dumps({
            'volume_id': volume_id,
            'instance_id': instance_id,
            'status': 'Expanded the volume.'
        })
    }