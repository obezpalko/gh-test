data "aws_ami" "awslinux" {
    most_recent = "true"
    owners = [137112412989]
    name_regex = "^amzn2-ami-kernel-5\\.\\d+-hvm-2.*-x86_64-gp2"

}
output "ami" {
    value = data.aws_ami.awslinux.name
}

resource "aws_instance" "kind" {
    ami           = data.aws_ami.awslinux.id
    instance_type = "t2.micro"
    key_name      = "alexbe"
    vpc_security_group_ids = [aws_security_group.kind.id]
    tags          = {
        Name      = "kind"
    }
    root_block_device {
        volume_size             = "100"
        volume_type             = "gp2"
        delete_on_termination   = false
    }
    user_data = <<-USER_DATA
        #cloud-config
        final_message: The system is finally up, after $UPTIME seconds
        package_upgrade: true
        package_reboot_if_required: false
        locale: en_US.UTF-8
        hostname: kind
        timezone: UTC
        ntp:
            enabled: true
        growpart:
            mode: auto
            devices:
                - /
        packages:
            - jq
            - golang

    USER_DATA
}

output "ip" {
    value = aws_instance.kind.public_ip
}


resource "aws_security_group" "kind" {
    vpc_id  = data.aws_vpc.default.id
    name = "kind"
}

resource "aws_security_group_rule" "egress" {
    security_group_id = aws_security_group.kind.id
    description       = "Allow egress"
    type              = "egress"
    from_port         = -1
    to_port           = -1
    protocol          = -1
    cidr_blocks       = [ "0.0.0.0/0" ]
}

resource "aws_security_group_rule" "allow_ssh" {
    security_group_id = aws_security_group.kind.id
    description = "Allow ssh"
    type        = "ingress"
    from_port   = 22
    to_port     = 22
    protocol    = "TCP"
    cidr_blocks = split(",", data.external.partner.result.networks)
    ipv6_cidr_blocks = []
    prefix_list_ids = []
}
resource "aws_security_group_rule" "allow_http" {
    security_group_id = aws_security_group.kind.id
    description = "Allow HTTP"
    type        = "ingress"
    from_port   = 80
    to_port     = 80
    protocol    = "TCP"
    cidr_blocks = [ "0.0.0.0/0" ]
    ipv6_cidr_blocks = []
    prefix_list_ids = []
}
resource "aws_security_group_rule" "allow_https" {
    security_group_id = aws_security_group.kind.id
    description = "Allow HTTP"
    type        = "ingress"
    from_port   = 443
    to_port     = 443
    protocol    = "TCP"
    cidr_blocks = [ "0.0.0.0/0" ]
    ipv6_cidr_blocks = []
    prefix_list_ids = []
}
resource "aws_security_group_rule" "allow_icmp" {
    security_group_id = aws_security_group.kind.id
    description = "Allow ping"
    type        = "ingress"
    from_port   = -1
    to_port     = -1
    protocol    = "ICMP"
    cidr_blocks = [ "0.0.0.0/0" ]
    ipv6_cidr_blocks = []
    prefix_list_ids = []
}

data "external" "partner" {
    program = ["python", "${path.module}/get_partner_networks.py"]
}
