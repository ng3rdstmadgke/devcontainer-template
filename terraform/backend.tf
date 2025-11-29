terraform {
  backend "s3" {
    region       = "ap-northeast-1"
    use_lockfile = true
    encrypt      = true
  }
}
