# Retrieve the Availability zones for the chosen region #
data "aws_availability_zones" "available" {
  state = "available"
}
