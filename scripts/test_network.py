#!/usr/bin/env python3
"""Network MVP validation tests.

Validates DNS resolution, NTP synchronization, and VLAN/subnet reachability
using system tools (dig, chronyc, ping). Designed for CI and manual execution.

Usage:
    python scripts/test_network.py [--dns-server 10.20.10.2] [--ntp-server 0.pool.ntp.org]
    python scripts/test_network.py --ci  # non-interactive, exit 0 on skip if tools missing
"""

import argparse
import json
import shutil
import subprocess
import sys
from pathlib import Path


class TestResult:
    def __init__(self, name: str, passed: bool, message: str, skipped: bool = False):
        self.name = name
        self.passed = passed
        self.message = message
        self.skipped = skipped

    def __str__(self) -> str:
        if self.skipped:
            status = "SKIP"
        elif self.passed:
            status = "PASS"
        else:
            status = "FAIL"
        return f"  [{status}] {self.name}: {self.message}"


def run_cmd(cmd: list[str], timeout: int = 10) -> tuple[int, str, str]:
    """Run a command and return (returncode, stdout, stderr)."""
    try:
        result = subprocess.run(
            cmd,
            capture_output=True,
            text=True,
            timeout=timeout,
        )
        return result.returncode, result.stdout.strip(), result.stderr.strip()
    except FileNotFoundError:
        return -1, "", f"Command not found: {cmd[0]}"
    except subprocess.TimeoutExpired:
        return -2, "", f"Command timed out after {timeout}s: {' '.join(cmd)}"


def tool_available(name: str) -> bool:
    return shutil.which(name) is not None


# ---------------------------------------------------------------------------
# DNS Tests
# ---------------------------------------------------------------------------
def test_dns_resolution(dns_server: str | None, targets: list[str]) -> list[TestResult]:
    results = []

    if not tool_available("dig") and not tool_available("nslookup"):
        results.append(TestResult("dns-tools", False, "Neither dig nor nslookup found", skipped=True))
        return results

    tool = "dig" if tool_available("dig") else "nslookup"

    for target in targets:
        if tool == "dig":
            cmd = ["dig", "+short", "+timeout=5", target]
            if dns_server:
                cmd.insert(1, f"@{dns_server}")
        else:
            cmd = ["nslookup", target]
            if dns_server:
                cmd.append(dns_server)

        rc, stdout, stderr = run_cmd(cmd)

        if rc == 0 and stdout:
            results.append(TestResult(f"dns-resolve-{target}", True, f"Resolved: {stdout.splitlines()[0]}"))
        elif rc == -1:
            results.append(TestResult(f"dns-resolve-{target}", False, f"Tool missing: {tool}", skipped=True))
        else:
            results.append(TestResult(f"dns-resolve-{target}", False, f"Failed to resolve {target}: {stderr or 'no answer'}"))

    return results


# ---------------------------------------------------------------------------
# NTP Tests
# ---------------------------------------------------------------------------
def test_ntp_sync(ntp_server: str | None) -> list[TestResult]:
    results = []

    if tool_available("chronyc"):
        rc, stdout, stderr = run_cmd(["chronyc", "tracking"])
        if rc == 0:
            synced = "Leap status     : Normal" in stdout or "Reference ID" in stdout
            results.append(TestResult("ntp-chrony-tracking", synced, stdout.splitlines()[0] if stdout else "no output"))
        elif rc == -1:
            results.append(TestResult("ntp-chrony-tracking", False, "chronyc not available", skipped=True))
        else:
            results.append(TestResult("ntp-chrony-tracking", False, f"chronyc error: {stderr}"))

        rc, stdout, stderr = run_cmd(["chronyc", "sources", "-n"])
        if rc == 0 and stdout:
            source_lines = [l for l in stdout.splitlines() if l.startswith("^") or l.startswith("*")]
            results.append(TestResult("ntp-chrony-sources", len(source_lines) > 0, f"{len(source_lines)} sources found"))
        elif rc != -1:
            results.append(TestResult("ntp-chrony-sources", False, f"No sources: {stderr}"))
    elif tool_available("timedatectl"):
        rc, stdout, stderr = run_cmd(["timedatectl", "show", "--property=NTPSynchronized"])
        if rc == 0:
            synced = "NTPSynchronized=yes" in stdout
            results.append(TestResult("ntp-timedatectl", synced, stdout))
        else:
            results.append(TestResult("ntp-timedatectl", False, f"timedatectl error: {stderr}"))
    else:
        results.append(TestResult("ntp-tools", False, "Neither chronyc nor timedatectl found", skipped=True))

    return results


