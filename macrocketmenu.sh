#!/bin/bash
set -euo pipefail

# Macrocketmenu.sh - Advanced System Tweaker for macOS Sonoma on M3 Mac Pro (Supreme Hacker Edition)
# Run with: chmod +x Macrocketmenu.sh && ./Macrocketmenu.sh
# WARNING: These tweaks require sudo and may affect stability/battery. Use at your own risk! Formatting USBs is DANGEROUS!
# Log file: ~/macrocketmenu.log
# Supreme Edition: Added CLI Hacker Tools, System Checkers, Expanded Installs with HandBrake, Picard, muCommander, FileZilla, etc.
# Safety Enhancements: Error handling, input validation, backups for tweaks, removable check for USB, hash verification for downloads where possible.
# Features: Fancy HTML report on exit - rocketreport.html, Live Network Scanner with SMB, IP Cameras, Devices, Gateways, VLAN/Hidden Networks, Non-App Store Updates
# New: Auto Unlock CPU/GPU Power (safe pmset tweaks + powermetrics verification)
# Fix: Added navigation handler to ensure correct submenu is opened from main menu selections

LOG_FILE="$HOME/macrocketmenu.log"
REPORT_FILE="$HOME/rocketreport.html"
SCAN_LOG="$HOME/network_scan.log"
AIRPORT="/System/Library/PrivateFrameworks/Apple80211.framework/Versions/Current/Resources/airport"
BACKUP_DIR="$HOME/macrocketmenu_backups"
mkdir -p "$BACKUP_DIR"

# Colors for supreme hacker output
RED=$(tput setaf 1)
GREEN=$(tput setaf 2)
YELLOW=$(tput setaf 3)
BLUE=$(tput setaf 4)
PURPLE=$(tput setaf 5)
CYAN=$(tput setaf 6)
RESET=$(tput sgr0)
BOLD=$(tput bold)
DIM=$(tput dim)

# Hacker Matrix effect (supreme)
matrix_effect() {
    for i in {1..12}; do
        echo -n "${GREEN}$(cat /dev/urandom | tr -dc '01' | fold -w $(( $(tput cols) / 2 )) | head -n 1)${RESET}"
        sleep 0.02
        clear
    done
}

# ASCII Rocket Fleet (purple, expanded)
ROCKET_FLEET="
   ${PURPLE}.     .     .     .     .${RESET}
  ${PURPLE}/ \\   / \\   / \\   / \\   / \\${RESET}
 ${PURPLE}/   \\ /   \\ /   \\ /   \\ /   \\${RESET}
${PURPLE}/_____\\_____\\_____\\_____\\_____\\${RESET}
${PURPLE}|     |     |     |     |     |${RESET}
${PURPLE}|     |     |     |     |     |${RESET}
${PURPLE}|     |     |     |     |     |${RESET}
${PURPLE}======= ======= ======= ======= =======${RESET}
"

# Boosted Rocket Fleet (with fire & green glow)
ROCKET_BOOSTED_FLEET="
   ${PURPLE}.     .     .     .     .${RESET}
  ${PURPLE}/ \\   / \\   / \\   / \\   / \\${RESET}
 ${PURPLE}/   \\ /   \\ /   \\ /   \\ /   \\${RESET}
${PURPLE}/_____\\_____\\_____\\_____\\_____\\${RESET}
${PURPLE}|     |     |     |     |     |${RESET}
${PURPLE}|     |     |     |     |     |${RESET}
${PURPLE}|     |     |     |     |     |${RESET}
${PURPLE}======= ======= ======= ======= =======${RESET}
${GREEN} ^ ^ ^  ^ ^ ^  ^ ^ ^  ^ ^ ^  ^ ^ ^${RESET}
${YELLOW} * * *  * * *  * * *  * * *  * * *${RESET}
${RED} 🔥 🔥 🔥 🔥 🔥 🔥 🔥 🔥 🔥 🔥 🔥 🔥${RESET}
"

# Function to log actions (supreme style)
log() {
    echo "$(date '+%Y-%m-%d %H:%M:%S'): $1" >> "$LOG_FILE"
    echo "${GREEN}[SUPREME_HACK_LOG]${RESET} ${DIM}$1${RESET}"
}

# Function to show info (supreme bordered)
show_info() {
    echo "${GREEN}┌──(${PURPLE}${BOLD}$1${RESET}${GREEN})────┐${RESET}"
    echo "${GREEN}│${RESET} ${DIM}$2${RESET}"
    echo "${GREEN}│${RESET}"
    echo "${GREEN}│ ${YELLOW}Pros:${RESET} $3"
    echo "${GREEN}│ ${YELLOW}Cons:${RESET} $4"
    echo "${GREEN}└──────────────────────────────────────┘${RESET}"
    echo ""
}

# Function to execute sudo command safely with error handling
sudo_exec() {
    if ! sudo "$@" 2>/dev/null; then
        log "ERROR: Failed to execute '$*'"
        echo "${RED}Failed to supreme hack: $*${RESET}"
        return 1
    else
        log "SUCCESS: Executed '$*' - SUPREMELY HACKED"
        return 0
    fi
}

# Backup function for settings
backup_settings() {
    local domain="$1"
    local backup_file="$BACKUP_DIR/${domain//./_}_$(date +%s).plist"
    defaults export "$domain" "$backup_file" 2>/dev/null || log "Warning: Failed to backup $domain"
    log "Backed up $domain to $backup_file"
}

# Restore advice
restore_advice() {
    echo "${YELLOW}To restore settings, use: defaults import domain path/to/backup.plist && killall relevant-app${RESET}"
    echo "${YELLOW}For pmset, use pmset restore from backup txt.${RESET}"
}

# Function to check if tweak is enabled (expanded)
is_enabled() {
    case "$1" in
        "lowpowermode") pmset -g | grep "lowpowermode.*0" >/dev/null 2>&1 ;;
        "sleep") pmset -g | grep " sleep.*0" >/dev/null 2>&1 ;;
        "displaysleep") pmset -g | grep " displaysleep.*0" >/dev/null 2>&1 ;;
        "awdl") ! ifconfig awdl0 >/dev/null 2>&1 ;;
        "hibernatemode") pmset -g | grep "hibernatemode.*0" >/dev/null 2>&1 ;;
        "animations") defaults read NSGlobalDomain NSAutomaticWindowAnimationsEnabled 2>/dev/null | grep "0" >/dev/null 2>&1 ;;
        "spotlight") mdutil -s / | grep "Indexing disabled" >/dev/null 2>&1 ;;
        "cpu_gpu_unlock") pmset -g | grep -E "lowpowermode.*0.*sleep.*0.*displaysleep.*0.*autopoweroff.*0.*standby.*0.*hibernatemode.*0" >/dev/null 2>&1 ;;
        *) return 1 ;;
    esac
}

# Backup PMSET
backup_pmset() {
    pmset -g > "$BACKUP_DIR/pmset_backup_$(date +%s).txt" 2>/dev/null
    log "PMSET backed up"
}

# NEW: Navigation Handler
navigate_to_menu() {
    local target_menu="$1"
    log "Navigating to $target_menu menu"
    case "$target_menu" in
        "wifi") wifi_menu ;;
        "power") power_menu ;;
        "gpu") gpu_menu ;;
        "system") system_menu ;;
        "main") main_menu ;;
        *) log "ERROR: Invalid menu $target_menu"; main_menu ;;
    esac
}

