project_name = "myapp-dev"
region = "ap-northeast-1"
environment = "dev"
emails = [""]
vpc = {
  cidr_block = {
    main       = "10.0.0.0/16"
    public_1a  = "10.0.1.0/24"
    private_1a = "10.0.10.0/24"
    private_1c = "10.0.20.0/24"
    private_1d = "10.0.30.0/24"
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
