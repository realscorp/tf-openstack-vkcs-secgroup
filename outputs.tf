# Export all SG attributes
output "sg" {
  value = openstack_networking_secgroup_v2.sg
}
# Export SG id
output "id" {
  value = openstack_networking_secgroup_v2.sg.id
}