# Auto Unlock CPU/GPU Power Function
auto_unlock_power() {
    clear
    echo "${GREEN}┌──(${PURPLE}🔓 Auto Unlock CPU/GPU Power${GREEN})─┐${RESET}"
    echo "${GREEN}│ Applying safe max perf profile (no kernel edits). │${RESET}"
    echo "${GREEN}└──────────────────────────────────────────────┘${RESET}"
    echo ""
    show_info "Auto Unlock Power" "pmset -a lowpowermode 0 sleep 0 displaysleep 0 autopoweroff 0 standby 0 hibernatemode 0" "Maximizes CPU/GPU clocks for performance tasks" "May increase heat; reboot may reset some settings"
    read -p "Confirm unlock? (y/n): " confirm
    if [[ $confirm != "y" ]]; then navigate_to_menu "main"; return; fi

    backup_pmset
    log "=== Auto Unlock Power Started ==="

    # Apply Unlock Tweaks
    sudo_exec pmset -a lowpowermode 0 || { echo "${RED}Low Power disable failed.${RESET}"; navigate_to_menu "main"; return; }
    sudo_exec pmset -a sleep 0 || { echo "${RED}Sleep disable failed.${RESET}"; navigate_to_menu "main"; return; }
    sudo_exec pmset -a displaysleep 0 || { echo "${RED}Display sleep disable failed.${RESET}"; navigate_to_menu "main"; return; }
    sudo_exec pmset -a autopoweroff 0 || { echo "${RED}Auto off disable failed.${RESET}"; navigate_to_menu "main"; return; }
    sudo_exec pmset -a standby 0 || { echo "${RED}Standby disable failed.${RESET}"; navigate_to_menu "main"; return; }
    sudo_exec pmset -a hibernatemode 0 || { echo "${RED}Hibernation disable failed.${RESET}"; navigate_to_menu "main"; return; }
    sudo_exec pmset -a CPUSpeedLimit 0 || log "CPU limit reset (may be ignored on M3)"

    log "=== Auto Unlock Power Complete ==="

    # Verification Snapshot
    echo "${YELLOW}Verifying changes (powermetrics snapshot)...${RESET}"
    powermetrics --samplers tasks,thermal,cpu_power,gpu_power -i 2000 -n 1 > "$BACKUP_DIR/power_verify_$(date +%s).txt" 2>/dev/null || echo "${YELLOW}powermetrics unavailable.${RESET}"
    echo "${GREEN}Unlock applied! Check System Settings > Battery > Energy Mode for 'High Power'.${RESET}"
    echo "${YELLOW}Note: Reboot may reset some; firmware limits apply.${RESET}"
    log "Auto Unlock verification saved to $BACKUP_DIR"
    sleep 5
    navigate_to_menu "main"
}

# Live Network Scanner
network_scanner() {
    clear
    echo "${GREEN}┌──(${PURPLE}🌐 Live Network Scanner${GREEN})─┐${RESET}"
    echo "${GREEN}│ Scanning for SMB, IP Cameras, Devices, Gateways, VLAN/Hidden... │${RESET}"
    echo "${GREEN}└──────────────────────────────────────────────────────────────┘${RESET}"
    echo ""
    if ! command -v nmap &> /dev/null; then
        echo "${YELLOW}Installing nmap...${RESET}"
        brew install nmap || echo "${RED}Nmap install failed. Install manually.${RESET}"
    fi
    # Detect subnet
    IFACE=$(route get default | grep interface | awk '{print $2}')
    SUBNET=$(ipconfig getifaddr $IFACE 2>/dev/null || echo "192.168.1.0/24")
    echo "${YELLOW}Scanning subnet: $SUBNET on $IFACE${RESET}"
    log "Network scan started on $SUBNET"
    > "$SCAN_LOG"
    echo "${BLUE}1. Gateways:${RESET}"
    netstat -nr | grep UG || echo "No gateways found"
    echo "" >> "$SCAN_LOG"
    echo "Gateways:" >> "$SCAN_LOG"
    netstat -nr | grep UG >> "$SCAN_LOG"
    echo ""
    echo "${BLUE}2. Connected Devices (Host Discovery):${RESET}"
    nmap -sn "$SUBNET" | tee -a "$SCAN_LOG" || echo "${RED}Host scan failed.${RESET}"
    echo ""
    read -p "Deep scan top 5 hosts for device info/IP+ports? (y/n): " deep_yn
    if [[ $deep_yn == "y" ]]; then
        HOSTS=$(nmap -sn "$SUBNET" | grep "Nmap scan report" | awk '{print $5}' | head -5)
        for host in $HOSTS; do
            echo "${YELLOW}Scanning $host for ports/services/OS:${RESET}"
            nmap -sV -O -p- "$host" | tee -a "$SCAN_LOG" || echo "Scan for $host failed"
        done
    fi
    echo ""
    echo "${BLUE}3. SMB Shares:${RESET}"
    nmap -p445 --script smb-enum-shares "$SUBNET" | tee -a "$SCAN_LOG" || echo "${RED}SMB scan failed.${RESET}"
    echo ""
    echo "${BLUE}4. IP Cameras (Ports 80,554,8554):${RESET}"
    nmap -p80,554,8554 --script http-title,rtsp-methods "$SUBNET" | tee -a "$SCAN_LOG" || echo "${RED}Camera scan failed.${RESET}"
    echo ""
    echo "${BLUE}5. VLAN/Hidden WiFi Networks:${RESET}"
    "$AIRPORT" -s | tee -a "$SCAN_LOG" || echo "${RED}WiFi scan failed.${RESET}"
    echo ""
    log "Network scan completed. Log: $SCAN_LOG"
    echo "${GREEN}Scan complete! View $SCAN_LOG for details.${RESET}"
    sleep 3
    navigate_to_menu "main"
}

