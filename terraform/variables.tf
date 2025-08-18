variable "project_id" {
  type    = string
  default = "boutique-prod-7f3a1c"
}

variable "region" {
  type    = string
  default = "us-central1"
}

variable "shop_hostname" {
  type    = string
  default = "shop.example.com"
}

variable "dns_managed_zone" {
  type    = string
  default = "example-com"
}

variable "office_cidr" {
  description = "Office egress range used by the strict Cloud Armor policy."
  type        = string
  default     = "203.0.113.0/24"
}
