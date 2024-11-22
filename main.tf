
locals {
  vswitches  = { for vswitch in var.vswitches : vswitch.cidr_block => vswitch }
  vbr_config = { for index, vbr in var.vbr_config : index => vbr }
}

# VPC & vSwitchs
resource "alicloud_vpc" "this" {
  vpc_name    = var.vpc_config.vpc_name
  cidr_block  = var.vpc_config.cidr_block
  enable_ipv6 = var.vpc_config.enable_ipv6

  resource_group_id = var.resource_group_id
  tags              = var.tags
}


resource "alicloud_vswitch" "this" {
  for_each = local.vswitches

  vpc_id       = alicloud_vpc.this.id
  cidr_block   = each.value.cidr_block
  zone_id      = each.value.zone_id
  vswitch_name = each.value.vswitch_name

  tags = var.tags
}

# NLB
resource "alicloud_nlb_load_balancer" "this" {
  load_balancer_type = "Network"
  address_type       = "Internet"
  address_ip_version = "Ipv4"
  vpc_id             = alicloud_vpc.this.id

  dynamic "zone_mappings" {
    for_each = alicloud_vswitch.this
    content {
      vswitch_id = zone_mappings.value.id
      zone_id    = zone_mappings.value.zone_id
    }
  }

  resource_group_id = var.resource_group_id
  tags              = var.tags
}

resource "alicloud_nlb_server_group" "this" {
  server_group_type        = "Ip"
  address_ip_version       = "Ipv4"
  vpc_id                   = alicloud_vpc.this.id
  server_group_name        = var.nlb_server_group.server_group_name
  scheduler                = var.nlb_server_group.scheduler
  protocol                 = var.nlb_server_group.protocol
  connection_drain_enabled = var.nlb_server_group.connection_drain_enabled
  connection_drain_timeout = var.nlb_server_group.connection_drain_timeout

  dynamic "health_check" {
    for_each = [var.nlb_server_group.health_check_config]
    content {
      health_check_enabled         = health_check.value.health_check_enabled
      health_check_type            = health_check.value.health_check_type
      health_check_connect_port    = health_check.value.health_check_connect_port
      healthy_threshold            = health_check.value.healthy_threshold
      unhealthy_threshold          = health_check.value.unhealthy_threshold
      health_check_connect_timeout = health_check.value.health_check_connect_timeout
      health_check_interval        = health_check.value.health_check_interval
      http_check_method            = health_check.value.http_check_method
      health_check_http_code       = health_check.value.health_check_http_code
    }
  }
}


resource "alicloud_nlb_server_group_server_attachment" "this" {
  server_type     = "Ip"
  server_group_id = alicloud_nlb_server_group.this.id
  server_id       = var.nlb_server_group_server_attachment.server_id
  server_ip       = var.nlb_server_group_server_attachment.server_ip
  port            = var.nlb_server_group_server_attachment.port
  weight          = var.nlb_server_group_server_attachment.weight
}


resource "alicloud_nlb_listener" "this" {
  load_balancer_id  = alicloud_nlb_load_balancer.this.id
  server_group_id   = alicloud_nlb_server_group.this.id
  listener_protocol = var.nlb_listener.listener_protocol
  listener_port     = var.nlb_listener.listener_port
  idle_timeout      = var.nlb_listener.idle_timeout
}

# ECR
resource "alicloud_express_connect_router_express_connect_router" "this" {
  alibaba_side_asn = var.ecr_alibaba_side_asn

  resource_group_id = var.resource_group_id
  tags              = var.tags
}

data "alicloud_regions" "default" {
  current = true
}


resource "alicloud_express_connect_router_vpc_association" "this" {
  ecr_id                = alicloud_express_connect_router_express_connect_router.this.id
  association_region_id = data.alicloud_regions.default.regions[0].id
  vpc_id                = alicloud_vpc.this.id
  depends_on            = [alicloud_vswitch.this]
}


# VBR
resource "alicloud_express_connect_virtual_border_router" "this" {
  for_each = local.vbr_config

  physical_connection_id     = each.value.physical_connection_id
  vlan_id                    = each.value.vlan_id
  local_gateway_ip           = each.value.local_gateway_ip
  peer_gateway_ip            = each.value.peer_gateway_ip
  peering_subnet_mask        = each.value.peering_subnet_mask
  virtual_border_router_name = each.value.virtual_border_router_name
  description                = each.value.description
}


resource "alicloud_express_connect_router_vbr_child_instance" "this" {
  for_each = local.vbr_config

  child_instance_id        = alicloud_express_connect_virtual_border_router.this[each.key].id
  child_instance_region_id = data.alicloud_regions.default.regions[0].id
  ecr_id                   = alicloud_express_connect_router_express_connect_router.this.id
  child_instance_type      = "VBR"

  lifecycle {
    ignore_changes = [child_instance_owner_id]
  }
}

resource "alicloud_vpc_bgp_group" "this" {
  for_each = local.vbr_config

  router_id      = alicloud_express_connect_router_vbr_child_instance.this[each.key].child_instance_id
  peer_asn       = var.vbr_bgp_group.peer_asn
  auth_key       = var.vbr_bgp_group.auth_key
  bgp_group_name = var.vbr_bgp_group.bgp_group_name
  is_fake_asn    = var.vbr_bgp_group.is_fake_asn
  description    = var.vbr_bgp_group.description
}

resource "alicloud_vpc_bgp_peer" "this" {
  for_each = local.vbr_config

  bgp_group_id    = alicloud_vpc_bgp_group.this[each.key].id
  ip_version      = "IPV4"
  bfd_multi_hop   = var.vbr_bgp_peer.bfd_multi_hop
  enable_bfd      = var.vbr_bgp_peer.enable_bfd
  peer_ip_address = var.vbr_bgp_peer.peer_ip_address
}