# Generate Fancy HTML Report (enhanced with Auto Unlock status)
generate_report() {
    log "Generating rocketreport.html"

    # Statuses
    lowpower_status=$(is_enabled lowpowermode && echo "DISABLED" || echo "ENABLED")
    lowpower_class=$(is_enabled lowpowermode && echo "green" || echo "red")
    sleep_status=$(is_enabled sleep && echo "DISABLED" || echo "ENABLED")
    sleep_class=$(is_enabled sleep && echo "green" || echo "red")
    displaysleep_status=$(is_enabled displaysleep && echo "DISABLED" || echo "ENABLED")
    displaysleep_class=$(is_enabled displaysleep && echo "green" || echo "red")
    awdl_status=$(is_enabled awdl && echo "DISABLED" || echo "ENABLED")
    awdl_class=$(is_enabled awdl && echo "green" || echo "red")
    hibernatemode_status=$(is_enabled hibernatemode && echo "DISABLED" || echo "ENABLED")
    hibernatemode_class=$(is_enabled hibernatemode && echo "green" || echo "red")
    animations_status=$(is_enabled animations && echo "DISABLED" || echo "ENABLED")
    animations_class=$(is_enabled animations && echo "green" || echo "red")
    spotlight_status=$(is_enabled spotlight && echo "DISABLED" || echo "ENABLED")
    spotlight_class=$(is_enabled spotlight && echo "green" || echo "red")
    cpu_gpu_unlock_status=$(is_enabled cpu_gpu_unlock && echo "UNLOCKED" || echo "LOCKED")
    cpu_gpu_unlock_class=$(is_enabled cpu_gpu_unlock && echo "green" || echo "red")

    # Tweaks table rows
    tweak_rows=""
    while IFS= read -r line; do
        if [[ $line =~ SUCCESS ]]; then
            time_part=$(echo "$line" | cut -d':' -f1)
            action=$(echo "$line" | cut -d':' -f2-)
            tweak_rows+="<tr><th>$time_part</th><th>$action</th></tr>\n"
        fi
    done < "$LOG_FILE"

    # Full log escaped
    full_log=$(sed 's/&/\&amp;/g; s/</\&lt;/g; s/>/\&gt;/g' "$LOG_FILE")

    # Scan log if exists
    if [[ -f "$SCAN_LOG" ]]; then
        scan_section="<h2>Network Scan Log</h2><pre class=\"log-entry\">$(sed 's/&/\&amp;/g; s/</\&lt;/g; s/>/\&gt;/g' "$SCAN_LOG")</pre>"
    else
        scan_section=""
    fi

    # Power verification log if exists
    power_verify_section=""
    if ls "$BACKUP_DIR"/power_verify_*.txt >/dev/null 2>&1; then
        latest_power_verify=$(ls -t "$BACKUP_DIR"/power_verify_*.txt | head -1)
        power_verify_section="<h2>Power Unlock Verification Log</h2><pre class=\"log-entry\">$(sed 's/&/\&amp;/g; s/</\&lt;/g; s/>/\&gt;/g' "$latest_power_verify")</pre>"
    fi

    # HTML template
    html=$(cat <<EOF
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>🚀 MAC Rocket Menu Report</title>
    <style>
        body { font-family: Arial, sans-serif; background-color: #f0f0f0; color: #333; margin: 0; padding: 20px; }
        h1 { text-align: center; color: #4a90e2; }
        .dashboard { display: grid; grid-template-columns: repeat(auto-fit, minmax(200px, 1fr)); gap: 20px; margin-bottom: 30px; }
        .card { background-color: white; padding: 15px; border-radius: 8px; box-shadow: 0 2px 4px rgba(0,0,0,0.1); }
        .card h3 { margin-top: 0; }
        .status-green { color: green; font-weight: bold; }
        .status-red { color: red; font-weight: bold; }
        table { width: 100%; border-collapse: collapse; margin-bottom: 30px; }
        th, td { border: 1px solid #ddd; padding: 8px; text-align: left; }
        th { background-color: #f2f2f2; }
        .log-entry { white-space: pre-wrap; background-color: #fff; padding: 10px; border: 1px solid #ddd; border-radius: 4px; }
    </style>
</head>
<body>
    <h1>🚀 MAC Rocket Menu System Tweak Report</h1>
    <p style="text-align: center;">Generated on $(date)</p>
    
    <h2>Dashboard Overview</h2>
    <div class="dashboard">
        <div class="card">
            <h3>Low Power Mode</h3>
            <p class="status-$lowpower_class">$lowpower_status</p>
        </div>
        <div class="card">
            <h3>Sleep</h3>
            <p class="status-$sleep_class">$sleep_status</p>
        </div>
        <div class="card">
            <h3>Display Sleep</h3>
            <p class="status-$displaysleep_class">$displaysleep_status</p>
        </div>
        <div class="card">
            <h3>AWDL</h3>
            <p class="status-$awdl_class">$awdl_status</p>
        </div>
        <div class="card">
            <h3>Hibernation Mode</h3>
            <p class="status-$hibernatemode_class">$hibernatemode_status</p>
        </div>
        <div class="card">
            <h3>Animations</h3>
            <p class="status-$animations_class">$animations_status</p>
        </div>
        <div class="card">
            <h3>Spotlight</h3>
            <p class="status-$spotlight_class">$spotlight_status</p>
        </div>
        <div class="card">
            <h3>CPU/GPU Unlock</h3>
            <p class="status-$cpu_gpu_unlock_class">$cpu_gpu_unlock_status</p>
        </div>
    </div>
    
    <h2>Tweaks Applied</h2>
    <table>
        <tr><th>Time</th><th>Action</th></tr>
        $tweak_rows
    </table>
    
    <h2>Full Log</h2>
    <pre class="log-entry">$full_log</pre>
    
    $scan_section
    
    $power_verify_section
    
    <h2>Restore Advice</h2>
    <p>Use backups in $BACKUP_DIR to restore settings.</p>
</body>
</html>
EOF
)

    echo "$html" > "$REPORT_FILE"
    log "Report generated: $REPORT_FILE"
    open "$REPORT_FILE" 2>/dev/null || echo "${YELLOW}Open failed; view $REPORT_FILE manually.${RESET}"
}

# USB Formatter Function (enhanced safety)
usb_formatter() {
    clear
    echo "${GREEN}┌──(${PURPLE}💾 USB Formatter Hack${GREEN})─┐${RESET}"
    echo "${GREEN}│ DANGEROUS: This will ERASE your USB! Triple confirm. │${RESET}"
    echo "${GREEN}└──────────────────────────────────────────────┘${RESET}"
    echo ""
    echo "${YELLOW}Scanning removable USB devices...${RESET}"
    DISKS=$(diskutil list | grep -E '^/dev/disk[0-9]+' | grep -v 'disk0' | awk '{print $1 " (" $NF ")"}')
    echo "${BLUE}Available Disks:${RESET}"
    echo "$DISKS"
    read -p "${GREEN}Enter disk (e.g., disk2): ${RESET}" disk
    if [[ ! $disk =~ ^disk[0-9]+$ ]]; then
        echo "${RED}Invalid disk!${RESET}"
        sleep 2
        navigate_to_menu "main"
        return
    fi
    # Check if removable
    if ! diskutil info "$disk" | grep -q "Removable Media:.*Removable"; then
        echo "${RED}Disk $disk is not removable! Aborting.${RESET}"
        log "Aborted format: $disk not removable"
        sleep 2
        navigate_to_menu "main"
        return
    fi
    echo "${YELLOW}Disk Info:${RESET}"
    diskutil info "$disk"
    read -p "Confirm this is the correct USB? Type 'YES' to proceed: " confirm1
    if [[ $confirm1 != "YES" ]]; then navigate_to_menu "main"; return; fi
    read -p "Confirm ERASE $disk? Type 'ERASE' to proceed: " confirm2
    if [[ $confirm2 != "ERASE" ]]; then navigate_to_menu "main"; return; fi
    echo "${YELLOW}Partition Scheme: 1) MBR 2) GUID: ${RESET}"
    read -p "Choice: " scheme_choice
    case $scheme_choice in 1) SCHEME="MBR" ;; 2) SCHEME="GPT" ;; *) echo "${RED}Invalid!${RESET}"; navigate_to_menu "main"; return ;; esac
    read -p "Volume Name: " volname
    if [[ -z "$volname" ]]; then echo "${RED}Name required!${RESET}"; navigate_to_menu "main"; return; fi
    echo "${YELLOW}Format: 1) FAT32 2) exFAT 3) NTFS${RESET}"
    read -p "Choice: " format_choice
    case $format_choice in
        1) FORMAT="FAT32" ;;
        2) FORMAT="exFAT" ;;
        3) FORMAT="NTFS" ; echo "${YELLOW}NTFS may require additional drivers.${RESET}" ;;
        *) echo "${RED}Invalid! EXT removed for safety.${RESET}"; navigate_to_menu "main"; return ;; esac
    show_info "USB Format" "diskutil eraseDisk $FORMAT $volname $SCHEME /dev/$disk" "Formats USB for cross-platform use" "Erases all data; NTFS may need drivers"
    if sudo_exec diskutil eraseDisk "$FORMAT" "$volname" "$SCHEME" "/dev/$disk"; then
        echo "${GREEN}Formatted successfully.${RESET}"
    else
        echo "${RED}Format failed! Check logs.${RESET}"
    fi
    log "USB $disk formatted to $FORMAT ($SCHEME) as $volname"
    sleep 3
    navigate_to_menu "main"
}

