# modules/environment/outputs.tf

output "rds_id"        { value = aws_db_instance.this.id }
output "redis_id"      { value = aws_elasticache_replication_group.redis.id }
