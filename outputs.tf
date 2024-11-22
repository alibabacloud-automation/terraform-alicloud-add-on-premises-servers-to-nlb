output "vpc_id" {
  value       = alicloud_vpc.this.id
  description = "The ID of the VPC."
}

output "vswitch_ids" {
  value       = [for vswitch in alicloud_vswitch.this : vswitch.id]
  description = "The IDs of the VSwitches."

}

output "nlb_load_balancer_id" {
  value       = alicloud_nlb_load_balancer.this.id
  description = "The ID of the NLB Load Balancer."
}

output "nlb_server_group_id" {
  value       = alicloud_nlb_server_group.this.id
  description = "The ID of the NLB Server Group."
}

output "nlb_server_group_server_attachment_id" {
  value       = alicloud_nlb_server_group_server_attachment.this.id
  description = "The ID of the NLB Server Group Server Attachment."
}

output "nlb_listener_id" {
  value       = alicloud_nlb_listener.this.id
  description = "The ID of the NLB Listener."
}

output "ecr_id" {
  value       = alicloud_express_connect_router_express_connect_router.this.id
  description = "The id of Express Connect Router."
}

output "ecr_vpc_association_id" {
  value       = alicloud_express_connect_router_vpc_association.this.association_id
  description = "The association ID of Express Connect Router and VPC."
}

output "vbr_id" {
  value       = [for vbr in alicloud_express_connect_virtual_border_router.this : vbr.id]
  description = "The id of VBR."
}


output "bgp_group_id" {
  value       = [for bgp in alicloud_vpc_bgp_group.this : bgp.id]
  description = "The id of BGP group."
}


output "bgp_peer_id" {
  value       = [for bgp in alicloud_vpc_bgp_peer.this : bgp.id]
  description = "The id of BGP peer."
}
