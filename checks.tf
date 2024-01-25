check "web_health" {
  data "http" "www" {
    url = "http://${aws_s3_bucket_website_configuration.www_bucket.website_endpoint}"
  }
  assert {
    condition     = data.http.www.status_code == 200
    error_message = "${data.http.www.url} returned an unhealthy status code"
  }
}
