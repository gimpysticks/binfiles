# Backup Configuration — sticksNAS Migration (Jul 25, 2026)

## Overview
Migrated from a NETGEAR ReadyNAS 104 (RAID 5) to a single USB external drive backup.
The NAS is no longer the primary storage solution. All backups now go to a local USB drive.

---

## Backup Drive

| Property     | Value                            |
|--------------|----------------------------------|
| Device       | ADATA HD710 PRO                  |
| Block Device | /dev/sdc                         |
| Partition    | /dev/sdc1                        |
| Filesystem   | exFAT (cross-platform)           |
| Label        | backup                           |
| UUID         | FA77-2196                        |
| Mount Point  | /mnt/backup                      |
| Capacity     | 3.7 TB                           |

### Notes
- Formatted as exFAT for compatibility with Linux, Windows, and PlayStation.
- Drive has a known loose USB connector on the enclosure board.
  - The internal drive is a standard 2.5" SATA HDD.
  - If the connector fails, remove the drive and place it in a new USB 3.0 enclosure (~$10-15).

---

## fstab Entry

Located in `/etc/fstab`:

```
# 4TB ADATA HD710 PRO USB backup drive (exFAT - cross-platform)
UUID=FA77-2196  /mnt/backup  exfat  defaults,nofail,x-systemd.device-timeout=30  0  0
```

- `nofail` — system boots normally even if the drive is not plugged in.
- `x-systemd.device-timeout=30` — waits up to 30 seconds for the drive on boot.

---

## Backup Script

**Location:** `~/bin/Backup`  
**Usage:** `Backup sticks`

- Backs up `/home/sticks/` to `/mnt/backup`
- Uses `rsync` with exFAT-compatible flags (`-rltDv`)
- Sends Discord webhook notifications on start and completion
- Logs stored at `/mnt/backup/logs/`
- Aborts safely if `/mnt/backup` is not mounted

### Key Excludes
Cache, trash, Firefox cache, thumbnails, npm/node_modules, yarn,
Steam, Cargo registry, Rust toolchains, Wine, Snap, Flatpak.

### To make destination configurable at runtime
See comments at the top of `~/bin/Backup` for instructions.

---

## Systemd Timer

Runs the backup automatically every day at **4:00 AM**.

| File | Path |
|------|------|
| Service | `/etc/systemd/system/backup.service` |
| Timer   | `/etc/systemd/system/backup.timer`   |

### Useful Commands

```sh
# Check timer status and next run time
systemctl status backup.timer

# View backup logs
journalctl -u backup.service

# Run backup manually
sudo systemctl start backup.service

# Disable the timer
sudo systemctl disable --now backup.timer
```

---

## ReadyNAS 104 — Decommission Notes

| Bay | Device | Model              | Condition                          |
|-----|--------|--------------------|------------------------------------|
| 1   | sdd    | ST1000DM003-1CH162 | OK (Temp: 33°C, ATA Errors: 0)     |
| 2   | sdc    | ST1000DM003-1CH162 | **FAILING** (19,776 reallocated sectors, 6,528 pending) |
| 3   | sdb    | ST1000DM003-1SB102 | OK — recently replaced             |
| 4   | sda    | ST1000DM003-1CH162 | OK (Temp: 31°C, ATA Errors: 0)     |

- All drives are Seagate Barracuda 1TB desktop drives (not NAS-rated).
- The NAS is running RAID 5, currently resyncing after the Bay 3 replacement.
- **Bay 2 drive is critically failing** — do not rely on it for data.
- Drives being repurposed as standalone USB externals or spare storage.
- NAS left running passively; no further maintenance planned.

---

## Cleanup Performed

- Removed two files with non-printable characters in their filenames from `~/bin`
  (inodes 108539565 and 108539580 — both were 0-byte or garbage files from Jan 4, 2026).
- Removed stale fstab entry: `UUID=6971-FF18 /media/sticks/HD710_PRO exfat ...`
- NFS mount entries in `/etc/fstab` remain commented out (from 192.168.4.2).
