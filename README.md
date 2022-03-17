# Openstack Security Group module (VKCS)
Terraform module designed to simplify and standardize day-by-day Openstack security group (firewall rulset) creation and operations.  
Module has been only tested to work with **VKCS** ([mcs.mail.ru](https://mcs.mail.ru/)) cloud platform, but feel free to use it as a starting point to create your own module for your Openstack hostring provider.
## Features
- Create Group and Rules in one module
- Set list of ports and list of adressess to create Rules for every combnation
- Use one Port value to set port range or only one port
- Set protocols and direction
- Use ip-address or other Security Group ID as destination
- Standardized names for created sub-objects
- Few times less code
### Without module
<details>
  <summary>86 lines of messy code hard to maintain</summary>

    resource "openstack_networking_secgroup_v2" "i_example" {
        name        = "i_example"
        description = "Group to access some service"
    }
    resource "openstack_networking_secgroup_rule_v2" "i_example_1" {
        direction         = "ingress"
        ethertype         = "IPv4"
        protocol          = "tcp"
        port_range_min    = 80
        port_range_max    = 80
        remote_ip_prefix  = "10.10.0.0/24"
        security_group_id = "${openstack_networking_secgroup_v2.i_example.id}"
    }
    resource "openstack_networking_secgroup_rule_v2" "i_example_2" {
        direction         = "ingress"
        ethertype         = "IPv4"
        protocol          = "tcp"
        port_range_min    = 80
        port_range_max    = 80
        remote_ip_prefix  = "10.20.0.0/24"
        security_group_id = "${openstack_networking_secgroup_v2.i_example.id}"
    }
    resource "openstack_networking_secgroup_rule_v2" "i_example_3" {
        direction         = "ingress"
        ethertype         = "IPv4"
        protocol          = "tcp"
        port_range_min    = 80
        port_range_max    = 80
        remote_ip_prefix  = "10.30.0.0/24"
        security_group_id = "${openstack_networking_secgroup_v2.i_example.id}"
    }
    resource "openstack_networking_secgroup_rule_v2" "i_example_4" {
        direction         = "ingress"
        ethertype         = "IPv4"
        protocol          = "tcp"
        port_range_min    = 80
        port_range_max    = 80
        remote_ip_prefix  = "10.40.10.1/32"
        security_group_id = "${openstack_networking_secgroup_v2.i_example.id}"
    }

    resource "openstack_networking_secgroup_rule_v2" "i_example_5" {
        direction         = "ingress"
        ethertype         = "IPv4"
        protocol          = "tcp"
        port_range_min    = 443
        port_range_max    = 443
        remote_ip_prefix  = "10.10.0.0/24"
        security_group_id = "${openstack_networking_secgroup_v2.i_example.id}"
    }
    resource "openstack_networking_secgroup_rule_v2" "i_example_6" {
        direction         = "ingress"
        ethertype         = "IPv4"
        protocol          = "tcp"
        port_range_min    = 443
        port_range_max    = 443
        remote_ip_prefix  = "10.20.0.0/24"
        security_group_id = "${openstack_networking_secgroup_v2.i_example.id}"
    }
    resource "openstack_networking_secgroup_rule_v2" "i_example_7" {
        direction         = "ingress"
        ethertype         = "IPv4"
        protocol          = "tcp"
        port_range_min    = 443
        port_range_max    = 443
        remote_ip_prefix  = "10.30.0.0/24"
        security_group_id = "${openstack_networking_secgroup_v2.i_example.id}"
    }
    resource "openstack_networking_secgroup_rule_v2" "i_example_8" {
        direction         = "ingress"
        ethertype         = "IPv4"
        protocol          = "tcp"
        port_range_min    = 443
        port_range_max    = 443
        remote_ip_prefix  = "10.40.10.1/32"
        security_group_id = "${openstack_networking_secgroup_v2.i_example.id}"
    }
    resource "openstack_networking_secgroup_rule_v2" "i_example_9" {
        direction         = "ingress"
        ethertype         = "IPv4"
        protocol          = "udp"
        port_range_min    = 9000
        port_range_max    = 11000
        remote_ip_prefix  = "192.168.0.0/24"
        security_group_id = "${openstack_networking_secgroup_v2.i_example.id}"
    }

</details>

### With module
<details>
  <summary>24 lines of easy-to-read code</summary>

    module "i_example" {
        source      = "git::https://github.com/realscorp/tf-openstack-vkcs-secgroup.git?ref=v1.0.0"
        name        = "i_example"
        description = "Group to access some service"
        rules = [{
                direction               = "ingress"
                protocol                = "tcp"
                ports                   = ["80", "443"]
                remote_ips = {
                    "Office 1"          = "10.10.0.0/24"
                    "Office 2"          = "10.20.0.0/24"
                    "Office 3"          = "10.30.0.0/24"
                    "Server"            = "10.40.10.1"
                    }
                },
                {
                direction               = "ingress"
                protocol                = "udp"
                ports                   = ["9000-11000"]
                remote_ips = {
                    "Remote access VPN" = "192.168.0.0/24"
                    }
                }]
    }

</details>

# Variables
- **name** - *(string; **required**)* - Security Group name
- **description** - *(string; default: "Terraform Managed")* - SG description
- **delete_default_rules**  - *(boolean; default: true)* - delete default platform rules *(e.g. allow all proto egress to 0.0.0.0/0)*
- **rules** - *(list(object); **required**)* - list of rules
  - **direction** - *(string; **required**)* - connection direction for rule **ingress** / **egress**
  - **protocol** - *(string; **required**)* - connection IP protocol, e.g. *(tcp / udp / icmp / [other](https://registry.terraform.io/providers/terraform-provider-openstack/openstack/latest/docs/resources/networking_secgroup_rule_v2))*
  - **ports** - *(list of string; **required**)* - tcp/udp port list, each item should be **x** for one port or **x-y** for port range
  - **remote_ips** - *(map of string; **required**)* - addresses list in form of ***"address name" = "address value"***, where address value is subnet in CIDR notation **a.b.c.d/m** or host **a.b.c.d/32**. It can also be ID of another Security Group if address name starts with prefix __SG__ (see Examples)

# Requirements
You should have [Openstack provider](https://registry.terraform.io/providers/terraform-provider-openstack/openstack/latest/docs) declared and set up in your root module.
<details>
  <summary>Example of <b>main.tf</b> in your root module</summary>

    terraform {
        required_providers {
            openstack = {
            source = "terraform-provider-openstack/openstack"
            version = "1.33.0"
            }
        }
    }

</details>
<details>
  <summary>Example of <b>init.sh</b> to set-up provider via enviromental variables</summary>

    #!/usr/bin/env bash
    # Openstack (VKCS)
    export OS_AUTH_URL="https://infra.mail.ru:35357/v3/"
    export OS_PROJECT_ID="xxxxxxxxxxxxxxxxxxxxxxx"
    export OS_REGION_NAME="RegionOne"
    export OS_USER_DOMAIN_NAME="users"
    # Remove legacy vars
    unset OS_TENANT_ID
    unset OS_TENANT_NAME
    unset OS_PROJECT_NAME
    unset OS_PROJECT_DOMAIN_ID
    # Ask for credentials if it is not set already
    if [[ -z $OS_USERNAME ]] || [[ -z $OS_PASSWORD ]]; then
        echo "Please enter your OpenStack Username for project $OS_PROJECT_ID: "
        read -sr OS_USERNAME_INPUT
        export OS_USERNAME=$OS_USERNAME_INPUT

        echo "Please enter your OpenStack Password for project $OS_PROJECT_ID as user $OS_USERNAME: "
        read -sr OS_PASSWORD_INPUT
        export OS_PASSWORD=$OS_PASSWORD_INPUT
    fi  

</details>

# Examples
<details>
  <summary><b>Simple Security Group with 2 rules</b></summary>

    module "i_web_dns_example" {
        source      = "./tf-mdl-secgroups"
        name        = "i_web_dns_example"
        description = "Group to access some service"
        rules = [{
                direction               = "ingress"
                protocol                = "tcp"
                ports                   = ["80", "443"]
                remote_ips = {
                    "Office 1"          = "10.10.0.0/24"
                    "Office 2"          = "10.20.0.0/24"
                    "Office 3"          = "10.30.0.0/24"
                    }
                },{
                direction               = "ingress"
                protocol                = "udp"
                ports                   = ["53"]
                remote_ips = {
                    "All internal"      = "10.0.0.0/8"
                    }
                }]
    }

</details>
<details>
  <summary><b>Create Security Group alongside with Instance</b></summary>

    # Create Security Group alongside with Instance
    module "i_int_test" {
        source  = "git::https://github.com/realscorp/tf-openstack-vkcs-secgroup.git?ref=v1.0.0"
        name    = "i_int_test"
        rules   = [{
                    direction               = "ingress"
                    protocol                = "tcp"
                    ports                   = ["80","443"]
                    remote_ips = {
                        "Office IT subnet"  = "10.0.0.0/24"
                        }
                }]
    }
    
    # We'll set even optional variables
    module "windows-vm" {
        source          = "git::https://github.com/realscorp/tf-openstack-vkcs-vm.git?ref=v1.0.0"
        name            = "windows-vm"
        flavor          = "Standard-4-8-80"
        az              = "DP1"
        dns_ttl         = 600
        region          = "RegionOne"
        image           = "Windows-Server-2019Std-en.202105"
        winrm_cert_path = "~/.winrm/winrm.der"
        ssh_key_name    = "ansible-key"
        user_data       = file(pathexpand("${path.module}/some.userdata"))
        metadata        = {
                os                  = "windows"
                os_ver              = "2019"
                service             = "test"
            }
        ports = [
            {
                network             = "network-1"
                subnet              = "subnet-1"
                ip_address          = "10.1.0.66"
                dns_record          = true
                dns_zone            = "domain.example.com"
                security_groups     = ["i_default","o_default"]
                security_groups_ids = [module.i_int_test.sg.id] # Id of a SG we created
            },
            {
                network             = "ext-net"
                subnet              = ""
                ip_address          = ""
                dns_record          = false
                dns_zone            = ""
                security_groups     = ["o_default"]
                security_groups_ids = []
            }
        ]
        volumes = {
            root = {
                type                = "ceph-ssd"
                size                = 50
            }
        }
    }

</details>
<details>
  <summary><b>Create 2 Security Groups with ID of first group as rule address in second group</b></summary>

    # Due to Terrafrom limitations you should apply this code in 2 steps: first create groups without using ID in rule then add ID.
    # Or you can use -target CLI option (https://www.terraform.io/cli/commands/apply#target-resource)
    module "i_int_ldap" {
        source = "git::https://github.com/realscorp/tf-openstack-vkcs-secgroup.git?ref=v1.0.0"
        name = "i_int_ldap"
        description = "Group to access LDAP service"
        rules = [{
                    direction               = "ingress"
                    protocol                = "tcp"
                    ports                   = ["389","636"]
                    remote_ips = {
                        "Office 1"          = "10.10.0.0/16"
                        "_SG_o_int_ldap"    = module.o_int_ldap.id # We use prefix _SG_ to pass ID
                        }
                    }
                ]
    }
    module "o_int_ldap" {
        source = "git::https://github.com/realscorp/tf-openstack-vkcs-secgroup.git?ref=v1.0.0"
        name = "o_int_test"
        description = "Egress group to access LDAP service"
        rules = [{
                    direction       = "egress"
                    protocol        = "tcp"
                    ports           = ["389","636"]
                    remote_ips = {
                        "dc1"       = "10.1.0.10"
                        "dc2"       = "10.1.0.20"
                        }
                    }
                ]
    }

</details>
<details>
  <summary><b>Output usage examples</b></summary>

    # Get all SG attributes
    output "i_int_example" {
        value = module.i_int_example.sg
    }
    # Get Security Group ID
    output "id" {
        value = module.i_int_example.id
    }

</details>

# Author
[Sergey Krasnov](https://github.com/realscorp)