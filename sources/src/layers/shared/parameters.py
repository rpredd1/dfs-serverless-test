import os
from aws_lambda_powertools.utilities import parameters

parameters_list = None

def get_parameters(ssm_prefix: str = None):
    ssm_prefix = ssm_prefix or f"/service/{os.getenv('SERVICE_DOMAIN')}/{os.getenv('SERVICE_NAME')}/{os.getenv('SERVICE_ENVIRONMENT')}/"
    global parameters_list
    if parameters_list is None:
        try:
            parameters_list = parameters.get_parameters(ssm_prefix, decrypt=True)
        except Exception as e:
            raise ValueError("Failed to retrieve parameters from SSM.") from e
    return parameters_list
