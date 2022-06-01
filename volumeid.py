import json
import boto3

# Get Volume ID
def lambda_handler(event, context):
    print("event => ", event)
    # payload = event['body']
    instance_id = event['instance_id']
    
    session = boto3.Session(region_name="ap-southeast-2")
    ec2 = session.client('ec2')
    response = ec2.describe_instances(
        InstanceIds=[instance_id]
    )
    for inst in response['Reservations'][0]['Instances']:
        volume_id =  inst['BlockDeviceMappings'][0]['Ebs']['VolumeId']

    volume_size = ec2.describe_volumes(VolumeIds=[volume_id])['Volumes'][0]['Size']
    
    
    return {
        'statusCode': 201,
        'body': json.dumps({
            'volume_id': volume_id,
            'old_volume_size': volume_size,
            'status': 'EBS modification completed successfully'
        })
    }