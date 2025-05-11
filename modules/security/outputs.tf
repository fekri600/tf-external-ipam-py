output "alb_security_group_id" {value = aws_security_group.alb.id}
output "ce2_security_group_id" {value = aws_security_group.ec2.id}
output "db_security_group_id" { value = aws_security_group.rds.id }
output "redis_security_group_id" { value = aws_security_group.redis.id }