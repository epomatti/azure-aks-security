output "jump_ssh_command" {
  value = "ssh -i .keys/tmp_key ${var.vm_jump_admin_username}@${module.jump_server.public_ip_address}"
}
