import json


def handler(event, context):
    """Minimal Lambda handler for the outdated-runtime sample."""
    return {
        "statusCode": 200,
        "headers": {"content-type": "application/json"},
        "body": json.dumps({"message": "Hello from the sample Lambda"}),
    }
