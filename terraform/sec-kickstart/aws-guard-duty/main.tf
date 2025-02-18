locals {
  aws_region = var.aws_region != "" ? var.aws_region : data.aws_region.current.name

  resource_name_suffix = "${var.project}-${var.environment}-${local.aws_region}"

  ipset_name          = "IPSet"
  ipset_key           = "ipset.txt"
  threatintelset_name = "ThreatIntelSet"
  threatintelset_key  = "threatintelset.txt"

  has_ipset          = length(var.ipset_iplist) > 0
  has_threatintelset = length(var.threatintelset_iplist) > 0
}

data "aws_region" "current" {}

resource "aws_guardduty_detector" "detector" {
  count = var.enabled && var.enable_detector ? 1 : 0

  enable = var.enable_detector

  finding_publishing_frequency = var.detector_frequency
}
