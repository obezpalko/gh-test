import ipaddress
import json
import subprocess


def main():
    addresses = []
    whois = subprocess.run(
        ['whois', '-h', 'whois.ripe.net', '--', '-i origin AS9116 -T route'],
        capture_output=True,
    )
    if whois.returncode != 0:
        return
    for line in whois.stdout.decode('utf-8').split('\n'):
        if line.startswith('route:'):
            addresses.append(ipaddress.ip_network(line.split()[1]))

    print(
        json.dumps({
            'networks': ','.join(
                list(
                    map(
                        lambda x: str(x),
                        ipaddress.collapse_addresses(addresses),
                    ),
                ),
            ),
        }),
    )


def dummy():
    print(
        json.dumps(
            {
                'networks': '104.236.37.215/32,91.199.119.0/24,'
                            '77.124.0.0/14,176.228.0.0/15',
            },
        ),
    )


if __name__ == '__main__':
    dummy()