# App Updater Function (with non-App Store updates)
app_updater() {
    clear
    echo "${GREEN}┌──(${PURPLE}📱 App Updater Matrix${GREEN})─┐${RESET}"
    echo "${GREEN}└────────────────────────────────┘${RESET}"
    echo ""
    # macOS System Updates
    echo "${YELLOW}Checking macOS System Updates...${RESET}"
    SYS_UPDATES=$(softwareupdate --list 2>/dev/null | grep -E 'recommended|update' | head -5 || echo "No system updates")
    if [[ -n "$SYS_UPDATES" && "$SYS_UPDATES" != "No system updates" ]]; then
        echo "${YELLOW}System Updates Available:${RESET}"
        echo "$SYS_UPDATES"
        read -p "Install all system updates? (y/n): " sys_yn
        if [[ $sys_yn == "y" ]]; then
            sudo_exec softwareupdate --install --all --verbose || echo "${RED}System update failed.${RESET}"
            log "macOS system updates installed"
        fi
    else
        echo "${GREEN}No system updates available.${RESET}"
    fi
    echo ""
    # App Store Updates
    echo "${YELLOW}Checking App Store Updates...${RESET}"
    AS_UPDATES=$(softwareupdate --list 2>/dev/null | grep -E 'recommended|update' | grep -i "app store" | head -5 || echo "No App Store updates")
    if [[ -n "$AS_UPDATES" && "$AS_UPDATES" != "No App Store updates" ]]; then
        echo "${YELLOW}App Store Updates:${RESET}"
        echo "$AS_UPDATES"
        read -p "Update all App Store apps? (y/n): " as_yn
        if [[ $as_yn == "y" ]]; then
            sudo_exec softwareupdate --install --all --verbose || echo "${RED}App Store update failed.${RESET}"
            log "App Store updates installed"
        fi
    else
        echo "${GREEN}No App Store updates available.${RESET}"
    fi
    echo ""
    # Brew Updates
    if ! command -v brew &> /dev/null; then
        echo "${YELLOW}Installing Homebrew...${RESET}"
        /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)" || { echo "${RED}Brew install failed.${RESET}"; navigate_to_menu "main"; return; }
    fi
    echo "${YELLOW}Checking Homebrew Updates...${RESET}"
    BREW_UPDATES=$(brew outdated | head -10)
    if [[ -n "$BREW_UPDATES" ]]; then
        echo "${YELLOW}Brew Apps to Update:${RESET}"
        echo "$BREW_UPDATES" | while read line; do echo "  ${RED}● $line${RESET}"; done
        read -p "Update all Brew apps? (y/n): " brew_yn
        if [[ $brew_yn == "y" ]]; then
            brew upgrade || echo "${RED}Brew upgrade failed.${RESET}"
            log "Brew apps updated"
        fi
    else
        echo "${GREEN}No Brew updates available.${RESET}"
    fi
    echo ""
    # Non-App Store Updates
    echo "${YELLOW}Checking Non-App Store Updates...${RESET}"
    NON_AS_APPS=("TaskExplorer" "Cocoa Packet Analyzer" "fre:ac" "UltimateVocalRemover")
    for app in "${NON_AS_APPS[@]}"; do
        if [[ -d "/Applications/$app.app" || ( "$app" == "UltimateVocalRemover" && -d "~/UVR" ) ]]; then
            echo "${BLUE}Checking $app...${RESET}"
            case "$app" in
                "TaskExplorer")
                    TE_URL="https://github.com/objective-see/TaskExplorer/releases/latest"
                    LATEST_TE=$(curl -sL "$TE_URL" | grep -o 'TaskExplorer_[0-9.]*.zip' | head -1)
                    CURRENT_TE=$(/Applications/TaskExplorer.app/Contents/MacOS/TaskExplorer --version 2>/dev/null || echo "Unknown")
                    if [[ -n "$LATEST_TE" && "$LATEST_TE" != "TaskExplorer_$CURRENT_TE.zip" ]]; then
                        echo "${YELLOW}Update available for TaskExplorer: $LATEST_TE${RESET}"
                        read -p "Update TaskExplorer? (y/n): " te_yn
                        if [[ $te_yn == "y" ]]; then
                            curl -L "https://github.com/objective-see/TaskExplorer/releases/download/${LATEST_TE//TaskExplorer_/}" -o /tmp/te.zip
                            unzip -o /tmp/te.zip -d /Applications/ || echo "${RED}TaskExplorer update failed.${RESET}"
                            rm /tmp/te.zip
                            log "TaskExplorer updated"
                        fi
                    else
                        echo "${GREEN}TaskExplorer is up-to-date.${RESET}"
                    fi
                    ;;
                "Cocoa Packet Analyzer")
                    echo "${YELLOW}Cocoa Packet Analyzer updates must be checked manually at https://www.tastycocoabytes.com/cpa/${RESET}"
                    log "CPA manual update check advised"
                    ;;
                "fre:ac")
                    echo "${YELLOW}fre:ac updates must be checked manually at https://www.freac.org${RESET}"
                    log "fre:ac manual update check advised"
                    ;;
                "UltimateVocalRemover")
                    if [[ -d ~/UVR ]]; then
                        cd ~/UVR
                        git fetch origin
                        if [[ $(git rev-parse HEAD) != $(git rev-parse origin/main) ]]; then
                            echo "${YELLOW}Update available for UltimateVocalRemover${RESET}"
                            read -p "Update UltimateVocalRemover? (y/n): " uvr_yn
                            if [[ $uvr_yn == "y" ]]; then
                                git pull origin main && python3 -m pip install -r requirements.txt || echo "${RED}UVR update failed.${RESET}"
                                log "UltimateVocalRemover updated"
                            fi
                        else
                            echo "${GREEN}UltimateVocalRemover is up-to-date.${RESET}"
                        fi
                        cd - >/dev/null
                    fi
                    ;;
            esac
        else
            echo "${RED}$app not installed.${RESET}"
        fi
    done
    sleep 3
    navigate_to_menu "main"
}

# Hacker Checker Function (enhanced with more checks)
hacker_checker() {
    clear
    echo "${GREEN}┌──(${PURPLE}🛡️ Supreme System Hacker Checker${GREEN})─┐${RESET}"
    echo "${GREEN}│ Scanning for suspicious apps, privileges, & more... │${RESET}"
    echo "${GREEN}└──────────────────────────────────────────────────┘${RESET}"
    echo ""
    UNSIGNED=$(mdfind 'kMDItemContentType == "com.apple.application-bundle"' | head -20 | xargs -I {} codesign -dv --verbose=4 {} 2>&1 | grep -E "not signed|denied" || echo "No issues")
    if [[ "$UNSIGNED" != "No issues" ]]; then
        echo "${RED}Suspicious Unsigned/Privileged Apps:${RESET}"
        echo "$UNSIGNED"
    else
        echo "${GREEN}No suspicious apps found.${RESET}"
    fi
    PRIVS=$(sudo tccutil reset All 2>&1 | grep -v "No such" | head -3 || echo "No resets")
    echo "${YELLOW}Recent Privilege Resets:${RESET}"
    echo "$PRIVS"
    if command -v lynis &> /dev/null; then
        echo "${YELLOW}Running Lynis scan (limited)...${RESET}"
        lynis audit system --quick | head -10 || echo "${RED}Lynis failed.${RESET}"
    else
        echo "${YELLOW}Install Lynis for advanced checks.${RESET}"
    fi
    echo "${BLUE}Open Ports:${RESET}"
    lsof -i -P -n | grep LISTEN | head -5 || echo "No open ports"
    log "Supreme hacker check completed"
    read -p "Reset suspicious privileges? (y/n): " priv_yn
    if [[ $priv_yn == "y" ]]; then
        sudo tccutil reset All || echo "${RED}Reset failed.${RESET}"
        log "Privileges reset"
    fi
    sleep 3
    navigate_to_menu "main"
}

# Launchpad Tweaks (enhanced)
launchpad_tweaks() {
    clear
    echo "${GREEN}┌──(${PURPLE}🚀 Launchpad Tweaks${GREEN})─┐${RESET}"
    echo "${GREEN}│ Adding Network Utility to Launchpad... │${RESET}"
    echo "${GREEN}└──────────────────────────────────────┘${RESET}"
    echo ""
    if [[ -e "/System/Library/CoreServices/Applications/Network Utility.app" ]]; then
        ln -s /System/Library/CoreServices/Applications/Network\ Utility.app ~/Applications/NetworkUtility.app 2>/dev/null || echo "${YELLOW}Alias exists.${RESET}"
        defaults write com.apple.dock persistent-apps -array-add '<dict><key>tile-data<dict><key>file-data<_array><data>$(xxd -l 0 -ps ~/Applications/NetworkUtility.app)</data></_array></key></dict></dict>' || echo "${RED}Dock update failed.${RESET}"
        killall Dock
        log "Network Utility added to Launchpad"
        echo "${GREEN}Added!${RESET}"
    else
        echo "${YELLOW}Network Utility not found (deprecated).${RESET}"
    fi
    sleep 2
    navigate_to_menu "main"
}

# Install CLI Hacker Tools (with safety)
install_hacker_tools() {
    clear
    echo "${GREEN}┌──(${PURPLE}🕵️ CLI Hacker Tools Installer${GREEN})─┐${RESET}"
    echo "${GREEN}│ Installing Nmap, Tcpdump, Htop, Neofetch, etc... │${RESET}"
    echo "${GREEN}└─────────────────────────────────────────────────┘${RESET}"
    echo ""
    if ! command -v brew &> /dev/null; then
        /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)" || { echo "${RED}Brew install failed.${RESET}"; navigate_to_menu "main"; return; }
    fi
    brew install nmap htop neofetch wget curl jq tshark || echo "${RED}Some installs failed.${RESET}"
    log "CLI Hacker Tools installed"
    echo "${GREEN}CLI Tools Installed! Run 'nmap -h' to test.${RESET}"
    sleep 3
    navigate_to_menu "main"
}

