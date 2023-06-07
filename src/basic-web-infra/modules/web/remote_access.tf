resource "aws_security_group_rule" "webserver_wmi" {
  count             = var.allow_remote_access == true ? 1 : 0
  security_group_id = aws_security_group.webserver.id
  type              = "ingress"
  to_port           = 135
  from_port         = 135
  protocol          = "TCP"
  cidr_blocks       = var.remote_access_cidrs
  description       = "Allows negotiation of WMI connections to the instance"
}

resource "aws_security_group_rule" "webserver_wmi_dynamic" {
  count             = var.allow_remote_access == true ? 1 : 0
  security_group_id = aws_security_group.webserver.id
  type              = "ingress"
  to_port           = 65535
  from_port         = 49152
  protocol          = "TCP"
  cidr_blocks       = var.remote_access_cidrs
  description       = "Allows WMI to open a dynamic port for inbound querying"
}

resource "aws_security_group_rule" "webserver_smb" {
  count             = var.allow_remote_access == true ? 1 : 0
  security_group_id = aws_security_group.webserver.id
  type              = "ingress"
  to_port           = 445
  from_port         = 445
  protocol          = "TCP"
  cidr_blocks       = var.remote_access_cidrs
  description       = "Allows SMB connections"
}

resource "aws_security_group_rule" "webserver_rdp" {
  count             = var.allow_remote_access == true ? 1 : 0
  security_group_id = aws_security_group.webserver.id
  type              = "ingress"
  to_port           = 3389
  from_port         = 3389
  protocol          = "TCP"
  cidr_blocks       = var.remote_access_cidrs
  description       = "Allows RDP access"
}

resource "aws_security_group_rule" "webserver_winrm_http" {
  count             = var.allow_remote_access == true ? 1 : 0
  security_group_id = aws_security_group.webserver.id
  type              = "ingress"
  to_port           = 5985
  from_port         = 5985
  protocol          = "TCP"
  cidr_blocks       = var.remote_access_cidrs
  description       = "Allows winrm access"
}

resource "aws_security_group_rule" "webserver_winrm_https" {
  count             = var.allow_remote_access == true ? 1 : 0
  security_group_id = aws_security_group.webserver.id
  type              = "ingress"
  to_port           = 5986
  from_port         = 5986
  protocol          = "TCP"
  cidr_blocks       = var.remote_access_cidrs
  description       = "Allows https winrm access"
}
