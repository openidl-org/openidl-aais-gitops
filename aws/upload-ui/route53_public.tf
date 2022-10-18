resource "aws_route53_record" "upload_ui" {
  name = "upload.dev.thetech.digital"
  zone_id = data.aws_route53_zone.public_zone.zone_id
  type = "CNAME"
  ttl = "300"
  records = [aws_s3_bucket.upload_ui.website_endpoint]
}

