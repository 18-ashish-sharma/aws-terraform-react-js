terraform {
  required_version = ">=1.1.2"

  backend "s3" {
    region         = "eu-west-2"
    bucket         = "my-react-app-state"
    key            = "terraform-dev"
    encrypt        = "true"
    dynamodb_table = "terraform-state-lock-dynamo"
  }
}