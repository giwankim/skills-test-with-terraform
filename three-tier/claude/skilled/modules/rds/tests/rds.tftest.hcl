mock_provider "aws" {
  mock_resource "aws_db_instance" {
    defaults = {
      address = "mock-db.abcdefghijkl.us-east-1.rds.amazonaws.com"
      arn     = "arn:aws:rds:us-east-1:123456789012:db:mock-db"
      id      = "mock-db"
      port    = 5432
    }
  }
}

mock_provider "random" {}

# Test 1: Default engine is postgres
run "default_engine_postgres" {
  command = plan

  variables {
    name_prefix           = "rds-test"
    vpc_id                = "vpc-12345678"
    subnet_ids            = ["subnet-aaa", "subnet-bbb"]
    ecs_security_group_id = "sg-ecs123"
    password              = "MockPassword123!"
  }

  assert {
    condition     = aws_db_instance.this.engine == "postgres"
    error_message = "Default engine should be postgres."
  }

  assert {
    condition     = aws_db_instance.this.port == 5432
    error_message = "Default port should be 5432."
  }
}

# Test 2: Storage encrypted by default
run "storage_encrypted" {
  command = plan

  variables {
    name_prefix           = "rds-test"
    vpc_id                = "vpc-12345678"
    subnet_ids            = ["subnet-aaa", "subnet-bbb"]
    ecs_security_group_id = "sg-ecs123"
    password              = "MockPassword123!"
  }

  assert {
    condition     = aws_db_instance.this.storage_encrypted == true
    error_message = "Storage must be encrypted."
  }

  assert {
    condition     = aws_db_instance.this.storage_type == "gp3"
    error_message = "Storage type should be gp3."
  }
}

# Test 3: Custom engine (mysql)
run "custom_engine_mysql" {
  command = plan

  variables {
    name_prefix           = "rds-test"
    vpc_id                = "vpc-12345678"
    subnet_ids            = ["subnet-aaa", "subnet-bbb"]
    ecs_security_group_id = "sg-ecs123"
    password              = "MockPassword123!"
    engine                = "mysql"
    port                  = 3306
  }

  assert {
    condition     = aws_db_instance.this.engine == "mysql"
    error_message = "Engine should be mysql."
  }
}

# Test 4: Auto-generated password when null (apply needed for random_password)
run "auto_generated_password" {
  command = apply

  variables {
    name_prefix           = "rds-test"
    vpc_id                = "vpc-12345678"
    subnet_ids            = ["subnet-aaa", "subnet-bbb"]
    ecs_security_group_id = "sg-ecs123"
  }

  assert {
    condition     = length(random_password.this) == 1
    error_message = "Random password should be generated when password is null."
  }
}

# Test 5: Explicit password skips random generation
run "explicit_password_skips_random" {
  command = plan

  variables {
    name_prefix           = "rds-test"
    vpc_id                = "vpc-12345678"
    subnet_ids            = ["subnet-aaa", "subnet-bbb"]
    ecs_security_group_id = "sg-ecs123"
    password              = "ExplicitPassword123!"
  }

  assert {
    condition     = length(random_password.this) == 0
    error_message = "Random password should not be generated when password is provided."
  }
}

# Test 6: Invalid engine rejected
run "invalid_engine_rejected" {
  command = plan

  variables {
    name_prefix           = "rds-test"
    vpc_id                = "vpc-12345678"
    subnet_ids            = ["subnet-aaa", "subnet-bbb"]
    ecs_security_group_id = "sg-ecs123"
    password              = "MockPassword123!"
    engine                = "oracle"
  }

  expect_failures = [
    var.engine,
  ]
}

# Test 7: SG ingress from ECS
run "security_group_ingress_from_ecs" {
  command = plan

  variables {
    name_prefix           = "rds-test"
    vpc_id                = "vpc-12345678"
    subnet_ids            = ["subnet-aaa", "subnet-bbb"]
    ecs_security_group_id = "sg-ecs123"
    password              = "MockPassword123!"
  }

  assert {
    condition     = aws_security_group.this.ingress != null
    error_message = "Security group should have ingress rules."
  }
}

# Test 8: Tags propagated
run "tags_propagated" {
  command = plan

  variables {
    name_prefix           = "rds-test"
    vpc_id                = "vpc-12345678"
    subnet_ids            = ["subnet-aaa", "subnet-bbb"]
    ecs_security_group_id = "sg-ecs123"
    password              = "MockPassword123!"
    tags = {
      Environment = "test"
    }
  }

  assert {
    condition     = aws_db_instance.this.tags["Environment"] == "test"
    error_message = "Environment tag should be propagated."
  }

  assert {
    condition     = aws_db_instance.this.tags["ManagedBy"] == "terraform"
    error_message = "ManagedBy tag should be set."
  }
}

# Test 9: Default database name
run "default_db_name" {
  command = plan

  variables {
    name_prefix           = "rds-test"
    vpc_id                = "vpc-12345678"
    subnet_ids            = ["subnet-aaa", "subnet-bbb"]
    ecs_security_group_id = "sg-ecs123"
    password              = "MockPassword123!"
  }

  assert {
    condition     = aws_db_instance.this.db_name == "appdb"
    error_message = "Default database name should be appdb."
  }

  assert {
    condition     = aws_db_instance.this.username == "appuser"
    error_message = "Default username should be appuser."
  }
}
