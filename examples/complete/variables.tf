variable "region" {
  default     = "cn-hangzhou"
  type        = string
  description = "The region ID which is used in internal parameter"
}

# VPC & vSwitchs
variable "vpc_config" {
  description = "The parameters of vpc. The attribute 'cidr_block' is required."
  type = object({
    cidr_block  = string
    vpc_name    = optional(string, null)
    enable_ipv6 = optional(bool, null)
  })
  default = {
    cidr_block = "10.0.0.0/16"
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
    zone_id    = "cn-hangzhou-i"
    cidr_block = "10.0.1.0/24"
    }, {
    zone_id    = "cn-hangzhou-j"
    cidr_block = "10.0.2.0/24"
  }]

  validation {
    condition     = length(var.vswitches) >= 2
    error_message = "At least two vswitchs must be configured."
  }
}

variable "nlb_server_group" {
  description = "The parameters of nlb server group."
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
    server_group_name = "idc"
  }
}

variable "nlb_server_group_server_attachment" {
  description = "The parameters of nlb server group server attachment."
  type = object({
    server_id = string
    server_ip = optional(string, null)
    port      = optional(number, null)
    weight    = optional(number, null)
  })
  default = {
    server_id = "172.16.1.5"
    server_ip = "172.16.1.5"
    port      = 80
    weight    = 100
  }
}

variable "nlb_listener" {
  description = "The parameters of nlb listener."
  type = object({
    listener_protocol = string
    listener_port     = number
    idle_timeout      = optional(number, null)
  })
  default = {
    listener_protocol = "TCP"
    listener_port     = 80
    idle_timeout      = 900
  }
}


# ECR
variable "ecr_alibaba_side_asn" {
  description = "The alibaba side asn for ECR."
  type        = number
  default     = 65533
}


variable "tags" {
  description = "The tags of resources."
  type        = map(string)
  default = {
    "Created" = "Terraform"
  }
}




