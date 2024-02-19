##################################################################
# SNS_TOPIC
##################################################################

resource "aws_sns_topic" "alert_sns_topic" {
  name              = "alert_sns_topic"
  kms_master_key_id = var.kms_id #tfsec:ignore:aws-sns-enable-topic-encryption
  policy            = <<EOF

 {
  "Version": "2008-10-17",
  "Id": "__default_policy_ID",
  "Statement": [
    {
      "Sid": "__default_statement_ID",
      "Effect": "Allow",
      "Principal": {
        "AWS": "*"
      },
      "Action": [
        "SNS:Publish",
        "SNS:RemovePermission",
        "SNS:SetTopicAttributes",
        "SNS:DeleteTopic",
        "SNS:ListSubscriptionsByTopic",
        "SNS:GetTopicAttributes",
        "SNS:AddPermission",
        "SNS:Subscribe"
      ],
      "Resource": "",
      "Condition": {
        "StringEquals": {
          "AWS:SourceOwner": ""
        }
      }
    },
    {
      "Sid": "__console_pub_0",
      "Effect": "Allow",
      "Principal": {
        "AWS": "*"
      },
      "Action": "SNS:Publish",
      "Resource": ""
    },
    {
      "Sid": "__console_sub_0",
      "Effect": "Allow",
      "Principal": {
        "AWS": "*"
      },
      "Action": [
        "SNS:Subscribe"
      ],
      "Resource": ""
    }
  ]
}
EOF

}



##################################################################
# SNS_SUBSCRIPTION
##################################################################
resource "aws_sns_topic_subscription" "sns_sub" {
  topic_arn = aws_sns_topic.alert_sns_topic.arn
  protocol  = "email"
  endpoint  = var.endpoint
}

##################################################################
# CLOUDWATCH_ALARM
##################################################################

resource "aws_cloudwatch_metric_alarm" "ec2_alerts_test" {
  alarm_name                = "ec2_alerts_test"
  comparison_operator       = "GreaterThanThreshold"
  evaluation_periods        = "1"
  metric_name               = "CPUUtilization"
  namespace                 = "AWS/EC2"
  period                    = ""
  statistic                 = "Average"
  threshold                 = "2"
  alarm_description         = "This metric monitors ec2 cpu utilization"
  insufficient_data_actions = []
  datapoints_to_alarm       = "1"
  actions_enabled           = "true"
  alarm_actions             = [aws_sns_topic.alert_sns_topic.arn]
  ok_actions                = [aws_sns_topic.alert_sns_topic.arn]

  dimensions = {
    InstanceId = var.instanceid
  }

}

resource "aws_cloudwatch_metric_alarm" "ec2_alerts_EBS" {
  alarm_name                = "ec2_alerts_EBS"
  comparison_operator       = "GreaterThanThreshold"
  evaluation_periods        = "1"
  metric_name               = "EBSReadOps"
  namespace                 = "AWS/EC2"
  period                    = ""
  statistic                 = "Average"
  threshold                 = "2"
  alarm_description         = "This metric monitors ec2 EBSReadOps"
  insufficient_data_actions = []
  datapoints_to_alarm       = "1"
  actions_enabled           = "true"
  alarm_actions             = [aws_sns_topic.alert_sns_topic.arn]
  ok_actions                = [aws_sns_topic.alert_sns_topic.arn]

  dimensions = {
    InstanceId = ""
  }

}

