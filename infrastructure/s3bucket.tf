# #####################################################
# # create s3 bucket to store TF state file
# # dynamodb to lock TF state file & prevent concurrent operations
# #################################################################

# resource "aws_s3_bucket" "terraform_state" {
#   bucket = "prod-env-tfstate"
#   versioning {
#     enabled = true
#   }
  
#   server_side_encryption_configuration {
#     rule {
#       apply_server_side_encryption_by_default {
#         sse_algorithm = "AES256"
#       }
#     }
#   }
# }

# resource "aws_dynamodb_table" "terraform_locks" {
#   name         = "tfstate-lock"
#   billing_mode = "PAY_PER_REQUEST"
#   hash_key     = "LockID"
#   attribute {
#     name = "LockID"
#     type = "S"
#   }
# }