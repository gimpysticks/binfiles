# KDE Connect Custom Commands Export

Exported command configurations for KDE Connect runcommand plugin on paired Android devices.

## Paired Devices

| Device | Device ID | JSON Export | Raw KConfig Backup |
| :--- | :--- | :--- | :--- |
| **Galaxy A13** | `9e2113b65d2d4cb18b6ec7e4fc9c2517` | [`galaxy-a13.json`](galaxy-a13.json) | [`galaxy-a13-runcommand.conf`](galaxy-a13-runcommand.conf) |
| **moto g 5G - 2023** | `38d40c1b6dec4d69ac04274d1ba3bf4a` | [`moto-g-5g.json`](moto-g-5g.json) | [`moto-g-5g-runcommand.conf`](moto-g-5g-runcommand.conf) |

## Configured Commands

| App Button Name | Command | Purpose |
| :--- | :--- | :--- |
| **Monitor Off** | `/home/sticks/bin/monitor-off` | Put monitors into DPMS sleep |
| **Monitor On** | `/home/sticks/bin/monitor-off on` | Wake monitors back up |
| **Lock & Screen Off** | `/home/sticks/bin/monitor-off --lock` | Lock desktop session and turn off displays |
| **Suspend PC** | `/home/sticks/bin/sp` | Put the workstation into sleep/suspend mode |
| **Reboot PC** | `/home/sticks/bin/rb` | Clean reboot via systemd without sudo prompts |
| **Shutdown PC** | `/home/sticks/bin/sd` | Clean power off via systemd |
| **Logout PC** | `/home/sticks/bin/lo` | Terminate the active COSMIC desktop session |

## Restoration Paths

KDE Connect stores these per-device plugin configurations at:
- `~/.config/kdeconnect/<device_id>/kdeconnect_runcommand/config`

After copying or restoring the raw configuration, reload the daemon with:
```bash
systemctl --user restart app-org.kde.kdeconnect.daemon@autostart.service
```
