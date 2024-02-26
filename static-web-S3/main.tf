# provider "aws" {
#   region     = var.region
#   access_key = var.access_key
#   secret_key = var.secret_key
# }

# Creating Random String for bucket name
# resource "random_string" "random" {
#   length  = 6
#   special = false
#   upper   = false
# }

# provider "aws" {
#   region = "ap-southeast-1"
# }

# Creating S3 Bucket 
resource "aws_s3_bucket" "bucket" {
  bucket = "terraform-learn-bucket-hjn4" #${random_string.random.result}"
  # force_destroy = true
}

resource "aws_s3_bucket_website_configuration" "static_web" {
  bucket = aws_s3_bucket.bucket.id
  index_document {
    suffix = "index.html"
  }
  error_document {
    key = "error/index.html"
  }
}

resource "aws_s3_bucket_policy" "bucket_policy" {
  bucket = aws_s3_bucket.bucket.id
  policy = file("s3_static_web_policy.json")
}

# Public Access
resource "aws_s3_bucket_public_access_block" "public_access_block" {
  bucket                  = aws_s3_bucket.bucket.id
  block_public_acls       = false
  block_public_policy     = false
  ignore_public_acls      = false
  restrict_public_buckets = false
}

locals {
  mime_types = {
    html  = "text/html"
    css   = "text/css"
    scss  = "text/x-scss"
    md    = "text/markdown"
    MD    = "text/markdown"
    ttf   = "font/ttf"
    woff  = "font/woff"
    woff2 = "font/woff2"
    otf   = "font/otf"
    js    = "application/javascript"
    map   = "application/javascript"
    json  = "application/json"
    jpg   = "image/jpeg"
    png   = "image/png"
    svg   = "image/svg+xml"
    eot   = "application/vnd.ms-fontobject"
  }
}

# will upload all the files present under HTML folder to the S3 bucket
resource "aws_s3_object" "upload_object" {
  for_each     = fileset(path.module, "static-web/**/*")
  bucket       = aws_s3_bucket.bucket.id
  key          = replace(each.value, "static-web", "")
  source       = each.value
  etag         = filemd5("${each.value}")
  content_type = lookup(local.mime_types, split(".", each.value)[length(split(".", each.value)) - 1])
}
