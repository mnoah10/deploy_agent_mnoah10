<<<<<<< HEAD
# Student Attendance Tracker — Setup Guide

This repo contains a shell script that builds the full workspace for the Student Attendance Tracker. Instead of manually creating folders, copying files, and editing config by hand, you just run one script and it handles everything for you.

---

## What's in this repo

```
.
├── setup_project.sh        ← the script you run
├── attendance_checker.py   ← the Python app that processes attendance
├── Helpers/
│   ├── assets.csv          ← student data (names, emails, attendance counts)
│   └── config.json         ← thresholds that control when alerts are sent
├── reports/
│   └── reports.log         ← where the tracker writes its output
└── README.md
```

---

## How to run it

**Step 1 — Clone the repo**

```bash
git clone https://github.com/<your-username>/deploy_agent_<GithubUsername>.git
cd deploy_agent_<GithubUsername>
```

**Step 2 — Make the script executable**

You only need to do this once:

```bash
chmod +x setup_project.sh
```

**Step 3 — Run it**

```bash
./setup_project.sh
```

The script will walk you through everything. You'll be asked two things:

1. **A project name** — something like `cohort2025` or `june_intake`. The script will create a folder called `attendance_tracker_<yourname>` and put everything inside it.

2. **Whether you want to update the attendance thresholds** — the defaults are 75% for a warning and 50% for a failure alert. If you're happy with those, just press Enter to skip.

Once it finishes, you'll have a fully built project folder and a confirmation that Python 3 is installed and all the files are in the right place.

---

## Running the attendance tracker

After setup, just `cd` into your project folder and run the Python script:

```bash
cd attendance_tracker_<yourname>
python3 attendance_checker.py
```

The tracker will read `Helpers/assets.csv`, check each student's attendance against the thresholds in `Helpers/config.json`, and write any alerts to `reports/reports.log`.

---

## The archive feature — what it is and how to trigger it

If you press **Ctrl+C** while the setup script is running, it won't just quit and leave a half-built folder sitting on your machine. Instead it will:

1. Zip up whatever was created so far into a file called `attendance_tracker_<yourname>_archive.tar.gz`
2. Delete the incomplete project folder
3. Exit cleanly

This means your workspace stays tidy even if something goes wrong mid-setup.

Here's what that looks like in practice:

```
$ ./setup_project.sh

  Student Attendance Tracker — Project Setup
  -------------------------------------------

What do you want to call this project? demo
Setting up your project folder: attendance_tracker_demo
Folder structure created.
  Copied attendance_checker.py
^C
Looks like you cancelled the setup. No worries — cleaning up now...
Saving what was built so far to attendance_tracker_demo_archive.tar.gz ...
Archive saved successfully.
Removing the incomplete project folder...
Done. The folder has been removed.

Exiting. Your workspace is clean.
```

If you want to look inside the archive later or restore it, you can use:

```bash
# See what's inside
tar -tzf attendance_tracker_demo_archive.tar.gz

# Extract it
tar -xzf attendance_tracker_demo_archive.tar.gz
```

---

## Config settings explained

The file `Helpers/config.json` controls how the tracker behaves. The setup script can update the thresholds for you, but here's what each setting means:

| Setting | Default | What it does |
|---|---|---|
| `thresholds.warning` | 75 | Students below this percentage get a warning email |
| `thresholds.failure` | 50 | Students below this percentage get an urgent failure alert |
| `run_mode` | `"live"` | Set to `"live"` to actually log alerts, or `"dry_run"` to just print them without writing anything |
| `total_sessions` | 15 | The total number of sessions in the course — used to calculate each student's percentage |

---

## Requirements

- **Python 3** — needed to run `attendance_checker.py`
- **Bash** — the script works on Linux and macOS
- Standard tools like `sed`, `tar`, and `cp` — these come pre-installed on any Unix system
=======
# deploy_agent_mnoah10
>>>>>>> a00a382c1a51cdc2280b139ab04d8dcfb4628bd0
>>>>>>> **Here is the link for the explanation video**: https://drive.google.com/file/d/1Eura943BEB3dlOTxHTBIT0e-fDhkRWDm/view?usp=drive_link
