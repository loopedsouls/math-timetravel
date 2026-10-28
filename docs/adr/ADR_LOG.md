# ADR_LOG — Registro de Architecture Decision Records (ADRs)

Este arquivo lista, em ordem cronológica, os ADRs do projeto `math-timetravel` (MathQuest). Cada ADR fica em `docs/adr/` e registra uma decisão arquitetural ou de segurança com data, contexto, decisão e consequências. Para adicionar uma nova entrada, crie o ADR em `docs/adr/ADR-<NNNN>-<slug>.md` e adicione uma linha na tabela abaixo.

| ADR | Data | Título | Status | Resumo |
|-----|------|--------|--------|--------|
| [ADR-0001](./ADR-0001-exposicao-chaves-api-firebase.md) | 2026-10-28 | Exposição de chaves de API Firebase (AIza) no repositório | Aceito | Achado (severidade média) da revisão de segurança diária de 2026-10-28: chaves Firebase expostas em `lib/firebase_options.dart` e `android/app/google-services.json` são públicas por design (configuração FlutterFire necessária ao app) e devem ser mantidas; a varredura do repositório não encontrou nenhum outro segredo real. Ação requerida: aplicar restrições de API e de aplicativo/referrer a cada chave no Google Cloud Console e garantir Firebase Security Rules restritivas. |
