provider "alicloud" {
  region = var.region
}

data "alicloud_express_connect_physical_connections" "example" {
  name_regex = "^preserved-NODELETING"
}

module "complete" {
  source = "../.."

  vpc_config = var.vpc_config
  vswitches  = var.vswitches

  nlb_server_group                   = var.nlb_server_group
  nlb_server_group_server_attachment = var.nlb_server_group_server_attachment
  nlb_listener                       = var.nlb_listener

  ecr_alibaba_side_asn = var.ecr_alibaba_side_asn

  vbr_config = [
    {
      physical_connection_id = data.alicloud_express_connect_physical_connections.example.connections[0].id
      vlan_id                = 106
      local_gateway_ip       = "192.168.0.1"
      peer_gateway_ip        = "192.168.0.2"
      peering_subnet_mask    = "255.255.255.252"
    },
    {
      physical_connection_id = data.alicloud_express_connect_physical_connections.example.connections[1].id
      vlan_id                = 107
      local_gateway_ip       = "192.168.1.1"
      peer_gateway_ip        = "192.168.1.2"
      peering_subnet_mask    = "255.255.255.252"
    }
  ]

  vbr_bgp_group = {
    peer_asn = 45000
  }

  tags = var.tags
}
