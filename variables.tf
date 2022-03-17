variable "name" {
  type    = string
  description = "Security Group name"
}
variable "description" {
  type    = string
  default = "terraform managed"
  description = "Security Group description"
}
variable "delete_default_rules" {
  type = bool
  default = true
  description = "Set if default Openstack rules should be deleted"
}
# Rules structure
variable "rules"{
  type = list (object({
    ports = list(string)
    protocol = string
    direction = string
    remote_ips = map(string)
  }))
}
