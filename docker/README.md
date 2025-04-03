# Lambda-awscliEnv

## Commands

### AWS CLI install for wsl2

1. `sudo apt install unzip`
1. `curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip"`
1. `unzip awscliv2.zip`
1. `sudo ./aws/install`
1. `aws --version`

### Setting up AWS CLI

- `aws configure`

### AWS ECR push

1. `aws ecr get-login-password --region ap-northeast-1 | docker login --username AWS --password-stdin ${accountId}.dkr.ecr.ap-northeast-1.amazonaws.com`
1. `docker build -t ${ecr-repositoryName} .`
1. `docker tag ${ecr-repositoryName}:latest ${accountId}.dkr.ecr.ap-northeast-1.amazonaws.com/${ecr-repositoryName}:latest`
1. `docker push ${accountId}.dkr.ecr.ap-northeast-1.amazonaws.com/${ecr-repositoryName}:latest`

### Docker run

- `docker run --name ${containerName} -dit ${imageName}`

### Bash login

- `docker exec -it ${containerName} bash`

### Process check

- `docker ps`
