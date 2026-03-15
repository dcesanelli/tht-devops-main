resource "aws_dynamodb_table" "orders" {
  name         = "${var.environment}-orders"
  billing_mode = "PAY_PER_REQUEST"
  hash_key     = "order_id"

  attribute {
    name = "order_id"
    type = "S"
  }
}

resource "aws_dynamodb_table" "inventory" {
  name         = "${var.environment}-inventory"
  billing_mode = "PAY_PER_REQUEST"
  hash_key     = "product_id"

  attribute {
    name = "product_id"
    type = "S"
  }
}

resource "aws_dynamodb_table_item" "sample_product_1" {
  table_name = aws_dynamodb_table.inventory.name
  hash_key   = aws_dynamodb_table.inventory.hash_key

  item = <<ITEM
{
  "product_id": {"S": "PROD001"},
  "name": {"S": "Sample Product 1"},
  "price": {"N": "29"},
  "stock": {"N": "100"}
}
ITEM

  lifecycle {
    ignore_changes = [item]
  }
}

resource "aws_dynamodb_table_item" "sample_product_2" {
  table_name = aws_dynamodb_table.inventory.name
  hash_key   = aws_dynamodb_table.inventory.hash_key

  item = <<ITEM
{
  "product_id": {"S": "PROD002"},
  "name": {"S": "Sample Product 2"},
  "price": {"N": "49"},
  "stock": {"N": "50"}
}
ITEM

  lifecycle {
    ignore_changes = [item]
  }
}
