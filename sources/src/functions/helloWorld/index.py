from aws_lambda_powertools import Logger
from parameters import get_parameters
from database import get_dynamodb_table

logger = Logger()
parameters = get_parameters()
users_table = get_dynamodb_table(parameters, "dynamodb-table-users")

def handler(event, context):
    try:
        logger.info(f"${event}")
        user_id = event.get("id")
        if not user_id:
            return {"statusCode": 400, "body": "Missing 'id' in request."}

        response = users_table.get_item(Key={"PK": user_id, "SK": "NAME#"})
        user_data = response.get("Item")

        if not user_data:
            return {"statusCode": 404, "body": f"No data found for user id {user_id}"}

        user_name = user_data.get("name", "there")
        return {"statusCode": 200, "body": f"Hello {user_name}!"}
    except Exception as e:
        return {"statusCode": 500, "body": "Internal server error."}
