variables {
  prefix     = "tftest"
  region     = "us-east-2"
  env        = "test"
  department = "PlatformEng"

  expired_version_retention_days = 14
}

provider "aws" {
  region = "us-east-2"
}

run "unit_test" {
  command = plan

  assert {
    condition     = aws_s3_bucket.www_bucket.bucket_prefix == "tftest-hashicafe-website-test-"
    error_message = "S3 bucket prefix does not match expected value."
  }
  assert {
    condition     = one(aws_s3_bucket_ownership_controls.www_bucket.rule).object_ownership == "BucketOwnerEnforced"
    error_message = "Bucket object ownership should be BucketOwnerEnforced."
  }

  # Need this because the check can't be evaluated at plan time
  expect_failures = [check.web_health]
}

run "input_validation" {
  command = plan

  # Invalid values
  variables {
    prefix = "InvalidPrefix"
    env    = "sandbox"

    expired_version_retention_days = 0
  }

  expect_failures = [
    var.prefix,
    var.env,
    var.expired_version_retention_days,
  ]
}

run "retention_days_max" {
  command = plan

  variables {
    expired_version_retention_days = 366
  }

  expect_failures = [
    var.expired_version_retention_days,
    check.web_health # Need this because the check can't be evaluated at plan time
  ]
}

run "prefix_length" {
  command = plan

  variables {
    prefix = "thisprefixwillmakethebucketnamewaytoolong"
  }

  # Precondition should fail
  expect_failures = [
    aws_s3_bucket.www_bucket
  ]
}

run "create_bucket" {
  command = apply

  assert {
    condition     = startswith(aws_s3_bucket.www_bucket.bucket, "tftest-hashicafe-website-test-")
    error_message = "The bucket name does not start with the expected prefix."
  }
}

run "website_is_running" {
  command = plan

  module {
    source = "./tests/http-validate"
  }

  variables {
    endpoint = run.create_bucket.endpoint
  }

  assert {
    condition     = data.http.index.status_code == 200
    error_message = "Website responded with HTTP status ${data.http.index.status_code}"
  }
}
