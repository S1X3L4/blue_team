#!/bin/bash

#####
#For using this script
#1] subfinder -d <domain> -o <file>
#2] ./check_headers_file.sh <file>
#
#####

#!/bin/bash

if [ -z "$1" ]; then
  echo "Usage: $0 <fichier_domaines>"
  exit 1
fi

FILE="$1"

if [ ! -f "$FILE" ]; then
  echo "Erreur : fichier $FILE introuvable."
  exit 1
fi

while read -r DOMAIN; do
  [[ -z "$DOMAIN" || "$DOMAIN" =~ ^# ]] && continue
  echo "==== $DOMAIN ===="

  HEADERS=$(curl -s -D - -o /dev/null "https://$DOMAIN")

  if [ $? -ne 0 ] || [[ -z "$HEADERS" ]]; then
    echo "❌ Domaine inaccessible ou erreur réseau"
    echo ""
    continue
  fi

  for HEADER in "strict-transport-security" "x-frame-options" "x-xss-protection" \
                "referrer-policy" "x-content-type-options" "x-robots-tag" \
                "content-security-policy" "permissions-policy"; do
    echo -n "$HEADER : "
    echo "$HEADERS" | grep -i "$HEADER" >/dev/null
    if [ $? -eq 0 ]; then
      echo "✅"
    else
      echo "❌"
    fi
  done
  echo ""
done < "$FILE"

