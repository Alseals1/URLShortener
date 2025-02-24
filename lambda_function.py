import json 
import boto3
import os
import string
import random

dynamodb = boto3.resource("dynamodb")
table = dynamodb.Table(os.environ["YOUR_TABLE_NAME_HERE"])

def generate_short_code():
    """Generate a random 6-character short code"""
    return ''.join(random.choices(string.ascii_letters + string.digits, k=6))

def lambda_handler(event, context):
    print("Received event:", json.dumps(event))
    
    # Ensure 'body' exists
    if "body" not in event:
        return {
            "statusCode": 400,
            "body": json.dumps({"error": "Missing 'body' in request"})
        }

    try:
        body = json.loads(event["body"]) 
        long_url = body.get("long_url") 
        
        if not long_url:
            return {
                "statusCode": 400,
                "body": json.dumps({"error": "Missing 'long_url' in request"})
            }
        
        short_code = generate_short_code()
        short_url = f"YOUR_DOMAIN_NAME_HERE/{short_code}"
        
        return {
            "statusCode": 200,
            "body": json.dumps({"short_url": short_url})
        }
    
    except Exception as e:
        print("Error:", str(e))  # Log the error
        return {
            "statusCode": 500,
            "body": json.dumps({"error": "Internal server error"})
        }