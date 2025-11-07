#!/bin/bash
#
# Setup automatiska backups med launchd (macOS)
#

set -e

GREEN='\033[0;32m'
BLUE='\033[0;34m'
RED='\033[0;31m'
NC='\033[0m'

echo -e "${BLUE}🤖 Setup Automatiska Backups${NC}"
echo ""

# Fråga om lösenord
echo -e "${BLUE}Ange krypteringslösenord för automatiska backups:${NC}"
read -s BACKUP_PASSWORD
echo ""

# Fråga om schema
echo -e "${BLUE}Hur ofta vill du köra backups?${NC}"
echo "1) Varje dag kl 02:00"
echo "2) Varje vecka (söndag 02:00)"
echo "3) Vid varje inloggning"
echo "4) Custom cron-schema"
read -p "Välj (1-4): " SCHEDULE_CHOICE

# Skapa launchd plist
PLIST_FILE="$HOME/Library/LaunchAgents/com.aiuser.backup.plist"

case $SCHEDULE_CHOICE in
    1)
        SCHEDULE='<key>StartCalendarInterval</key>
        <dict>
            <key>Hour</key>
            <integer>2</integer>
            <key>Minute</key>
            <integer>0</integer>
        </dict>'
        ;;
    2)
        SCHEDULE='<key>StartCalendarInterval</key>
        <dict>
            <key>Weekday</key>
            <integer>0</integer>
            <key>Hour</key>
            <integer>2</integer>
            <key>Minute</key>
            <integer>0</integer>
        </dict>'
        ;;
    3)
        SCHEDULE='<key>RunAtLoad</key>
        <true/>'
        ;;
    *)
        echo -e "${RED}Custom cron inte implementerat än. Använd manuell crontab.${NC}"
        exit 1
        ;;
esac

cat > "$PLIST_FILE" << EOF
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
    <key>Label</key>
    <string>com.aiuser.backup</string>

    <key>ProgramArguments</key>
    <array>
        <string>/Users/aiuser/aiuser-backup/backup-agent.sh</string>
    </array>

    <key>EnvironmentVariables</key>
    <dict>
        <key>BACKUP_PASSWORD</key>
        <string>${BACKUP_PASSWORD}</string>
    </dict>

    ${SCHEDULE}

    <key>StandardOutPath</key>
    <string>/tmp/aiuser-backup.log</string>

    <key>StandardErrorPath</key>
    <string>/tmp/aiuser-backup-error.log</string>
</dict>
</plist>
EOF

# Ladda launchd agent
launchctl unload "$PLIST_FILE" 2>/dev/null || true
launchctl load "$PLIST_FILE"

echo ""
echo -e "${GREEN}✅ Automatiska backups aktiverade!${NC}"
echo -e "${BLUE}📋 Loggar: /tmp/aiuser-backup.log${NC}"
echo -e "${BLUE}🔄 För att avaktivera: launchctl unload $PLIST_FILE${NC}"
echo ""
