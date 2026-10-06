# Linux IT Support Monitor

A Bash-based Linux system health monitoring project designed to simulate basic IT Support / Linux System Administration tasks.

The script checks important system components, reports their health status, and returns an appropriate exit code that can be used by automation tools such as cron, monitoring systems, or CI/CD pipelines.

## Project Goals

This project was built to practice real-world Linux administration and IT support skills, including:

* Linux system monitoring
* Bash scripting
* CPU, memory, and disk monitoring
* Linux service management with systemd
* Log monitoring with journalctl
* Network connectivity checks
* Linux permissions
* Cron automation
* Exit codes
* Git and GitHub workflow

## Project Structure

```text
linux-it-support-monitor/
├── README.md
├── Vagrantfile
├── .gitignore
├── scripts/
│   ├── system_check.sh
│   └── disk_check.sh
├── logs/
│   └── .gitkeep
└── docs/
    └── notes.txt
```

## Main Monitoring Script

The main script is:

```bash
scripts/system_check.sh
```

It performs the following checks:

1. Hostname
2. Operating system
3. Kernel version
4. System uptime
5. CPU usage
6. Memory usage
7. Disk usage
8. Cron service status
9. Recent cron logs
10. Network connectivity
11. Overall system status

## Status Levels

The monitoring system uses three main health states:

```text
OK
WARNING
CRITICAL
```

`CRITICAL` always has priority over `WARNING`.

For example, if CPU usage produces a warning but the cron service is stopped, the final result will still be:

```text
OVERALL STATUS: CRITICAL
```

## Exit Codes

The script returns different exit codes depending on the final health status:

| Status   | Exit Code |
| -------- | --------: |
| OK       |         0 |
| WARNING  |         1 |
| CRITICAL |         2 |
| Unknown  |         3 |

These exit codes allow the script to be integrated with automation and monitoring systems.

## Example Output

A healthy system produces output similar to:

```text
=================================
        SYSTEM HEALTH CHECK
=================================

Hostname:
ubuntu-jammy

Operating system:
PRETTY_NAME="Ubuntu 22.04.5 LTS"

Kernel:
5.x.x

CPU Usage:
OK: CPU usage is 2%

Memory Usage:
OK: Memory usage is 20%

Disk Usage:
OK: Disk usage is 7%

Service Monitoring:
OK: cron is running

Log monitoring:
OK: No errors found in the cron logs

Network Monitoring:
OK: Network is reachable

=================================
OVERALL STATUS: OK
=================================
```

The exact values depend on the current state of the Linux system.

## Running the Monitor

Make sure the script is executable:

```bash
chmod +x scripts/system_check.sh
```

Run it:

```bash
./scripts/system_check.sh
```

Check the exit code:

```bash
echo $?
```

A successful check returns:

```text
0
```

## Syntax Validation

Before executing changes to the Bash script, its syntax can be checked with:

```bash
bash -n scripts/system_check.sh
```

If there is no output, the script passed the Bash syntax check.

## Cron Automation

The monitoring script can be executed automatically using cron.

Example:

```cron
*/5 * * * * cd /home/vagrant/linux-it-support-monitor && ./scripts/system_check.sh >> /home/vagrant/linux-it-support-monitor/logs/system_check.log 2>&1
```

This runs the system health check every five minutes and stores the output in:

```text
logs/system_check.log
```

Log files are excluded from Git using `.gitignore`.

## Testing a Critical Condition

The monitoring system can be tested by stopping the monitored cron service:

```bash
sudo systemctl stop cron
```

Then run:

```bash
./scripts/system_check.sh
echo $?
```

The expected result is:

```text
CRITICAL: cron is not running
OVERALL STATUS: CRITICAL
```

and:

```text
2
```

The service can then be restored:

```bash
sudo systemctl start cron
```

Verify:

```bash
systemctl is-active cron
```

Expected:

```text
active
```

## Technologies

* Ubuntu Linux
* Bash
* systemd
* systemctl
* journalctl
* cron
* awk
* grep
* df
* free
* top
* ping
* Git
* GitHub
* Vagrant

## Environment

The project is developed and tested inside an Ubuntu 22.04 virtual machine using Vagrant.

Example environment:

```text
OS: Ubuntu 22.04.5 LTS
Shell: Bash
Virtualization: VirtualBox + Vagrant
```

## Skills Demonstrated

This project demonstrates practical experience with:

* Linux command line
* Linux filesystem
* Users and groups
* File permissions
* Process management
* systemd services
* Linux logs
* Cron jobs
* Bash scripting
* System monitoring
* Network troubleshooting
* Git version control
* SSH authentication with GitHub
* Basic automation

## Roadmap

Planned improvements:

* [ ] Separate monitoring modules
* [ ] Configurable CPU/memory/disk thresholds
* [ ] Improved log management
* [ ] Automated Bash tests
* [ ] GitHub Actions CI
* [ ] Better error handling
* [ ] Monitoring configuration file
* [ ] Containerized version
* [ ] Cloud deployment

## Author

**Ahmed Imed Eddine Amiraoui**

Computer Science student | IT Support | Linux | Cloud | DevOps

GitHub: https://github.com/ahmedimed

