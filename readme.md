- SOME SCREENS 
MAIN MENU:
<img width="737" height="333" alt="Scherm­afbeelding 2025-09-24 om 23 29 36" src="https://github.com/user-attachments/assets/9f4d0172-5f2e-43f3-bb43-e9e47d59596b" />
<img width="310" height="550" alt="Scherm­afbeelding 2025-09-24 om 23 35 26" src="https://github.com/user-attachments/assets/ffef0f54-5dac-4c24-a853-d88dc6f289a3" />
<img width="647" height="496" alt="Scherm­afbeelding 2025-09-24 om 23 31 12" src="https://github.com/user-attachments/assets/6d7cc569-8b18-42ac-b01b-2b2e3c8875f5" />
<img width="689" height="471" alt="Scherm­afbeelding 2025-09-24 om 23 40 44" src="https://github.com/user-attachments/assets/a2b257d1-741c-49fa-a769-6b0a1ec3ab9a" />
<img width="736" height="725" alt="Scherm­afbeelding 2025-09-24 om 23 44 37" src="https://github.com/user-attachments/assets/ab3c8cac-18be-402b-a5c3-ec4ed36e2bd9" />



Changes Made

Added Auto Unlock CPU/GPU Power Function:
Implements safe pmset tweaks to disable Low Power Mode, sleep, and other power-saving features that throttle CPU/GPU performance.
Includes a verification step using powermetrics to confirm changes.
Backs up power settings before applying tweaks.
Advises users to check System Settings > Battery > Energy Mode for "High Power" (or equivalent on Mac Pro).

Updated Main Menu:

Added option 16: 🔓 Auto Unlock CPU/GPU Power to the menu.

Updated Report Generation:
Enhanced the HTML report to include Auto Unlock status and verification logs.
Preserved Existing Functionality:
Kept the live network scanner, USB formatter, app updater (with non-App Store updates), and all other features unchanged.

Safety Notes:
No kernel edits are included, as they are unsafe and unsupported on M3 hardware.
The unlocks are limited to what Apple's firmware allows (e.g., disabling Low Power Mode, setting High Power mode).

Steps to Fix the Permission Denied Error

Grant Executable Permissions:
Run the following command in the Terminal to make the script executable:
  bashchmod +x Macrocketmenu.sh

Verify Permissions:
Confirm that the script now has executable permissions:
  bashls -l Macrocketmenu.sh
  You should see output like -rwxr-xr-x, where the x indicates executable permissions for the owner, group, and others.
  Once permissions are set, execute the script:
    bash./Macrocketmenu.sh


Additional Checks

Correct Directory: Ensure you are in the same directory as Macrocketmenu.sh. If the script is located elsewhere, navigate to that directory using
- cd /path/to/directory or provide the full path, e.g., ~/path/to/Macrocketmenu.sh.
File Ownership: If the permissions command fails, check the file ownership:
- bashls -l Macrocketmenu.sh
If the file is not owned by your user, change ownership:
bashsudo chown $USER Macrocketmenu.sh

Filesystem Restrictions: If the script is on a read-only or restricted filesystem (e.g., a mounted drive), move it to a writable location like your home directory:
bashmv Macrocketmenu.sh ~/
cd ~
chmod +x Macrocketmenu.sh
./Macrocketmenu.sh

Script Shebang: The script starts with #!/bin/bash, which requires Bash to be installed at /bin/bash. Verify this with:
bashwhich bash
If Bash is not found, install it via Homebrew (brew install bash) or change the shebang to #!/bin/sh for compatibility with the default shell.

If the Issue Persists
If you still encounter issues after setting permissions, please provide:

The output of ls -l Macrocketmenu.sh.
The directory where the script is located (pwd).
Any additional error messages when running the script.
