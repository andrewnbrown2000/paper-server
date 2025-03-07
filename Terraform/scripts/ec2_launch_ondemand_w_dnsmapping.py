import boto3, time, os

region = os.environ.get('REGION') #passed in from Terraform as env variable
instances = [os.environ.get('INSTANCE_ID')
             ] #passed in from Terraform as env variable
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

def get_public_dns(client):
    response = client.describe_instances(InstanceIds=instances)
    public_dns = response['Reservations'][0]['Instances'][0]['PublicDnsName']
    print(public_dns)
    return public_dns
    
# def map_route53_a_record(client, ip):
    
#     client.change_resource_record_sets(
#         HostedZoneId='', #put hosted zone id here (R53)
#         ChangeBatch={
#             'Changes': [
#                 {
#                     'Action': 'UPSERT',
#                     'ResourceRecordSet': {
#                         'Name': '', #put domain name here
#                         'Type': 'A',
#                         'TTL': 300,
#                         'ResourceRecords': [
#                             {
#                                 'Value': ip
#                             }
#                         ]
#                     }
#                 }
#             ]
#         }
#     )
#     print("DNS record updated to " + ip)
    
def lambda_handler(event, context):
    start_ec2_instance(ec2)
    public_dns = get_public_dns(ec2)
    public_ip = get_public_ip(ec2)
    #map_route53_a_record(route53, public_ip)
    return {
        'statusCode': 200,
        'body': f"Paste this address into the Minecraft Server Address field: {public_dns}\n\nThe server will be online shortly."
    }