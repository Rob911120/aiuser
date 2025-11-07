#!/bin/bash
#
# AI User Restore Agent
# Dekrypterar och återställer backup
#

set -e

# Färger för output
GREEN='\033[0;32m'
BLUE='\033[0;34m'
RED='\033[0;31m'
NC='\033[0m'

echo -e "${BLUE}🤖 AI User Restore Agent${NC}"
echo ""

# Lista tillgängliga backups
echo -e "${GREEN}📋 Tillgängliga backups:${NC}"
ls -lh *.tar.gz.enc 2>/dev/null | awk '{print "   " $9 " (" $5 ")"}'
echo ""

# Välj backup
echo -e "${BLUE}Ange backup-filnamn att återställa:${NC}"
read BACKUP_FILE

if [ ! -f "$BACKUP_FILE" ]; then
    echo -e "${RED}❌ Fil hittades inte: $BACKUP_FILE${NC}"
    exit 1
fi

# Välj destination
echo -e "${BLUE}Ange destination (tryck Enter för /Users/aiuser):${NC}"
read RESTORE_DIR
RESTORE_DIR=${RESTORE_DIR:-/Users/aiuser}

echo ""
echo -e "${RED}⚠️  VARNING: Detta kommer skriva över filer i ${RESTORE_DIR}${NC}"
echo -e "${BLUE}Fortsätt? (ja/nej):${NC}"
read CONFIRM

if [ "$CONFIRM" != "ja" ]; then
    echo -e "${RED}❌ Avbruten${NC}"
    exit 0
fi

# Dekryptera och extrahera
echo ""
echo -e "${GREEN}🔓 Dekrypterar och återställer...${NC}"
openssl enc -d -aes-256-cbc -pbkdf2 -in "$BACKUP_FILE" | tar xzf - -C "$(dirname ${RESTORE_DIR})"

echo ""
echo -e "${GREEN}✅ Återställning komplett!${NC}"
echo -e "${BLUE}📁 Destination: ${RESTORE_DIR}${NC}"
echo ""
