# modules/environment/outputs.tf

output "rds_id" { value = aws_db_instance.this.id }
output "redis_id" { value = aws_elasticache_replication_group.redis.id }
output "asg_name" { value = aws_autoscaling_group.this.name }
output "rds_endpoint" { value = aws_db_instance.this.endpoint }
output "redis_endpoint" { value = aws_elasticache_replication_group.redis.primary_endpoint_address }

output "rds_address" {
  value = aws_db_instance.this.address
}

output "redis_primary_endpoint" {
  value = aws_elasticache_replication_group.redis.primary_endpoint_address
}