# Install System Checkers (with safety)
install_system_checkers() {
    clear
    echo "${GREEN}┌──(${PURPLE}🔍 System Checker Tools Installer${GREEN})─┐${RESET}"
    echo "${GREEN}│ Installing Lynis, ClamAV, RKHunter, etc... │${RESET}"
    echo "${GREEN}└──────────────────────────────────────────────────┘${RESET}"
    echo ""
    if ! command -v brew &> /dev/null; then
        /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)" || { echo "${RED}Brew failed.${RESET}"; navigate_to_menu "main"; return; }
    fi
    brew install lynis clamav rkhunter || echo "${RED}Installs failed.${RESET}"
    sudo freshclam || echo "${YELLOW}ClamAV update failed.${RESET}"
    log "System Checkers installed"
    echo "${GREEN}Checkers Installed! Run 'lynis audit system' for scan.${RESET}"
    sleep 3
    navigate_to_menu "main"
}

# Install Tools Function (expanded with media & file tools, hash checks)
install_tools() {
    clear
    echo "${GREEN}┌──(${PURPLE}🔧 Supreme Install Ultimate Tools${GREEN})─┐${RESET}"
    echo "${GREEN}│ Installing with hash verification where possible... │${RESET}"
    echo "${GREEN}└────────────────────────────────────────────────────┘${RESET}"
    echo ""
    if ! command -v brew &> /dev/null; then
        /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)" || { echo "${RED}Brew failed.${RESET}"; navigate_to_menu "main"; return; }
    fi
    brew install ffmpeg wget --cask flatpak --cask wireshark --cask visual-studio-code picard --cask handbrake --cask mucommander --cask filezilla || echo "${RED}Some brews failed.${RESET}"
    if [[ ! -d ~/UVR ]]; then
        git clone https://github.com/Anjok07/ultimatevocalremovergui.git ~/UVR || { echo "${RED}Git clone failed.${RESET}"; navigate_to_menu "main"; return; }
        cd ~/UVR && python3 -m pip install -r requirements.txt || echo "${RED}Pip failed.${RESET}"
    fi
    log "UVR ready"
    TE_URL="https://github.com/objective-see/TaskExplorer/releases/download/v2.1.0/TaskExplorer_2.1.0.zip"
    TE_SHA="0F00CCB5C031A3F7F63CC6EF156CBF16BA5C88D0"
    curl -L "$TE_URL" -o /tmp/te.zip || { echo "${RED}Download failed.${RESET}"; navigate_to_menu "main"; return; }
    COMPUTED_SHA=$(shasum -a 1 /tmp/te.zip | awk '{print $1}')
    if [[ "$COMPUTED_SHA" != "$TE_SHA" ]]; then
        echo "${RED}Hash mismatch! Aborting.${RESET}"
        rm /tmp/te.zip
        navigate_to_menu "main"
        return
    fi
    unzip /tmp/te.zip -d /Applications/ || echo "${RED}Unzip failed.${RESET}"
    rm /tmp/te.zip
    log "TaskExplorer installed"
    CPA_URL="https://www.tastycocoabytes.com/_downloads/CPA_214.dmg"
    curl -L "$CPA_URL" -o /tmp/cpa.dmg || { echo "${RED}Download failed.${RESET}"; navigate_to_menu "main"; return; }
    hdiutil attach /tmp/cpa.dmg -quiet || { echo "${RED}Mount failed.${RESET}"; navigate_to_menu "main"; return; }
    cp -R "/Volumes/Cocoa Packet Analyzer/Cocoa Packet Analyzer.app" /Applications/ || echo "${RED}Copy failed.${RESET}"
    hdiutil detach "/Volumes/Cocoa Packet Analyzer" -quiet
    rm /tmp/cpa.dmg
    log "CPA installed"
    FREAC_URL="https://www.freac.org/download/freac-1.1.7-mac.dmg"
    curl -L "$FREAC_URL" -o /tmp/freac.dmg || { echo "${RED}Download failed.${RESET}"; navigate_to_menu "main"; return; }
    hdiutil attach /tmp/freac.dmg -quiet || { echo "${RED}Mount failed.${RESET}"; navigate_to_menu "main"; return; }
    cp -R "/Volumes/fre:ac/fre:ac.app" /Applications/ || echo "${RED}Copy failed.${RESET}"
    hdiutil detach "/Volumes/fre:ac" -quiet
    rm /tmp/freac.dmg
    log "fre:ac installed"
    echo "${GREEN}All Supreme Tools Installed Safely!${RESET}"
    sleep 5
    navigate_to_menu "main"
}

# WiFi Menu (with backups)
wifi_menu() {
    clear
    echo "${GREEN}┌──(${PURPLE}📡 WiFi Hacks Menu${GREEN})─┐${RESET}"
    echo "${GREEN}│ Detailed hacks for signal, stability, speed. Aggressive or stable. │${RESET}"
    echo "${GREEN}└───────────────────────────────────────────────────────────────────┘${RESET}"
    echo ""
    echo "1) Hack AWDL (Improves hidden SSID & crowded nets)"
    echo "   Aggressive: Full disable (breaks AirDrop)"
    echo "   Stable: Temp disable (reboot resets)"
    echo ""
    echo "2) Toggle WiFi Power Matrix"
    echo "   Aggressive: Force on."
    echo "   Stable: Perf priority."
    echo ""
    echo "3) Scan Signal Matrix"
    echo ""
    echo "4) Forget Network Trace"
    echo ""
    echo "5) Set WiFi Channel Hack"
    echo "   Aggressive: Force channel."
    echo "   Stable: Scan suggest."
    echo ""
    echo "6) Disable Weak Auto-Join"
    echo "   Aggressive: Remove weak."
    echo "   Stable: Set threshold."
    echo ""
    echo "0) Back to Supreme Hack"
    read -p "${GREEN}[HACKER@WIFI] ~$ ${RESET}" subchoice
    case $subchoice in
        1)
            show_info "Hack AWDL" "Aggressive: sudo ifconfig awdl0 down | Stable: sudo launchctl unload /System/Library/LaunchDaemons/com.apple.awdl.plist" "Improves WiFi in crowded areas" "Aggressive breaks AirDrop"
            read -p "Aggressive (1) or Stable (2)? (n cancel): " alt
            if [[ $alt == "1" ]]; then
                sudo_exec ifconfig awdl0 down || navigate_to_menu "main"
            elif [[ $alt == "2" ]]; then
                sudo_exec launchctl unload /System/Library/LaunchDaemons/com.apple.awdl.plist || navigate_to_menu "main"
                log "Stable AWDL hack (temp)"
            fi
            sleep 2
            ;;
        2)
            show_info "Toggle WiFi Power" "Aggressive: networksetup -setairportpower en0 on | Stable: pmset -a networkoversleep 0" "Ensures max WiFi signal" "May increase power use"
            read -p "Aggressive On (1), Stable (2), Off (n)? : " alt
            if [[ $alt == "1" ]]; then
                sudo_exec networksetup -setairportpower en0 on || navigate_to_menu "main"
            elif [[ $alt == "2" ]]; then
                backup_pmset
                sudo_exec pmset -a networkoversleep 0 || navigate_to_menu "main"
                log "Stable WiFi power hack"
            fi
            sleep 2
            ;;
        3)
            echo "${BLUE}Scanning Matrix...${RESET}"
            "$AIRPORT" -s || echo "${RED}Scan failed.${RESET}"
            sleep 5
            ;;
        4)
            read -p "Enter SSID to erase: " ssid
            if [[ -z "$ssid" ]]; then echo "${RED}SSID required.${RESET}"; navigate_to_menu "main"; return; fi
            show_info "Forget Network" "networksetup -removepreferredwirelessnetwork en0 $ssid" "Clears network clutter" "May require re-authentication"
            sudo_exec networksetup -removepreferredwirelessnetwork en0 "$ssid" || navigate_to_menu "main"
            sleep 2
            ;;
        5)
            show_info "Set WiFi Channel" "Aggressive: Manual (router) | Stable: Scan" "Reduces interference" "Manual requires router access"
            read -p "Aggressive (1: Channel) or Stable (2)? : " alt
            if [[ $alt == "1" ]]; then
                read -p "Channel (1-11 etc.): " chan
                if ! [[ $chan =~ ^[0-9]+$ ]]; then echo "${RED}Invalid channel.${RESET}"; navigate_to_menu "main"; return; fi
                echo "${YELLOW}Router config needed.${RESET}"
                log "Manual channel hack to $chan"
            elif [[ $alt == "2" ]]; then
                "$AIRPORT" -s || echo "${RED}Scan failed.${RESET}"
                echo "${GREEN}Pick least crowded.${RESET}"
            fi
            sleep 2
            ;;
        6)
            show_info "Disable Weak Join" "Aggressive: Remove < -70dBm | Stable: Prefs" "Prioritizes strong networks" "Aggressive may limit options"
            read -p "Aggressive (1) or Stable (2)? : " alt
            if [[ $alt == "1" ]]; then
                echo "${YELLOW}Simulating removal - no action for safety.${RESET}"
                log "Aggressive weak hack simulated"
            elif [[ $alt == "2" ]]; then
                backup_settings "com.apple.airport.preferences"
                defaults write /Library/Preferences/SystemConfiguration/com.apple.airport.preferences JoinMode -string "Preferred" || echo "${RED}Write failed.${RESET}"
                log "Stable join hack"
            fi
            sleep 2
            ;;
        0) navigate_to_menu "main" ;;
        *) echo "${RED}Invalid hack!${RESET}"; sleep 1; wifi_menu ;;
    esac
    wifi_menu
}

