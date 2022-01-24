data "aws_ami" "awslinux" {
  most_recent = "true"
  owners      = [137112412989]
  name_regex  = "^amzn2-ami-kernel-5\\.\\d+-hvm-2.*-x86_64-gp2"

}
output "ami" {
  value = data.aws_ami.awslinux.name
}

resource "aws_instance" "kind" {
  ami                    = data.aws_ami.awslinux.id
  instance_type          = "t2.micro"
  key_name               = "alexbe"
  vpc_security_group_ids = [aws_security_group.kind.id]
  tags = {
    Name = "kind"
  }
  # root_block_device {
  #     volume_size             = "100"
  #     volume_type             = "gp2"
  #     delete_on_termination   = false
  # }
  metadata_options {
    http_endpoint = "enabled"
    http_tokens   = "required"
  }
  user_data = <<-USER_DATA
        #cloud-config
        hostname: kind
        preserve_hostname: true
        prefer_fqdn_over_hostname: false
        final_message: The system is finally up, after $UPTIME seconds
        package_upgrade: true
        package_update: true
        package_reboot_if_required: false
        locale: en_US.UTF-8
        timezone: UTC
        ntp:
            enabled: true
        growpart:
            mode: auto
            devices:
                - /
        packages:
            - aws-apitools-common
            - bash-completion
            - docker
            - golang
            - jq
            - kubectl
        yum_repos:
            kubernetes:
                baseurl: https://packages.cloud.google.com/yum/repos/kubernetes-el7-x86_64
                name: Kubernetes
                enabled: 1
                gpgcheck: 1
                repo_gpgcheck: 1
                gpgkey: https://packages.cloud.google.com/yum/doc/yum-key.gpg https://packages.cloud.google.com/yum/doc/rpm-package-key.gpg
        write_files:
            - path: /etc/profile
              append: true
              content: |
                export GOPATH=/root/go
                export PATH=$${PATH}:/root/go
                which helm > /dev/null && source <(helm completion bash)
                which kind > /dev/null && source <(kind completion bash)
                which kubectl > /dev/null && source <(kubectl completion bash)
            - path: /root/kind.yaml
              content: |
                kind: Cluster
                apiVersion: kind.x-k8s.io/v1alpha4
                nodes:
                  - role: control-plane
                    kubeadmConfigPatches:
                      - |
                        kind: InitConfiguration
                        nodeRegistration:
                          kubeletExtraArgs:
                            node-labels: "ingress-ready=true"
                    extraPortMappings:
                      - containerPort: 80
                        hostPort: 80
                        protocol: TCP
                      - containerPort: 443
                        hostPort: 443
                        protocol: TCP
        runcmd:
            - [ cloud-init-per, instance, docker_enable, systemctl, enable, docker ]
            - [ cloud-init-per, instance, docker_start, systemctl, start, docker ]
            - [ cloud-init-per, instance, kind, sh, -c,
                "HOME=/root go get sigs.k8s.io/kind" ]
            - [ cloud-init-per, instance, kind_bin, ln, -sf, /root/go/bin/kind, /usr/bin/ ]
            - [ cloud-init-per, instance, kind_cluster, sh, -c,
                "HOME=/root kind create cluster --config=/root/kind.yaml" ]
            - [ cloud-init-per, instance, helm_install, sh, -c,
                "curl -L -s https://get.helm.sh/helm-v3.7.2-linux-amd64.tar.gz | sudo tar -C /usr/bin --strip-components=1 -xzf - linux-amd64/helm" ]
            - [ cloud-init-per, instance, repo_clone,
                git, clone, "https://github.com/obezpalko/gh-test.git", "/opt/gh-test" ]
            - [ cloud-init-per, instance, helm_repo, sh, -c,
                "HOME=/root helm repo add stable https://charts.helm.sh/stable" ]
            - [ cloud-init-per, instance, helm_repo, sh, -c,
                "HOME=/root helm repo add nginx-stable https://helm.nginx.com/stable" ]
            - [ cloud-init-per, instance, helm_apply, sh, -c,
                "HOME=/root helm install --set \"nginx-ingress.controller.service.externalIPs={$(docker inspect --format='{{ .NetworkSettings.Networks.kind.IPAddress }}' kind-control-plane)}\" gh /opt/gh-test/gh-test-chart" ]
    USER_DATA
}

output "ip" {
  value = aws_instance.kind.public_ip
}


resource "aws_security_group" "kind" {
  vpc_id = data.aws_vpc.default.id
  name   = "kind"
}

resource "aws_security_group_rule" "egress" {
  security_group_id = aws_security_group.kind.id
  description       = "Allow egress"
  type              = "egress"
  from_port         = -1
  to_port           = -1
  protocol          = -1
  cidr_blocks       = ["0.0.0.0/0"]
}

resource "aws_security_group_rule" "allow_ssh" {
  security_group_id = aws_security_group.kind.id
  description       = "Allow ssh"
  type              = "ingress"
  from_port         = 22
  to_port           = 22
  protocol          = "TCP"
  cidr_blocks       = split(",", data.external.partner.result.networks)
  ipv6_cidr_blocks  = []
  prefix_list_ids   = []
}
resource "aws_security_group_rule" "allow_http" {
  security_group_id = aws_security_group.kind.id
  description       = "Allow HTTP"
  type              = "ingress"
  from_port         = 80
  to_port           = 80
  protocol          = "TCP"
  cidr_blocks       = ["0.0.0.0/0"]
  ipv6_cidr_blocks  = []
  prefix_list_ids   = []
}
resource "aws_security_group_rule" "allow_https" {
  security_group_id = aws_security_group.kind.id
  description       = "Allow HTTP"
  type              = "ingress"
  from_port         = 443
  to_port           = 443
  protocol          = "TCP"
  cidr_blocks       = ["0.0.0.0/0"]
  ipv6_cidr_blocks  = []
  prefix_list_ids   = []
}
resource "aws_security_group_rule" "allow_icmp" {
  security_group_id = aws_security_group.kind.id
  description       = "Allow ping"
  type              = "ingress"
  from_port         = -1
  to_port           = -1
  protocol          = "ICMP"
  cidr_blocks       = ["0.0.0.0/0"]
  ipv6_cidr_blocks  = []
  prefix_list_ids   = []
}

data "external" "partner" {
  program = ["python", "${path.module}/get_partner_networks.py"]
}
