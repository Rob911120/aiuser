# 🤖 AI User Backup Agent

Automatisk backup-agent för hela `/Users/aiuser` miljön. Zippar, krypterar och laddar upp till GitHub.

## 🚀 Snabbstart

### Skapa backup
```bash
./backup-agent.sh
```

Du kommer bli ombedd att ange ett krypteringslösenord. **GLÖM INTE DETTA LÖSENORD!**

### Återställa backup
```bash
./restore-agent.sh
```

Välj backup-fil och destinationskatalog.

## 🔐 Säkerhet

- **Kryptering:** AES-256-CBC med PBKDF2
- **Lösenordsskyddad:** Endast du kan dekryptera backups
- **GitHub:** Säker lagring av krypterade filer

## 📁 Vad backas upp?

- Hela `/Users/aiuser` katalogen
- Exkluderar:
  - `aiuser-backup` repo (själva backup-katalogen)
  - `Library/Caches` (cache-filer)
  - `.Trash` (papperskorgen)

## 🔄 Automatisera backups

### Manuellt
```bash
cd /Users/aiuser/aiuser-backup
./backup-agent.sh
```

### Med cron (daglig backup kl 02:00)
```bash
crontab -e
# Lägg till:
0 2 * * * cd /Users/aiuser/aiuser-backup && BACKUP_PASSWORD='ditt-lösenord' ./backup-agent.sh
```

### Med launchd (rekommenderat på macOS)
Se `setup-auto-backup.sh` för automatisk schemaläggning.

## 📦 Backup-format

```
aiuser-backup-YYYYMMDD-HHMMSS.tar.gz.enc
```

- `.tar.gz` = Komprimerat tar-arkiv
- `.enc` = Krypterat med OpenSSL

## 🛠️ Manuell dekryptering

```bash
openssl enc -d -aes-256-cbc -pbkdf2 -in BACKUP_FIL.tar.gz.enc -out backup.tar.gz
tar xzf backup.tar.gz
```

## 🤖 Genererat med Claude Code

Detta system skapades av Claude Code för att möjliggöra en portabel AI-agent utvecklingsmiljö.

---

**🔗 GitHub:** https://github.com/Rob911120/aiuser
