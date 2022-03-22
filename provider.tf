provider "aws" {
  region = "ap-northeast-1"
  shared_credentials_file = "credentials"
}
provider "aws" {
  alias  = "virginia"
  region = "us-east-1"
  shared_credentials_file = "credentials"
}