resource "aws_elasticache_replication_group" "redis" {
  replication_group_id = "redis-${var.prefix}-${var.environment}"
  description          = "redis replication group for ${var.environment} environment"
  node_type            = var.redis.node_type
  subnet_group_name    = var.redis_subnet_group_name
  security_group_ids   = [var.redis_security_group_id]
  engine               = var.redis.redis_settings.engine
  num_cache_clusters   = var.redis.redis_settings.num_cache_clusters

  tags = {
    Name = "${var.prefix}-${var.environment}-redis"
  }
}
