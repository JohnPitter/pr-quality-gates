---
name: quality-report
description: Roda a suite completa dos 5 gates de qualidade e pede ao Claude para explicar violacoes e sugerir refactors.
---

Execute o script `hooks/pr-check.sh` do plugin `pr-quality-gates` e, para cada gate que falhar:

1. Resuma a violacao em 1 linha (arquivo, metrica, valor atual vs threshold).
2. Sugira uma acao de refactor concreta (extrair funcao, dividir arquivo, inverter dependencia).
3. Priorize as violacoes por impacto (alto / medio / baixo) baseado em:
   - Tamanho do arquivo/funcao afetado
   - Criticidade do modulo (camada de dominio > infra > utils)
   - Risco de regressao

No final, liste os gates que passaram em uma linha cada. Nao entre em detalhes sobre os que passaram.

Se todos passarem, apenas reporte: "Todos os 5 gates OK - PR pronto para review."
