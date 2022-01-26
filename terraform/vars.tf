variable "region" {
  type    = string
  default = "us-east-1"
}
variable "profile" {
  type    = string
  default = "gh-test"
}

variable "ssh_key" {
  type = map(string)
  default = {
    name = "kind"
    key  = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQDpLoVdUwbL5aFs2eHRfDGdntWs4PuUcY0DKWPypPiR7rf4kj/QHsA3Wsd41MGHKv+DT+yp0Do0KvfdhtcdMRP6pNCNpb+xzAt9K2Tz3uNCJsOL2Azrsaz8byRSu7WYie8PYD3sGFwRE3VOEAS1cQN7at5Ds6EOyed/BTFdGfXJYtw+3HYGg2GEjoB0qvuPpS8JycNUteng3A1VCwYQlOMYJks0qlFX/E0TTm8FCXfdLD80ser/Vs2wwVTDLFvm/GW0qZ8hBpEI5/JWJSDJSXJKDr3CGmESliuTU67l2i5upmfAwzvPAfxI/PKN6K2DpxihEyC76O3qs6OKwNYNWWx1 ~/.ssh/bestia.pem"
  }
}
