# modules/network/outputs.tf
output "vpc_id" { value = aws_vpc.this.id }
output "public_subnet_ids" { value = aws_subnet.public[*].id }
output "private_subnet_ids" { value = aws_subnet.private[*].id }
output "ec2_security_group_id" { value = aws_security_group.ec2.id }
output "alb_arn" { value = aws_lb.alb.arn }
output "alb_dns_name" { value = aws_lb.alb.arn }
output "target_group_arn" { value = aws_lb_target_group.tg.arn }
output "rds_subnet_group_name" { value = aws_db_subnet_group.rds.name }
output "redis_subnet_group_name" { value = aws_elasticache_subnet_group.redis.name }
output "db_security_group_id" { value = aws_security_group.rds.id }
output "redis_security_group_id" { value = aws_security_group.redis.id }



