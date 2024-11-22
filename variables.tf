# VPC & vSwitchs
variable "vpc_config" {
  description = "The parameters of vpc. The attribute 'cidr_block' is required."
  type = object({
    cidr_block  = string
    vpc_name    = optional(string, null)
    enable_ipv6 = optional(bool, null)
  })
  default = {
    cidr_block = null
  }
}

variable "vswitches" {
  description = "The parameters of vswitches. The attributes 'zone_id', 'cidr_block' are required."
  type = list(object({
    zone_id      = string
    cidr_block   = string
    vswitch_name = optional(string, null)
  }))
  default = [{
    zone_id    = null
    cidr_block = null
    }, {
    zone_id    = null
    cidr_block = null
  }]


  validation {
    condition     = length(var.vswitches) >= 2
    error_message = "At least two vswitchs must be configured."
  }
}

variable "nlb_server_group" {
  description = "The parameters of nlb server group. The attribute 'server_group_name' is required."
  type = object({
    server_group_name        = string
    scheduler                = optional(string, "Wrr")
    protocol                 = optional(string, "TCP")
    connection_drain_enabled = optional(bool, true)
    connection_drain_timeout = optional(number, 60)

    health_check_config = optional(object({
      health_check_enabled         = optional(bool, true)
      health_check_type            = optional(string, "TCP")
      health_check_connect_port    = optional(number, 0)
      healthy_threshold            = optional(number, 2)
      unhealthy_threshold          = optional(number, 2)
      health_check_connect_timeout = optional(number, 5)
      health_check_interval        = optional(number, 10)
      http_check_method            = optional(string, "GET")
      health_check_http_code       = optional(list(string), ["http_2xx", "http_3xx", "http_4xx"])
    }), {})
  })
  default = {
    server_group_name = "idc_server_group"
  }
}

variable "nlb_server_group_server_attachment" {
  description = "The parameters of nlb server group server attachment. The attribute 'server_id' is required."
  type = object({
    server_id = string
    server_ip = optional(string, null)
    port      = optional(number, null)
    weight    = optional(number, null)
  })
  default = {
    server_id = null
  }
}

variable "nlb_listener" {
  description = "The parameters of nlb listener. The default value of 'listener_protocol' is 'TCP', the default value of 'listener_port' is 80."
  type = object({
    listener_protocol = string
    listener_port     = number
    idle_timeout      = optional(number, null)
  })
  default = {
    listener_protocol = "TCP"
    listener_port     = 80
  }
}


# ECR
variable "ecr_alibaba_side_asn" {
  description = "The alibaba side asn for ECR."
  type        = number
  default     = null
}


# VBR
variable "vbr_config" {
  description = "The list parameters of VBR. The attributes 'physical_connection_id', 'vlan_id', 'local_gateway_ip','peer_gateway_ip','peering_subnet_mask' are required."
  type = list(object({
    physical_connection_id     = string
    vlan_id                    = number
    local_gateway_ip           = string
    peer_gateway_ip            = string
    peering_subnet_mask        = string
    virtual_border_router_name = optional(string, null)
    description                = optional(string, null)
  }))
  default = [
    {
      physical_connection_id = null
      vlan_id                = null
      local_gateway_ip       = null
      peer_gateway_ip        = null
      peering_subnet_mask    = null
    },
    {
      physical_connection_id = null
      vlan_id                = null
      local_gateway_ip       = null
      peer_gateway_ip        = null
      peering_subnet_mask    = null
    }
  ]

  validation {
    condition     = length(var.vbr_config) >= 2
    error_message = "At least two vbr resources must be configured."
  }
}

# BGP
variable "vbr_bgp_group" {
  description = "The parameters of the bgp group. The attribute 'peer_asn' is required."
  type = object({
    peer_asn       = string
    auth_key       = optional(string, null)
    bgp_group_name = optional(string, null)
    description    = optional(string, null)
    is_fake_asn    = optional(bool, false)
  })
  default = {
    peer_asn = null
  }
}

variable "vbr_bgp_peer" {
  description = "The parameters of the bgp peer. The default value of 'bfd_multi_hop' is 255. The default value of 'enable_bfd' is 'false'. The default value of 'ip_version' is 'IPV4'."
  type = object({
    bfd_multi_hop   = optional(number, 10)
    enable_bfd      = optional(bool, "true")
    ip_version      = optional(string, "IPV4")
    peer_ip_address = optional(string, null)
  })
  default = {}
}


variable "tags" {
  description = "The tags of resources."
  type        = map(string)
  default     = {}
}

variable "resource_group_id" {
  description = "The resource group id."
  type        = string
  default     = null
}
