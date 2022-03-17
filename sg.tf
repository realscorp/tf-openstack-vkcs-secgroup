locals {
    # Use 3 nested loops to create flat list of objects for every 'name - port - address' combination 
    rules_list = flatten([for rule_index, rule_value in var.rules : [
        # In a first cycle check port list and if it empty treat it as port 0 ('all ports' in Openstack)
        for port_index, port_value in (length(var.rules[rule_index].ports) == 0 ? ["0"] : var.rules[rule_index].ports) : [
            for ip_desc, ip_address in var.rules[rule_index].remote_ips : {
                description     = ip_desc
                direction       = var.rules[rule_index].direction
                protocol        = var.rules[rule_index].protocol
                ports           = coalesce(port_value, "0")
                remote_ip       = var.rules[rule_index].remote_ips[ip_desc]
                }
            ]
        ]
    ])
    # Create 'map' type variable to store rules list.
    # Generate unique key names (Description-Address-Direction-Protocol-Ports).
    # We use 'map' instead of 'list' to avoid one rule changes will lead to massive rules recreation because of index shift
    rules = {for index,value in local.rules_list : "${value.description}-${value.remote_ip}-${value.direction}-${value.protocol}-${value.ports}" => {
                description     = value.description
                direction       = value.direction
                protocol        = value.protocol
                remote_ip       = value.remote_ip
                ports           = value.ports
                }
            }
}

# Create Security Group
resource "openstack_networking_secgroup_v2" "sg" {
    name                 = var.name
    description          = var.description
    delete_default_rules = var.delete_default_rules
}

# Attach rules to Group
resource "openstack_networking_secgroup_rule_v2" "sg-rule" {
    for_each            = local.rules

    # If rule name have '_SG_' prefix, remove it because it's service flag
    description         = substr(each.value.description,0,4) == "_SG_" ? trimprefix(each.value.description,"_SG_") : each.value.description
    protocol            = each.value.protocol
    port_range_min      = tonumber(element(split("-",each.value.ports),0))

    # If port was set in range form, set range end as Maximum port value, else use same Min and Max port values
    port_range_max      = tonumber(coalesce(element(split("-",each.value.ports),1),element(split("-",each.value.ports),0)))
    ethertype           = "IPv4"
    direction           = each.value.direction

    # If rule name have '_SG_' prefix, it should be interpreted as other Security Group id
    remote_ip_prefix    = substr(each.value.description,0,4) == "_SG_" ? "" : (
        replace(each.value.remote_ip, "/", "") == each.value.remote_ip ? "${each.value.remote_ip}/32" : each.value.remote_ip
        ) # Id address is not in a CIDR format, add /32 mask to it because it is possibly host address
    remote_group_id     = substr(each.value.description,0,4) == "_SG_" ? each.value.remote_ip : ""
    security_group_id   = openstack_networking_secgroup_v2.sg.id
}