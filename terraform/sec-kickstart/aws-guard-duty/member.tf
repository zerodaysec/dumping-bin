resource "aws_guardduty_invite_accepter" "member_accepter" {
  count = var.enabled && var.is_guardduty_member ? 1 : 0

  master_account_id = var.master_account_id
  detector_id       = one(aws_guardduty_detector.detector[*].id)
}
