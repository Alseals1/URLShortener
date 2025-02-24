import json
import boto3
from dotenv import load_dotenv
import os
import string
import random

load_dotenv()

dynamodb = boto3.resource("dynamodb")
table_name = os.getenv("TABLE_NAME")
BASE_URL = os.getenv("BASE_URL")

def generate_short_code():
    """Generate a random 6-character short code"""
    return ''.join(random.choices(string.ascii_letters + string.digits, k=6))

def lambda_handler(event, context):
    print("Received event:", json.dumps(event))  # Debugging
    
   
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
        short_url = f"{BASE_URL}/{short_code}"
        
        return {
            "statusCode": 200,
            "body": json.dumps({"short_url": short_url})
        }
    
    except Exception as e:
        print("Error:", str(e)) 
        return {
            "statusCode": 500,
            "body": json.dumps({"error": "Internal server error"})
        }