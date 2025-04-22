import boto3

dynamodb_resource = boto3.resource('dynamodb')

def get_dynamodb_table(params, table: str):
    table_name = params.get(table)
    if not table_name:
        raise ValueError("DynamoDB table name not found in SSM parameters.")

    return dynamodb_resource.Table(table_name)
