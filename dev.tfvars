project_name = "test-service-tf-dev"
region = "ap-northeast-1"
environment = "dev"
emails = ["j.terayama@infocom-east.co.jp"]
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
  zone_id = "Z05890042Z6W4UK0O9CHQ"
  root_domain = "keytecho.com"
  user_domain = "user-dev.keytecho.com"
  staff_domain = "staff-dev.keytecho.com"
  api_domain = "api.keytecho.com"
}
apigateway = {
  id = "idfanmpl1b"
}