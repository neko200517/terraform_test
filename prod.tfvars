project_name = "myapp-prod"
region = "ap-northeast-1"
environment = "prod"
emails = [""]
vpc = {
  cidr_block = {
    main       = "20.0.0.0/16"
    public_1a  = "20.0.1.0/24"
    private_1a = "20.0.10.0/24"
    private_1c = "20.0.20.0/24"
    private_1d = "20.0.30.0/24"
  }
}
domain = {
  zone_id = ""
  root_domain = ""
  user_domain = ""
  staff_domain = ""
  api_domain = ""
}
apigateway = {
  id = ""
}
