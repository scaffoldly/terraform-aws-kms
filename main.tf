data "aws_partition" "current" {}
data "aws_caller_identity" "current" {}

data "aws_iam_policy_document" "policy" {
  statement {
    effect = "Allow"
    principals {
      type = "AWS"
      identifiers = [
        "arn:${data.aws_partition.current.partition}:iam::${data.aws_caller_identity.current.account_id}:root"
      ]
    }
    actions = [
      "kms:*"
    ]
    resources = [
      "*"
    ]
  }

  statement {
    effect = "Allow"
    principals {
      type = "AWS"
      identifiers = [
        "*"
      ]
    }
    actions = [
      "kms:Encrypt",
      "kms:Decrypt",
      "kms:ReEncrypt*",
      "kms:GenerateDataKey*",
      "kms:DescribeKey"
    ]
    resources = [
      "*"
    ]
    condition {
      test     = "StringLike"
      variable = "kms:RequestAlias"
      values = [
        "alias/${var.stage}"
      ]
    }
    condition {
      test     = "StringLike"
      variable = "aws:SourceIdentity"
      values = [
        "arn:${data.aws_partition.current.partition}:iam::${data.aws_caller_identity.current.account_id}:role/*-${var.stage}"
      ]
    }
  }
}

resource "aws_kms_key" "key" {
  description             = var.stage
  deletion_window_in_days = 10
  key_usage               = "ENCRYPT_DECRYPT"
  policy                  = data.aws_iam_policy_document.policy.json
}

resource "aws_kms_alias" "alias" {
  name          = "alias/${var.stage}"
  target_key_id = aws_kms_key.key.key_id
}
