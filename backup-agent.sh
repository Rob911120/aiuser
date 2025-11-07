#!/bin/bash
#
# AI User Backup Agent
# Zippar, krypterar och laddar upp hela /Users/aiuser till GitHub
#

set -e  # Avsluta vid fel

# Färger för output
GREEN='\033[0;32m'
BLUE='\033[0;34m'
RED='\033[0;31m'
NC='\033[0m' # No Color

# Konfiguration
SOURCE_DIR="/Users/aiuser"
REPO_DIR="/Users/aiuser/aiuser-backup"
BACKUP_NAME="aiuser-backup-$(date +%Y%m%d-%H%M%S)"
TEMP_ZIP="/tmp/${BACKUP_NAME}.tar.gz"
ENCRYPTED_FILE="${REPO_DIR}/${BACKUP_NAME}.tar.gz.enc"

echo -e "${BLUE}🤖 AI User Backup Agent startar...${NC}"
echo ""

# Steg 1: Skapa ZIP-arkiv (exkludera backup-repot själv)
echo -e "${GREEN}📦 Skapar arkiv av /Users/aiuser...${NC}"
tar czf "${TEMP_ZIP}" \
    --exclude="${REPO_DIR}" \
    --exclude="${SOURCE_DIR}/Library/Caches" \
    --exclude="${SOURCE_DIR}/.Trash" \
    -C "$(dirname ${SOURCE_DIR})" \
    "$(basename ${SOURCE_DIR})"

ARCHIVE_SIZE=$(ls -lh "${TEMP_ZIP}" | awk '{print $5}')
echo -e "   ✅ Arkiv skapat: ${ARCHIVE_SIZE}"
echo ""

# Steg 2: Kryptering
echo -e "${GREEN}🔐 Krypterar arkiv...${NC}"
if [ -z "$BACKUP_PASSWORD" ]; then
    echo -e "${BLUE}Ange krypteringslösenord:${NC}"
    openssl enc -aes-256-cbc -pbkdf2 -salt -in "${TEMP_ZIP}" -out "${ENCRYPTED_FILE}"
else
    echo "$BACKUP_PASSWORD" | openssl enc -aes-256-cbc -pbkdf2 -salt -in "${TEMP_ZIP}" -out "${ENCRYPTED_FILE}" -pass stdin
fi

ENCRYPTED_SIZE=$(ls -lh "${ENCRYPTED_FILE}" | awk '{print $5}')
echo -e "   ✅ Krypterad fil: ${ENCRYPTED_SIZE}"
echo ""

# Rensa temporär ZIP
rm -f "${TEMP_ZIP}"

# Steg 3: Git commit och push
echo -e "${GREEN}📤 Laddar upp till GitHub...${NC}"
cd "${REPO_DIR}"

git add "${BACKUP_NAME}.tar.gz.enc"
git commit -m "🤖 AI User Backup: $(date '+%Y-%m-%d %H:%M:%S')

Backup size: ${ENCRYPTED_SIZE}
Encrypted with AES-256-CBC

🤖 Generated with [Claude Code](https://claude.com/claude-code)

Co-Authored-By: Claude <noreply@anthropic.com>"

git push origin main

echo ""
echo -e "${GREEN}✅ Backup komplett!${NC}"
echo -e "${BLUE}📁 Fil: ${BACKUP_NAME}.tar.gz.enc${NC}"
echo -e "${BLUE}📊 Storlek: ${ENCRYPTED_SIZE}${NC}"
echo -e "${BLUE}🔗 GitHub: https://github.com/Rob911120/aiuser${NC}"
echo ""
echo -e "${BLUE}💡 För att återställa:${NC}"
echo -e "   openssl enc -d -aes-256-cbc -pbkdf2 -in ${BACKUP_NAME}.tar.gz.enc | tar xzf -"
echo ""
