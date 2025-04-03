function handler () {
  aws s3 mv s3://$S3_SOURCE_BUCKET/$S3_ARTIFACT_FOLDER/ s3://$S3_SOURCE_BUCKET/ --recursive
  RESPONSE=$(aws s3 ls s3://$S3_SOURCE_BUCKET/ 2>&1)
  echo $RESPONSE
}
