import boto3, time

region = 'us-east-1' #put your region here. us-east-1 by default
instances = [''] #put instance id here
ec2 = boto3.client('ec2', region)
route53 = boto3.client('route53')

def start_ec2_instance(client):
    response = client.describe_instance_status(InstanceIds=instances, IncludeAllInstances=True)
    instance_state = response['InstanceStatuses'][0]['InstanceState']['Name']
    
    if instance_state == 'stopped':
        client.start_instances(InstanceIds=instances)
        print("starting your paper server")

        while instance_state != 'running':
            response = client.describe_instance_status(InstanceIds=instances, IncludeAllInstances=True)
            time.sleep(3)
            instance_state = response['InstanceStatuses'][0]['InstanceState']['Name']
            print("state: " + instance_state)
    else:
        print("instance is NOT in the 'stopped' state. cannot start")

def get_public_ip(client):
    response = client.describe_instances(InstanceIds=instances)
    public_ip = response['Reservations'][0]['Instances'][0]['PublicIpAddress']
    print(public_ip)
    return public_ip
    
def map_route53_a_record(client, ip):
    
    client.change_resource_record_sets(
        HostedZoneId='', #put hosted zone id here (R53)
        ChangeBatch={
            'Changes': [
                {
                    'Action': 'UPSERT',
                    'ResourceRecordSet': {
                        'Name': '', #put domain name here
                        'Type': 'A',
                        'TTL': 300,
                        'ResourceRecords': [
                            {
                                'Value': ip
                            }
                        ]
                    }
                }
            ]
        }
    )
    print("DNS record updated to " + ip)
    
def lambda_handler(event, context):
    start_ec2_instance(ec2)
    public_ip = get_public_ip(ec2)
    map_route53_a_record(route53, public_ip)