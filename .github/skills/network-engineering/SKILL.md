---
name: network-engineering
description: "**WORKFLOW SKILL** — Configure, troubleshoot, and secure network infrastructure. USE FOR: firewall rules (nftables/UFW/Firewalld/OPNsense/pfSense), DNS/DHCP configuration, VPN setup (WireGuard/OpenVPN/IPSec), VLAN segmentation, network diagnostics (tcpdump/Wireshark/eBPF), load balancing (Nginx/HAProxy/Traefik), Kubernetes networking (CNI/NetworkPolicies/Ingress), cloud networking (VPC/VNet/NSG), OSI model diagnostics. USE WHEN: configuring firewalls, troubleshooting connectivity, designing network segmentation, setting up VPNs, or managing load balancers."
argument-hint: "Describe the network task (e.g., 'WireGuard site-to-site VPN between Proxmox clusters')"
---

# Network Engineering

Configure, troubleshoot, and secure network infrastructure across on-premises, cloud, and hybrid environments.

## When to Use

- Configuring firewall rules (Linux, cloud, appliances)
- Setting up DNS/DHCP services
- Designing VLAN segmentation or network architecture
- Deploying VPN tunnels (WireGuard, OpenVPN, IPSec)
- Troubleshooting connectivity and performance issues
- Configuring load balancers and reverse proxies
- Managing Kubernetes networking (CNI, NetworkPolicies, Ingress)

## Procedure

### 1. Assess the Network Requirement

Determine:
- **Scope**: On-prem, cloud, hybrid, or Kubernetes
- **Layer**: L2 (switching/VLAN), L3 (routing/IP), L4 (transport/firewall), L7 (application/proxy)
- **Security posture**: Internal-only, DMZ, internet-facing, zero-trust
- **Platform constraints**: Check `skills/_shared/references/environments.md` for OS and hypervisor specifics

### 2. Firewall Configuration

#### Linux Firewalls
```bash
# nftables (modern, recommended)
nft add table inet filter
nft add chain inet filter input { type filter hook input priority 0 \; policy drop \; }
nft add rule inet filter input ct state established,related accept
nft add rule inet filter input iif lo accept
nft add rule inet filter input tcp dport { 22, 443 } accept

# UFW (Ubuntu simplified)
ufw default deny incoming
ufw allow 22/tcp
ufw allow 443/tcp
ufw enable

# Firewalld (RHEL/AlmaLinux)
firewall-cmd --permanent --add-service=ssh
firewall-cmd --permanent --add-service=https
firewall-cmd --reload
```

#### Cloud Security Groups
```hcl
# AWS — Terraform
resource "aws_security_group" "web" {
  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}
```

### 3. DNS & DHCP

**DNS record checklist:**
- [ ] A/AAAA records for services
- [ ] PTR records for reverse lookups
- [ ] MX + SPF + DKIM + DMARC for email
- [ ] SRV records for service discovery
- [ ] CAA records for certificate authority pinning

```bash
# Diagnostics
dig +short example.com A
dig +trace example.com
host -t MX example.com
nslookup -type=SOA example.com
```

### 4. VPN Deployment

#### WireGuard (recommended)
```ini
# /etc/wireguard/wg0.conf — Server
[Interface]
PrivateKey = <server-private-key>
Address = 10.0.0.1/24
ListenPort = 51820

[Peer]
PublicKey = <client-public-key>
AllowedIPs = 10.0.0.2/32
```

#### Site-to-Site Pattern
```text
Site A (10.1.0.0/24) ←── WireGuard tunnel ──→ Site B (10.2.0.0/24)
     wg0: 10.0.0.1/24                          wg0: 10.0.0.2/24
     AllowedIPs: 10.2.0.0/24                   AllowedIPs: 10.1.0.0/24
```

### 5. VLAN Segmentation

**Standard VLAN design:**

| VLAN ID | Name | Purpose | Subnet |
| --------- | ------ | --------- | -------- |
| 10 | Management | Admin access, IPMI/iDRAC | 10.0.10.0/24 |
| 20 | Servers | Production workloads | 10.0.20.0/24 |
| 30 | DMZ | Internet-facing services | 10.0.30.0/24 |
| 40 | Storage | iSCSI/NFS traffic | 10.0.40.0/24 |
| 50 | IoT | Isolated IoT devices | 10.0.50.0/24 |
| 99 | Guest | Guest WiFi (internet-only) | 10.0.99.0/24 |

