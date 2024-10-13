resource "aws_cloudwatch_metric_alarm" "up" {

  alarm_name = "ASG Up"

  alarm_description = "Scale up an instance when CPU utilization is great than 30%"

  comparison_operator = "GreaterThanOrEqualToThreshold"

  evaluation_periods = 1

  metric_name = "CPUUtilization"

  namespace = "AWS/EC2"

  period = 60 #segundos

  statistic = "Average"

  threshold = 30 #Porcentagem do processamento , quando atigir esse valor apenas 1 vez o alarme será desparado.


  dimensions = {

    "AutoScalingGroupName" = aws_autoscaling_group.this.name


  }

  actions_enabled = true

  alarm_actions = [aws_autoscaling_policy.scaleup.arn]


}




resource "aws_cloudwatch_metric_alarm" "down" {

  alarm_name = "ASG Down"

  alarm_description = "Scale up an instance when CPU utilization is great than 40%"

  comparison_operator = "LessThanOrEqualToThreshold"

  evaluation_periods = 1

  metric_name = "CPUUtilization"

  namespace = "AWS/EC2"

  period = 60 #segundos

  statistic = "Average"

  threshold = 40 #Porcentagem do processamento , quando atigir esse valor apenas 1 vez o alarme será desparado.


  dimensions = {

    "AutoScalingGroupName" = aws_autoscaling_group.this.name


  }

  actions_enabled = true

  alarm_actions = [aws_autoscaling_policy.scaledown.arn]


}