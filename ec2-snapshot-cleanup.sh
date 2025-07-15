#!/bin/bash

# Script para deletar snapshots órfãos (não referenciados por nenhuma AMI)
# Uso: ./delete-orphan-snapshots.sh [--dry-run=true|false] [--region <REGIAO>]

DRY_RUN=true
REGION=""

# Parse argumentos opcionais
while [[ $# -gt 0 ]]; do
  case $1 in
    --dry-run=*)
      DRY_RUN="${1#*=}"
      shift
      ;;
    --region)
      REGION="$2"
      shift 2
      ;;
    *)
      shift
      ;;
  esac
done

AWS_REGION_OPT=""
if [ -n "$REGION" ]; then
  AWS_REGION_OPT="--region $REGION"
fi

echo -e "🔎 Buscando todos os snapshots referenciados por AMIs..."
echo -e "\n🗂️  Snapshots órfãos encontrados: ${#ORPHANS[@]}"
echo -e "🔎 Buscando todos os snapshots de sua conta..."
ALL_SNAPSHOTS=$(aws ec2 describe-snapshots --owner-ids self --query "Snapshots[*].SnapshotId" --output text $AWS_REGION_OPT | tr '\t' '\n' | sort)

echo -e "🔎 Buscando todos os snapshots referenciados por AMIs..."
USED_SNAPSHOTS=$(aws ec2 describe-images --owners self --query "Images[*].BlockDeviceMappings[*].Ebs.SnapshotId" --output text $AWS_REGION_OPT | tr '\t' '\n' | sort)

# Salva listas em arquivos temporários
TMP_ALL=$(mktemp)
TMP_USED=$(mktemp)
echo -e "$ALL_SNAPSHOTS" > "$TMP_ALL"
echo -e "$USED_SNAPSHOTS" > "$TMP_USED"

# Snapshots órfãos = todos - usados
ORPHANS=$(grep -Fxv -f "$TMP_USED" "$TMP_ALL" | grep -v '^$')
ORPHAN_COUNT=$(echo "$ORPHANS" | grep -c '^' || true)
if [ -z "$ORPHANS" ]; then
  ORPHAN_COUNT=0
fi

echo
echo -e "🗂️  Snapshots órfãos encontrados: $ORPHAN_COUNT"
if [ "$ORPHAN_COUNT" -eq 0 ]; then
  echo -e "✅ Nenhum snapshot órfão encontrado."
  rm -f "$TMP_ALL" "$TMP_USED"
  exit 0
fi
for snap in $ORPHANS; do
  echo " - $snap"
done

if [[ "$DRY_RUN" == "true" ]]; then
  echo -e "\n🧪 Dry-run ativado: Nenhum snapshot será deletado."
else
  echo -e "\n🗑️  Deletando snapshots órfãos..."
  for snap in $ORPHANS; do
    echo "Deletando $snap..."
    aws ec2 delete-snapshot --snapshot-id "$snap" $AWS_REGION_OPT
  done
  echo -e "✅ Snapshots órfãos deletados."
fi

rm -f "$TMP_ALL" "$TMP_USED"
