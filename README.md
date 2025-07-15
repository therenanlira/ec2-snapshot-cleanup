# EC2 Snapshot Cleanup

Script Bash para identificar e remover snapshots órfãos (não referenciados por nenhuma AMI) na sua conta AWS.

## Pré-requisitos

- AWS CLI configurado
- Permissões AWS para:
  - `ec2:DescribeSnapshots`
  - `ec2:DescribeImages`
  - `ec2:DeleteSnapshot`

## Uso

```bash
./ec2-snapshot-cleanup.sh [--dry-run=true|false] [--region <REGIAO>]
```

### Parâmetros

- `--dry-run=true` (padrão): Apenas exibe os snapshots órfãos que seriam removidos, sem deletar nada.
- `--dry-run=false`: Remove os snapshots órfãos encontrados.
- `--region <REGIAO>`: Especifica a região AWS (opcional, usa a região padrão do AWS CLI se não especificada).

### Exemplos

```bash
# Modo dry-run (padrão) - apenas visualiza
./ec2-snapshot-cleanup.sh

# Executar limpeza real
./ec2-snapshot-cleanup.sh --dry-run=false

# Executar em região específica
./ec2-snapshot-cleanup.sh --dry-run=false --region us-east-1
```

## O que o script faz

1. Busca todos os snapshots criados pela sua conta AWS.
2. Identifica todos os snapshots que estão sendo referenciados por AMIs existentes.
3. Compara as duas listas para encontrar snapshots órfãos (não referenciados).
4. Exibe a lista de snapshots órfãos encontrados.
5. Se não estiver em modo dry-run, deleta os snapshots órfãos.

## Aviso

**Use com cautela!** Certifique-se de que os snapshots não estão sendo utilizados por outros recursos antes de removê-los. Snapshots deletados não podem ser recuperados.

## Funcionalidades

- ✅ Busca automática de snapshots órfãos
- ✅ Modo dry-run para previsualização segura
- ✅ Suporte a múltiplas regiões AWS
- ✅ Limpeza automática de arquivos temporários
- ✅ Interface amigável com emojis e contadores

## Observações

- O script identifica apenas snapshots que não estão vinculados a AMIs
- Snapshots podem estar sendo utilizados por outros recursos (volumes EBS, Launch Templates, etc.)
- Sempre execute primeiro em modo dry-run para verificar os resultados