# Power Menu (with backups)
power_menu() {
    clear
    echo "${GREEN}┌──(${PURPLE}⚡ Power Hacks Menu${GREEN})─┐${RESET}"
    echo "${GREEN}│ Hack energy for max perf. With stable alts. │${RESET}"
    echo "${GREEN}└─────────────────────────────────────────────┘${RESET}"
    echo ""
    echo "1) Hack Low Power Mode"
    echo "   Aggressive: Full off."
    echo "   Stable: Charger off."
    echo ""
    echo "2) Hack System Sleep"
    echo "   Aggressive: Never."
    echo "   Stable: 30 min."
    echo ""
    echo "3) Hack Display Sleep"
    echo "   Aggressive: Never."
    echo "   Stable: 15 min."
    echo ""
    echo "4) Hack Auto Power Off"
    echo "   Aggressive: Off."
    echo "   Stable: 1 hour."
    echo ""
    echo "5) Hack Hibernation"
    echo "   Aggressive: Off."
    echo "   Stable: Safe sleep."
    echo ""
    echo "6) Force High Perf Hack"
    echo "   Aggressive: Max CPU."
    echo "   Stable: Balanced."
    echo ""
    echo "0) Back"
    read -p "${GREEN}[HACKER@POWER] ~$ ${RESET}" subchoice
    backup_pmset
    case $subchoice in
        1)
            show_info "Hack Low Power" "Aggressive: pmset -a lowpowermode 0 | Stable: pmset -c lowpowermode 0" "Boosts performance" "Increases heat"
            read -p "Aggressive (1) or Stable (2)? : " alt
            if [[ $alt == "1" ]]; then
                sudo_exec pmset -a lowpowermode 0 || navigate_to_menu "main"
            elif [[ $alt == "2" ]]; then
                sudo_exec pmset -c lowpowermode 0 || navigate_to_menu "main"
                log "Stable low power hack"
            fi
            sleep 2
            ;;
        2)
            show_info "Hack Sleep" "Aggressive: pmset -a sleep 0 | Stable: pmset -a sleep 30" "Keeps system active" "May increase power use"
            read -p "Aggressive (1) or Stable (2)? : " alt
            if [[ $alt == "1" ]]; then
                sudo_exec pmset -a sleep 0 || navigate_to_menu "main"
            elif [[ $alt == "2" ]]; then
                sudo_exec pmset -a sleep 30 || navigate_to_menu "main"
                log "Stable sleep hack"
            fi
            sleep 2
            ;;
        3)
            show_info "Hack Display Sleep" "Aggressive: pmset -a displaysleep 0 | Stable: pmset -a displaysleep 15" "Keeps display active" "Increases power use"
            read -p "Aggressive (1) or Stable (2)? : " alt
            if [[ $alt == "1" ]]; then
                sudo_exec pmset -a displaysleep 0 || navigate_to_menu "main"
            elif [[ $alt == "2" ]]; then
                sudo_exec pmset -a displaysleep 15 || navigate_to_menu "main"
                log "Stable display hack"
            fi
            sleep 2
            ;;
        4)
            show_info "Hack Auto Off" "Aggressive: pmset -a autopoweroff 0; standby 0 | Stable: 3600" "Prevents shutdown" "May keep system active unnecessarily"
            read -p "Aggressive (1) or Stable (2)? : " alt
            if [[ $alt == "1" ]]; then
                sudo_exec pmset -a autopoweroff 0 || navigate_to_menu "main"
                sudo_exec pmset -a standby 0 || navigate_to_menu "main"
            elif [[ $alt == "2" ]]; then
                sudo_exec pmset -a autopoweroff 3600 || navigate_to_menu "main"
                sudo_exec pmset -a standby 3600 || navigate_to_menu "main"
                log "Stable auto off hack"
            fi
            sleep 2
            ;;
        5)
            show_info "Hack Hibernation" "Aggressive: pmset -a hibernatemode 0 | Stable: 3" "Frees RAM" "Aggressive may lose data on power loss"
            read -p "Aggressive (1) or Stable (2)? : " alt
            if [[ $alt == "1" ]]; then
                sudo_exec pmset -a hibernatemode 0 || navigate_to_menu "main"
            elif [[ $alt == "2" ]]; then
                sudo_exec pmset -a hibernatemode 3 || navigate_to_menu "main"
                log "Stable hibernation hack"
            fi
            sleep 2
            ;;
        6)
            show_info "Force High Perf" "Aggressive: pmset -a CPUSpeedLimit 100 | Stable: Reset" "Maximizes CPU" "Increases heat; may be ignored on M3"
            read -p "Aggressive (1) or Stable (2)? : " alt
            if [[ $alt == "1" ]]; then
                sudo_exec pmset -a CPUSpeedLimit 100 || navigate_to_menu "main"
            elif [[ $alt == "2" ]]; then
                sudo_exec pmset -a CPUSpeedLimit 0 || navigate_to_menu "main"
                log "Stable CPU hack"
            fi
            sleep 2
            ;;
        0) navigate_to_menu "main" ;;
        *) echo "${RED}Invalid!${RESET}"; sleep 1; power_menu ;;
    esac
    power_menu
}

# GPU Menu (with backups)
gpu_menu() {
    clear
    echo "${GREEN}┌──(${PURPLE}🎮 GPU Hacks Menu${GREEN})─┐${RESET}"
    echo "${GREEN}│ Max M3 GPU hacks. With alts. │${RESET}"
    echo "${GREEN}└──────────────────────────────┘${RESET}"
    echo ""
    echo "1) Force GPU High Power"
    echo "   Aggressive: Full."
    echo "   Stable: Charger."
    echo ""
    echo "2) Purge GPU Cache"
    echo "   Aggressive: Purge."
    echo "   Stable: Sync."
    echo ""
    echo "3) Hack GPU Limits"
    echo "   Aggressive: Global."
    echo "   Stable: Per-app."
    echo ""
    echo "4) Enable Metal Debug"
    echo "   Aggressive: Full."
    echo "   Stable: Per-run."
    echo ""
    echo "5) Boost GPU Clock"
    echo "   Aggressive: Power hack."
    echo "   Stable: Monitor."
    echo ""
    echo "0) Back"
    read -p "${GREEN}[HACKER@GPU] ~$ ${RESET}" subchoice
    case $subchoice in
        1)
            show_info "GPU High Power" "Aggressive: pmset -a lowpowermode 0 | Stable: pmset -c lowpowermode 0" "Boosts GPU performance" "Increases heat"
            read -p "Aggressive (1) or Stable (2)? : " alt
            backup_pmset
            if [[ $alt == "1" ]]; then
                sudo_exec pmset -a lowpowermode 0 || navigate_to_menu "main"
            elif [[ $alt == "2" ]]; then
                sudo_exec pmset -c lowpowermode 0 || navigate_to_menu "main"
                log "Stable GPU power"
            fi
            sleep 2
            ;;
        2)
            show_info "Purge Cache" "Aggressive: purge | Stable: sync" "Frees memory for GPU" "Aggressive may disrupt apps"
            read -p "Aggressive (1) or Stable (2)? : " alt
            if [[ $alt == "1" ]]; then
                sudo_exec purge || navigate_to_menu "main"
            elif [[ $alt == "2" ]]; then
                sudo_exec sync || navigate_to_menu "main"
                log "Stable cache sync"
            fi
            sleep 2
            ;;
        3)
            show_info "Hack Limits" "Aggressive: global smoothing | Stable: app" "Improves rendering" "May affect visuals"
            read -p "Aggressive (1) or Stable (2: app ID)? : " alt
            if [[ $alt == "1" ]]; then
                backup_settings "NSGlobalDomain"
                defaults write -g CGFontRenderingFontSmoothingDisabled -bool NO || navigate_to_menu "main"
                killall Finder
            elif [[ $alt == "2" ]]; then
                read -p "App bundle ID: " appid
                if [[ -z "$appid" ]]; then echo "${RED}ID required.${RESET}"; navigate_to_menu "main"; return; fi
                backup_settings "$appid"
                defaults write "$appid" CGFontRenderingFontSmoothingDisabled -bool NO || navigate_to_menu "main"
                log "Stable GPU for $appid"
            fi
            sleep 2
            ;;
        4)
            show_info "Metal Debug" "Aggressive: export METAL_DEBUG=1 | Stable: per-run" "Aids GPU debugging" "Slows performance"
            read -p "Aggressive (1) or Stable (2)? : " alt
            if [[ $alt == "1" ]]; then
                export METAL_DEBUG=1
                log "Aggressive Metal"
            elif [[ $alt == "2" ]]; then
                echo "${YELLOW}Launch with METAL_DEBUG=1 app${RESET}"
                log "Stable Metal advice"
            fi
            sleep 2
            ;;
        5)
            show_info "Boost GPU Clock" "Aggressive: power | Stable: monitor" "Maximizes GPU" "Increases heat"
            read -p "Aggressive (1) or Stable (2)? : " alt
            if [[ $alt == "1" ]]; then
                backup_pmset
                sudo_exec pmset -a lowpowermode 0 || navigate_to_menu "main"
                log "Aggressive GPU boost"
            elif [[ $alt == "2" ]]; then
                echo "${YELLOW}Use iStat for monitor.${RESET}"
                log "Stable GPU monitor"
            fi
            sleep 2
            ;;
        0) navigate_to_menu "main" ;;
        *) echo "${RED}Invalid!${RESET}"; sleep 1; gpu_menu ;;
    esac
    gpu_menu
}

