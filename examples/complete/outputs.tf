output "vpc_id" {
  value       = module.complete.vpc_id
  description = "The ID of the VPC."
}

output "vswitch_ids" {
  value       = module.complete.vswitch_ids
  description = "The IDs of the VSwitches."

}

output "nlb_load_balancer_id" {
  value       = module.complete.nlb_load_balancer_id
  description = "The ID of the NLB Load Balancer."
}

output "nlb_server_group_id" {
  value       = module.complete.nlb_server_group_id
  description = "The ID of the NLB Server Group."
}

output "nlb_server_group_server_attachment_id" {
  value       = module.complete.nlb_server_group_server_attachment_id
  description = "The ID of the NLB Server Group Server Attachment."
}

output "nlb_listener_id" {
  value       = module.complete.nlb_listener_id
  description = "The ID of the NLB Listener."
}


output "ecr_id" {
  value       = module.complete.ecr_id
  description = "The id of Express Connect Router."

}

output "ecr_vpc_association_id" {
  value       = module.complete.ecr_vpc_association_id
  description = "The association ID of Express Connect Router and VPC."

}
output "vbr_id" {
  value       = module.complete.vbr_id
  description = "The id of VBR."
}


output "bgp_group_id" {
  value       = module.complete.bgp_group_id
  description = "The id of BGP group."
}


output "bgp_peer_id" {
  value       = module.complete.bgp_peer_id
  description = "The id of BGP peer."
}