```bash
# Linux bridge with VLAN
ip link add link eth0 name eth0.20 type vlan id 20
ip addr add 10.0.20.1/24 dev eth0.20
ip link set eth0.20 up
```

### 6. Load Balancing

```nginx
# Nginx upstream with health checks
upstream backend {
    least_conn;
    server 10.0.20.10:8080 max_fails=3 fail_timeout=30s;
    server 10.0.20.11:8080 max_fails=3 fail_timeout=30s;
    server 10.0.20.12:8080 backup;
}

server {
    listen 443 ssl http2;
    location / {
        proxy_pass http://backend;
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;
    }
}
```

### 7. Kubernetes Networking

```yaml
# NetworkPolicy — deny all, allow specific
apiVersion: networking.k8s.io/v1
kind: NetworkPolicy
metadata:
  name: allow-web-only
  namespace: production
spec:
  podSelector:
    matchLabels:
      app: api
  policyTypes:
    - Ingress
    - Egress
  ingress:
    - from:
        - namespaceSelector:
            matchLabels:
              name: frontend
      ports:
        - port: 8080
  egress:
    - to:
        - namespaceSelector:
            matchLabels:
              name: database
      ports:
        - port: 5432
    - to:  # DNS
        - namespaceSelector: {}
      ports:
        - port: 53
          protocol: UDP
```

## OSI Diagnostics Toolkit

| Layer | Tools | What to Check |
| ------- | ------- | --------------- |
| L1 (Physical) | `ethtool`, `ip link` | Link state, speed, duplex, errors |
| L2 (Data Link) | `arp`, `bridge`, `ip neighbor` | MAC tables, VLAN tags, ARP entries |
| L3 (Network) | `ip route`, `traceroute`, `mtr`, `ping` | Routes, hops, packet loss, MTU |
| L4 (Transport) | `ss`, `netstat`, `tcpdump` | Port states, connections, SYN retransmits |
| L7 (Application) | `curl`, `openssl s_client`, `wget` | HTTP codes, TLS handshake, headers |
| Advanced | Wireshark, `tshark`, eBPF (`bpftrace`) | Packet capture, protocol analysis, tracing |

## Common Issue Patterns

1. **DNS resolution failure** — Check `/etc/resolv.conf`, upstream DNS, split-horizon, NXDOMAIN
2. **Asymmetric routing** — Verify routes on all interfaces, check NAT/SNAT, policy routing
3. **MTU/MSS issues** — Path MTU discovery, tunnel overhead (WireGuard = 80 bytes), MSS clamping
4. **Firewall stateful misconfig** — Check conntrack; ensure `ct state established,related accept`
5. **TLS certificate mismatch** — Verify SAN, intermediate chain, expiration, OCSP stapling
6. **K8s DNS failure** — CoreDNS pods running? `egress` NetworkPolicy allows port 53/UDP?
7. **VLAN not passing traffic** — Trunk port? tagged vs untagged? bridge VLAN filtering enabled?

## Anti-Patterns

- Opening wide port ranges instead of specific services
- Using `iptables` on systems that use nftables (dual-stack conflict)
- Flat networks without segmentation (blast radius)
- Hardcoded IP addresses instead of DNS names
- Missing reverse DNS (PTR) for mail servers
- Running DNS resolvers without rate limiting (amplification attacks)
- Not logging firewall drops
- NetworkPolicies without egress rules for DNS

## Agent Integration

- **`executant-security-ops`**: Review firewall rules, network segmentation, and TLS configuration
- **`executant-cloud-ops`**: Cloud-specific networking (VPC/VNet/NSG, peering, transit gateways)
- **`executant-platform-ops`**: Hypervisor networking (bridges, VLANs, pve-firewall, dvSwitch)
- **`executant-observability-ops`**: Network metrics, flow logging, and monitoring dashboards
- **`executant-infra-architect`**: Network architecture decisions and topology review
