project_name = "lib-poc-service-tf-prod"
region = "ap-northeast-1"
environment = "prod"
emails = ["LIB_IFCsupport@teijin.co.jp"]
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
  zone_id = "Z05890042Z6W4UK0O9CHQ"
  root_domain = "keytecho.com"
  user_domain = "keytecho.com"
  staff_domain = "staff.keytecho.com"
  api_domain = "api.keytecho.com"
}
apigateway = {
  id = "idfanmpl1b"
}