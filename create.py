import json
import boto3

def lambda_handler(event, context):
    payload = json.loads(event['body'])
    instance_id = payload['instance_id']
    # Trigger APIG and do a POST request on the endpoint with instance ID as payload.
    # Find the EBS volumes attached to the instance.
    # session = boto3.Session(region_name="ap-southeast-2", profile_name="personalauroot")
    session = boto3.Session(region_name="ap-southeast-2")
    ec2 = session.client('ec2')
    response = ec2.describe_instances(
        InstanceIds=[instance_id]
    )
    # print(response['Reservations']['Instances']['BlockDeviceMappings'][0])
    for inst in response['Reservations'][0]['Instances']:
        volume_id =  inst['BlockDeviceMappings'][0]['Ebs']['VolumeId']

    # Find current specs of volume now that we have the volume id
    print("Device: ", ec2.describe_volumes(VolumeIds=[volume_id])['Volumes'][0]['Attachments'][0]['Device'])
    print("State: ", ec2.describe_volumes(VolumeIds=[volume_id])['Volumes'][0]['Attachments'][0]['State'])
    print("VolumeID: ", ec2.describe_volumes(VolumeIds=[volume_id])['Volumes'][0]['Attachments'][0]['VolumeId'])
    print("AvailabilityZone", ec2.describe_volumes(VolumeIds=[volume_id])['Volumes'][0]['AvailabilityZone'])
    print("VolumeSize", ec2.describe_volumes(VolumeIds=[volume_id])['Volumes'][0]['Size'])


    volume_size = ec2.describe_volumes(VolumeIds=[volume_id])['Volumes'][0]['Size']
    
    # Modify and increase the EBS volume.
    ec2.modify_volume(
        VolumeId = volume_id,
        Size = 22,
    )
    new_volume_size = ec2.describe_volumes(VolumeIds=[volume_id])['Volumes'][0]['Size']
    # Send the email.
    # Expand the filesystem.
        # Create a document and lambda will just invoke that document using ssm boto client.
    
    # Send the email.
    
    return {
        'statusCode': 201,
        'body': json.dumps({
            'volume_id': volume_id,
            'old_volume_size': volume_size,
            'new_volume_size': new_volume_size,
            'status': 'EBS modification completed successfully'
        })
    }