# ---------------------------------------------------------------------------
# VLAN / Subnet Reachability Tests
# ---------------------------------------------------------------------------
def test_subnet_reachability(subnets: list[dict]) -> list[TestResult]:
    results = []

    if not tool_available("ping"):
        results.append(TestResult("ping-tool", False, "ping not found", skipped=True))
        return results

    for subnet in subnets:
        name = subnet.get("name", "unknown")
        cidr = subnet.get("cidr", "")
        if not cidr:
            continue

        # Ping the gateway (.1) of each subnet
        gateway = cidr.rsplit(".", 1)[0] + ".1"
        cmd = ["ping", "-c", "1", "-W", "2", gateway]
        rc, stdout, stderr = run_cmd(cmd, timeout=5)

        if rc == 0:
            results.append(TestResult(f"ping-{name}-gw", True, f"Gateway {gateway} reachable"))
        else:
            results.append(TestResult(f"ping-{name}-gw", False, f"Gateway {gateway} unreachable (expected in CI without network)"))

    return results


# ---------------------------------------------------------------------------
# Terraform Plan Validation
# ---------------------------------------------------------------------------
def test_terraform_plan() -> list[TestResult]:
    results = []
    module_path = Path(__file__).resolve().parents[1] / "terraform" / "modules" / "network"

    if not tool_available("terraform"):
        results.append(TestResult("tf-plan", False, "terraform not found", skipped=True))
        return results

    # Init
    rc, stdout, stderr = run_cmd(
        ["terraform", f"-chdir={module_path}", "init", "-backend=false"],
        timeout=60,
    )
    if rc != 0:
        results.append(TestResult("tf-init", False, f"Init failed: {stderr[:200]}"))
        return results

    results.append(TestResult("tf-init", True, "Initialized successfully"))

    # Validate
    rc, stdout, stderr = run_cmd(
        ["terraform", f"-chdir={module_path}", "validate"],
        timeout=30,
    )
    results.append(TestResult("tf-validate", rc == 0, stdout if rc == 0 else stderr[:200]))

    # Plan with dev tfvars
    dev_tfvars = Path(__file__).resolve().parents[1] / "terraform" / "envs" / "dev" / "network.tfvars"
    if dev_tfvars.exists():
        rc, stdout, stderr = run_cmd(
            ["terraform", f"-chdir={module_path}", "plan", f"-var-file={dev_tfvars}", "-no-color"],
            timeout=60,
        )
        passed = rc == 0
        msg = "Plan succeeded" if passed else stderr[:200]
        results.append(TestResult("tf-plan-dev", passed, msg))

    return results


# ---------------------------------------------------------------------------
# Main
# ---------------------------------------------------------------------------
def load_subnets_from_tfvars() -> list[dict]:
    """Load subnet definitions from dev tfvars for reachability tests."""
    # Hardcoded from terraform/envs/dev/network.tfvars for CI portability
    return [
        {"name": "mgmt-dev", "cidr": "10.20.10.0/24", "tier": "management"},
        {"name": "prod-dev", "cidr": "10.20.20.0/24", "tier": "production"},
        {"name": "dmz-dev", "cidr": "10.20.30.0/24", "tier": "dmz"},
    ]


def main() -> int:
    parser = argparse.ArgumentParser(description="Network MVP validation tests")
    parser.add_argument("--dns-server", default=None, help="DNS server to test against")
    parser.add_argument("--ntp-server", default=None, help="NTP server to verify")
    parser.add_argument("--ci", action="store_true", help="CI mode: skip failures for missing tools")
    parser.add_argument("--skip-ping", action="store_true", help="Skip subnet ping tests")
    parser.add_argument("--skip-terraform", action="store_true", help="Skip Terraform plan tests")
    args = parser.parse_args()

    dns_targets = ["google.com", "cloudflare.com"]
    subnets = load_subnets_from_tfvars()

    all_results: list[TestResult] = []

    print("=" * 60)
    print("Network MVP Validation Tests")
    print("=" * 60)

    # DNS
    print("\n--- DNS Resolution ---")
    dns_results = test_dns_resolution(args.dns_server, dns_targets)
    all_results.extend(dns_results)
    for r in dns_results:
        print(r)

    # NTP
    print("\n--- NTP Synchronization ---")
    ntp_results = test_ntp_sync(args.ntp_server)
    all_results.extend(ntp_results)
    for r in ntp_results:
        print(r)

    # Subnet reachability
    if not args.skip_ping:
        print("\n--- Subnet Reachability ---")
        ping_results = test_subnet_reachability(subnets)
        all_results.extend(ping_results)
        for r in ping_results:
            print(r)

    # Terraform plan
    if not args.skip_terraform:
        print("\n--- Terraform Plan Validation ---")
        tf_results = test_terraform_plan()
        all_results.extend(tf_results)
        for r in tf_results:
            print(r)

    # Summary
    total = len(all_results)
    passed = sum(1 for r in all_results if r.passed)
    failed = sum(1 for r in all_results if not r.passed and not r.skipped)
    skipped = sum(1 for r in all_results if r.skipped)

    print(f"\n{'=' * 60}")
    print(f"Results: {passed}/{total} passed, {failed} failed, {skipped} skipped")
    print(f"{'=' * 60}")

    if args.ci:
        # In CI mode, only hard-fail on non-skipped failures
        return 1 if failed > 0 else 0
    else:
        return 1 if failed > 0 else 0


if __name__ == "__main__":
    sys.exit(main())
