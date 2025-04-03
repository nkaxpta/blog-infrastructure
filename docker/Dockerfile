FROM public.ecr.aws/lambda/provided:al2023

ARG S3_SOURCE_BUCKET
ENV S3_SOURCE_BUCKET=${S3_SOURCE_BUCKET}
ARG CODEBUILD_PROJECT_NAME
ENV S3_ARTIFACT_FOLDER=${CODEBUILD_PROJECT_NAME}

RUN dnf update -y \
    && dnf install -y less \
    && dnf install -y unzip

WORKDIR /tmp
RUN curl -sSL "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip" \
    && unzip awscliv2.zip \
    && ./aws/install

RUN dnf clean all \
    && rm -rf /var/cache/yum

COPY bootstrap ${LAMBDA_RUNTIME_DIR}
COPY function.sh ${LAMBDA_TASK_ROOT}

RUN chmod +x ${LAMBDA_RUNTIME_DIR}/bootstrap \
    && chmod +x ${LAMBDA_TASK_ROOT}/*.sh

CMD [ "function.handler" ]
