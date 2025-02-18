locals {
  is_guardduty_master = var.enabled && var.is_guardduty_master

  bucket = var.create_s3_bucket ? one(aws_s3_bucket.created[*].id) : var.s3_bucket_name
}

resource "aws_s3_object" "ipset" {
  count = local.is_guardduty_master && local.has_ipset ? 1 : 0

  bucket = local.bucket
  key    = local.ipset_key

  acl = "public-read"

  content = templatefile("${path.module}/files/templates/ipset.txt.tpl",
    {
      ipset_iplist = var.ipset_iplist
  })

  tags = var.tags
}

resource "aws_guardduty_ipset" "ipset" {
  count = local.is_guardduty_master && local.has_ipset ? 1 : 0

  detector_id = one(aws_guardduty_detector.detector[*].id)
  name        = local.ipset_name
  activate    = var.activate_ipset
  format      = var.ipset_format
  location    = "https://s3.amazonaws.com/${local.bucket}/${local.ipset_key}"

  depends_on = [aws_s3_object.ipset]
}

resource "aws_s3_object" "threatintelset" {
  count = local.is_guardduty_master && local.has_threatintelset ? 1 : 0

  bucket = local.bucket
  key    = local.threatintelset_key

  acl = "public-read"

  content = templatefile("${path.module}/files/templates/threatintelset.txt.tpl",
    {
      threatintelset_iplist = var.threatintelset_iplist
  })

  tags = var.tags
}

resource "aws_guardduty_threatintelset" "threatintelset" {
  count = local.is_guardduty_master && local.has_threatintelset ? 1 : 0

  detector_id = one(aws_guardduty_detector.detector[*].id)
  name        = local.threatintelset_name
  activate    = var.activate_threatintelset
  format      = var.threatintelset_format
  location    = "https://s3.amazonaws.com/${local.bucket}/${local.threatintelset_key}"

  depends_on = [aws_s3_object.threatintelset]
}

resource "aws_guardduty_organization_configuration" "org" {
  count = var.enable_organization ? 1 : 0

  detector_id = one(aws_guardduty_detector.detector[*].id)

  auto_enable_organization_members = var.auto_enable_organization_members

  datasources {
    s3_logs {
      auto_enable = true
    }
    kubernetes {
      audit_logs {
        enable = true
      }
    }
    malware_protection {
      scan_ec2_instance_with_findings {
        ebs_volumes {
          auto_enable = true
        }
      }
    }
  }
}

resource "aws_guardduty_member" "members" {
  count = local.is_guardduty_master && !var.enable_organization ? length(var.member_list) : 0

  detector_id        = one(aws_guardduty_organization_configuration.org[*].detector_id)
  invitation_message = "Please accept GuardDuty invitation"

  account_id = var.member_list[count.index]["account_id"]
  email      = var.member_list[count.index]["member_email"]

  invite = var.member_list[count.index]["invite"]
}

# separate resource to manage lifecycle changes and dependencies
resource "aws_guardduty_member" "organizations_members" {
  count = local.is_guardduty_master && var.enable_organization ? length(var.member_list) : 0

  detector_id        = one(aws_guardduty_detector.detector[*].id)
  invitation_message = "Please accept GuardDuty invitation"

  account_id = var.member_list[count.index]["account_id"]
  email      = var.member_list[count.index]["member_email"]

  # do not directly invite if using the organizations option
  invite = false

  lifecycle {
    ignore_changes = [
      email,
      invite,
    ]
  }
}
