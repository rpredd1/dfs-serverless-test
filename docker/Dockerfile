ARG RUNTIME_LANG
ARG RUNTIME_VERSION
ARG IMAGE_ARCH

FROM public.ecr.aws/lambda/${RUNTIME_LANG}:${RUNTIME_VERSION} as build

WORKDIR ${LAMBDA_TASK_ROOT}

ARG FUNCTION_NAME
COPY sources/src/functions/${FUNCTION_NAME}/requirements.txt ${LAMBDA_TASK_ROOT}/
COPY sources/src/layers/shared/requirements.txt ${LAMBDA_TASK_ROOT}/shared_requirements.txt

ARG RUNTIME_LANG
ARG RUNTIME_VERSION
RUN pip install --no-cache-dir -r requirements.txt -r shared_requirements.txt -t .

# Stage 2: Runtime Environment
FROM public.ecr.aws/lambda/${RUNTIME_LANG}:${RUNTIME_VERSION}
ENV PYTHONPATH=/var/task:/var/task/lambda:/var/task/shared

# Copy only the necessary files from the build stage
COPY --from=build ${LAMBDA_TASK_ROOT} ${LAMBDA_TASK_ROOT}

# Set the entrypoint and command
ENTRYPOINT [ "/usr/local/bin/aws-lambda-rie", "/var/runtime/bootstrap" ]
CMD [ "lambda/index.handler" ]
