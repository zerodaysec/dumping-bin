locals {
  recorder_name         = var.recorder_name != "" ? var.recorder_name : "aws-config-recorder-${local.resource_name_suffix}"
  delivery_channel_name = var.delivery_channel_name != "" ? var.delivery_channel_name : "aws-config-channel-${local.resource_name_suffix}"
}

resource "aws_config_configuration_recorder" "default" {
  count = var.enabled && var.create_recorder ? 1 : 0

  name     = local.recorder_name
  role_arn = local.aws_config_role_arn

  recording_group {
    all_supported                 = true
    include_global_resource_types = true
  }
}

resource "aws_config_delivery_channel" "default" {
  count = var.enabled && var.create_recorder ? 1 : 0

  name = local.delivery_channel_name

  s3_bucket_name = local.config_bucket_name
  s3_key_prefix  = var.bucket_object_prefix

  snapshot_delivery_properties {
    delivery_frequency = var.config_delivery_frequency
  }

  depends_on = [aws_config_configuration_recorder.default]
}

resource "aws_config_configuration_recorder_status" "default" {
  count = var.enabled && var.create_recorder ? 1 : 0

  name       = local.recorder_name
  is_enabled = var.recording_enabled
  depends_on = [aws_config_delivery_channel.default]
}
 