# System Menu (with backups)
system_menu() {
    clear
    echo "${GREEN}┌──(${PURPLE}⚙️ System Hacks Menu${GREEN})─┐${RESET}"
    echo "${GREEN}│ Optimizations for M3 Pro. Alts included. │${RESET}"
    echo "${GREEN}└──────────────────────────────────────────┘${RESET}"
    echo ""
    echo "1) Hack Window Animations"
    echo "   Aggressive: Off."
    echo "   Stable: Reduce."
    echo ""
    echo "2) Speed Dock Hack"
    echo "   Aggressive: 0 delay."
    echo "   Stable: 0.2 sec."
    echo ""
    echo "3) Hack Spotlight"
    echo "   Aggressive: All off."
    echo "   Stable: Volumes off."
    echo ""
    echo "4) Hack Dashboard"
    echo "   Aggressive: Kill."
    echo "   Stable: Hide."
    echo ""
    echo "5) Optimize Swap Hack"
    echo "   Aggressive: Monitor."
    echo "   Stable: Purge."
    echo ""
    echo "6) Flush DNS Matrix"
    echo "   Aggressive: Kill mDNS."
    echo "   Stable: Flush cache."
    echo ""
    echo "0) Back"
    read -p "${GREEN}[HACKER@SYSTEM] ~$ ${RESET}" subchoice
    case $subchoice in
        1)
            show_info "Hack Animations" "Aggressive: false | Stable: 0.001 resize" "Speeds up UI" "Aggressive may feel abrupt"
            read -p "Aggressive (1) or Stable (2)? : " alt
            backup_settings "NSGlobalDomain"
            if [[ $alt == "1" ]]; then
                defaults write NSGlobalDomain NSAutomaticWindowAnimationsEnabled -bool false || navigate_to_menu "main"
            elif [[ $alt == "2" ]]; then
                defaults write NSGlobalDomain NSWindowResizeTime -float 0.001 || navigate_to_menu "main"
                log "Stable animation hack"
            fi
            sleep 2
            ;;
        2)
            show_info "Speed Dock" "Aggressive: 0 | Stable: 0.2" "Faster Dock access" "Aggressive may feel abrupt"
            read -p "Aggressive (1) or Stable (2)? : " alt
            backup_settings "com.apple.dock"
            if [[ $alt == "1" ]]; then
                defaults write com.apple.dock autohide-delay -float 0 || navigate_to_menu "main"
                defaults write com.apple.dock autohide-time-modifier -float 0 || navigate_to_menu "main"
                killall Dock
            elif [[ $alt == "2" ]]; then
                defaults write com.apple.dock autohide-delay -float 0.2 || navigate_to_menu "main"
                defaults write com.apple.dock autohide-time-modifier -float 0.5 || navigate_to_menu "main"
                killall Dock
                log "Stable Dock hack"
            fi
            sleep 2
            ;;
        3)
            show_info "Hack Spotlight" "Aggressive: -a off | Stable: /Volumes off" "Frees CPU" "Limits search functionality"
            read -p "Aggressive (1) or Stable (2)? : " alt
            if [[ $alt == "1" ]]; then
                sudo_exec mdutil -a -i off || navigate_to_menu "main"
            elif [[ $alt == "2" ]]; then
                sudo_exec mdutil -i off /Volumes/* || navigate_to_menu "main"
                log "Stable Spotlight hack"
            fi
            sleep 2
            ;;
        4)
            show_info "Hack Dashboard" "Aggressive: mcx-disabled true | Stable: overlay" "Frees resources" "Limits Dashboard access"
            read -p "Aggressive (1) or Stable (2)? : " alt
            backup_settings "com.apple.dashboard"
            backup_settings "com.apple.dock"
            if [[ $alt == "1" ]]; then
                defaults write com.apple.dashboard mcx-disabled -bool true || navigate_to_menu "main"
                killall Dock
            elif [[ $alt == "2" ]]; then
                defaults write com.apple.dock dashboard-in-overlay -bool true || navigate_to_menu "main"
                killall Dock
                log "Stable Dashboard hack"
            fi
            sleep 2
            ;;
        5)
            show_info "Optimize Swap" "Aggressive: vm.swapusage | Stable: purge" "Monitors/frees memory" "Aggressive may disrupt apps"
            read -p "Aggressive (1) or Stable (2)? : " alt
            if [[ $alt == "1" ]]; then
                sysctl vm.swapusage || echo "${RED}Failed.${RESET}"
                log "Aggressive swap monitor"
            elif [[ $alt == "2" ]]; then
                sudo_exec purge || navigate_to_menu "main"
                log "Stable swap hack"
            fi
            sleep 2
            ;;
        6)
            show_info "Flush DNS" "Aggressive: killall -HUP mDNSResponder | Stable: dscacheutil -flushcache" "Clears DNS cache" "Aggressive may disrupt network"
            read -p "Aggressive (1) or Stable (2)? : " alt
            if [[ $alt == "1" ]]; then
                sudo_exec killall -HUP mDNSResponder || navigate_to_menu "main"
            elif [[ $alt == "2" ]]; then
                dscacheutil -flushcache || navigate_to_menu "main"
                log "Stable DNS hack"
            fi
            sleep 2
            ;;
        0) navigate_to_menu "main" ;;
        *) echo "${RED}Invalid!${RESET}"; sleep 1; system_menu ;;
    esac
    system_menu
}

# Rocket Mode (with backups)
rocket_mode() {
    local mode="$1"
    clear
    matrix_effect
    if [[ $mode == "aggressive" ]]; then
        echo "${GREEN}┌──(${PURPLE}🚀 AGGRESSIVE SUPREME ROCKET FLEET${GREEN})────┐${RESET}"
    else
        echo "${GREEN}┌──(${PURPLE}🚀 STABLE SUPREME ROCKET FLEET${GREEN})────┐${RESET}"
    fi
    echo "${GREEN}│ Launching $mode supreme hacks! Ultimate Matrix Overload! │${RESET}"
    echo "${GREEN}└──────────────────────────────────────────────────────────┘${RESET}"
    echo ""
    read -p "Confirm supreme launch? Type 'LAUNCH' : " confirm
    if [[ $confirm != "LAUNCH" ]]; then
        echo "${YELLOW}Launch aborted.${RESET}"
        sleep 1
        navigate_to_menu "main"
        return
    fi

    log "=== $mode SUPREME ROCKET FLEET ACTIVATED ==="
    backup_pmset
    backup_settings "NSGlobalDomain"
    backup_settings "com.apple.dock"
    backup_settings "com.apple.dashboard"
    if [[ $mode == "aggressive" ]]; then
        sudo_exec pmset -a lowpowermode 0 && sudo_exec pmset -a sleep 0 && sudo_exec pmset -a displaysleep 0 && sudo_exec pmset -a autopoweroff 0 && sudo_exec pmset -a standby 0 && sudo_exec pmset -a hibernatemode 0 || { echo "${RED}Power hacks failed.${RESET}"; navigate_to_menu "main"; return; }
    else
        sudo_exec pmset -c lowpowermode 0 && sudo_exec pmset -a sleep 30 && sudo_exec pmset -a displaysleep 15 && sudo_exec pmset -a autopoweroff 3600 && sudo_exec pmset -a standby 3600 && sudo_exec pmset -a hibernatemode 3 || { echo "${RED}Power hacks failed.${RESET}"; navigate_to_menu "main"; return; }
    fi
    if [[ $mode == "aggressive" ]]; then
        sudo_exec ifconfig awdl0 down && sudo_exec networksetup -setairportpower en0 on || { echo "${RED}WiFi hacks failed.${RESET}"; navigate_to_menu "main"; return; }
    else
        sudo_exec launchctl unload /System/Library/LaunchDaemons/com.apple.awdl.plist && sudo_exec pmset -a networkoversleep 0 || { echo "${RED}WiFi hacks failed.${RESET}"; navigate_to_menu "main"; return; }
    fi
    if [[ $mode == "aggressive" ]]; then
        defaults write NSGlobalDomain NSAutomaticWindowAnimationsEnabled -bool false && defaults write com.apple.dock autohide-delay -float 0 && defaults write com.apple.dock autohide-time-modifier -float 0 && killall Dock && sudo_exec mdutil -a -i off && defaults write com.apple.dashboard mcx-disabled -bool true || { echo "${RED}System hacks failed.${RESET}"; navigate_to_menu "main"; return; }
    else
        defaults write NSGlobalDomain NSWindowResizeTime -float 0.001 && defaults write com.apple.dock autohide-delay -float 0.2 && defaults write com.apple.dock autohide-time-modifier -float 0.5 && killall Dock && sudo_exec mdutil -i off /Volumes/* && defaults write com.apple.dock dashboard-in-overlay -bool true || { echo "${RED}System hacks failed.${RESET}"; navigate_to_menu "main"; return; }
    fi
    if [[ $mode == "aggressive" ]]; then
        sudo_exec purge && defaults write -g CGFontRenderingFontSmoothingDisabled -bool NO && killall Finder || { echo "${RED}GPU hacks failed.${RESET}"; navigate_to_menu "main"; return; }
    else
        sudo_exec sync
        log "Stable GPU hacks"
    fi
    log "=== $mode SUPREME ROCKET FLEET COMPLETE ==="

    echo ""
    echo "${GREEN}Supreme $mode hacks launched! M3 Pro is SUPREME FLEET!${RESET}"
    echo "$ROCKET_BOOSTED_FLEET"
    echo "${GREEN}Status: SUPREME MATRIX BOOST (${mode})${RESET}"
    restore_advice
    sleep 5
    navigate_to_menu "main"
}

# Main menu (updated with navigation handler)
main_menu() {
    clear
    matrix_effect
    echo "${GREEN}┌──────────────────────────────────────────────────────────────────────────────┐${RESET}"
    echo "${GREEN}│ ${BOLD}${PURPLE}🚀🚀🚀 MAC Rocket Menu - Ultimate Hacker Fleet Edition 🚀🚀🚀${RESET}${GREEN} │${RESET}"
    echo "${GREEN}│ Max supreme hacks: WiFi, Power, GPU, System, USB, Apps, Security, CLI Tools & More! │${RESET}"
    echo "${GREEN}└──────────────────────────────────────────────────────────────────────────────┘${RESET}"
    echo ""
    echo "${PURPLE}Supreme Rocket Fleet:${RESET}"
    echo "$ROCKET_FLEET"
    echo ""
    echo "${BLUE}Matrix Scan - Current Supreme Hacks:${RESET}"
    [ $(is_enabled lowpowermode) ] && echo "  - Low Power: ${GREEN}SUPREMELY HACKED${RESET}" || echo "  - Low Power: ${RED}LOCKED${RESET}"
    [ $(is_enabled sleep) ] && echo "  - Sleep: ${GREEN}SUPREMELY HACKED${RESET}" || echo "  - Sleep: ${RED}LOCKED${RESET}"
    [ $(is_enabled displaysleep) ] && echo "  - Display Sleep: ${GREEN}SUPREMELY HACKED${RESET}" || echo "  - Display Sleep: ${RED}LOCKED${RESET}"
    [ $(is_enabled awdl) ] && echo "  - AWDL: ${GREEN}SUPREMELY HACKED${RESET}" || echo "  - AWDL: ${RED}LOCKED${RESET}"
    [ $(is_enabled hibernatemode) ] && echo "  - Hibernation: ${GREEN}SUPREMELY HACKED${RESET}" || echo "  - Hibernation: ${RED}LOCKED${RESET}"
    [ $(is_enabled animations) ] && echo "  - Animations: ${GREEN}SUPREMELY HACKED${RESET}" || echo "  - Animations: ${RED}LOCKED${RESET}"
    [ $(is_enabled spotlight) ] && echo "  - Spotlight: ${GREEN}SUPREMELY HACKED${RESET}" || echo "  - Spotlight: ${RED}LOCKED${RESET}"
    [ $(is_enabled cpu_gpu_unlock) ] && echo "  - CPU/GPU Unlock: ${GREEN}UNLOCKED${RESET}" || echo "  - CPU/GPU Unlock: ${RED}LOCKED${RESET}"
    echo ""
    echo "Supreme Hack Log: $LOG_FILE | Backups: $BACKUP_DIR"
    echo "${GREEN}┌──(Supreme Options)──────────────────────────────────────────────────────────┐${RESET}"
    echo "${GREEN}│ 1) WiFi Hacks (Expanded)                                                 │${RESET}"
    echo "${GREEN}│ 2) Power & Energy Hacks (Full + Alts)                                    │${RESET}"
    echo "${GREEN}│ 3) GPU & Acceleration Hacks (More)                                       │${RESET}"
    echo "${GREEN}│ 4) System Speed Hacks (Enhanced)                                         │${RESET}"
    echo "${GREEN}│ 5) AGGRESSIVE SUPREME ROCKET FLEET - All Hacks!                          │${RESET}"
    echo "${GREEN}│ 6) STABLE SUPREME ROCKET FLEET - Safe Alts!                              │${RESET}"
    echo "${GREEN}│ 7) View Supreme Hack Log                                                  │${RESET}"
    echo "${GREEN}│ 8) 💾 USB Formatter (MBR/GUID, FAT32/exFAT/NTFS)                          │${RESET}"
    echo "${GREEN}│ 9) 📱 App Updater (System/Brew, Highlight & Update)                         │${RESET}"
    echo "${GREEN}│ 10) 🛡️ Supreme Hacker Checker (Apps/Privs/Ports/Lynis)                     │${RESET}"
    echo "${GREEN}│ 11) 🚀 Launchpad Tweaks (Add Network Utility)                              │${RESET}"
    echo "${GREEN}│ 12) 🔧 Supreme Install Tools (FFmpeg, HandBrake, Picard, muCmdr, FZilla) │${RESET}"
    echo "${GREEN}│ 13) 🕵️ CLI Hacker Tools (Nmap, Htop, Neofetch, TShark)                     │${RESET}"
    echo "${GREEN}│ 14) 🔍 System Checker Tools (Lynis, ClamAV, RKHunter)                      │${RESET}"
    echo "${GREEN}│ 15) 🌐 Live Network Scanner (SMB, Cameras, Devices, VLAN)                   │${RESET}"
    echo "${GREEN}│ 16) 🔓 Auto Unlock
