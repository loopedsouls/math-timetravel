# ADR-0001: Exposição de chaves de API Firebase (AIza) no repositório

- **Data:** 2026-10-28
- **Status:** Aceito
- **Contexto:** Revisão de segurança diária do repositório `loopedsouls/math-timetravel` (app Flutter MathQuest)
- **Severidade do achado:** Média

## Contexto

A revisão de segurança diária de 2026-10-28 identificou chaves de API Firebase (formato `AIza...`) expostas nos seguintes arquivos versionados:

| Arquivo | Linha(s) | Chave | Plataforma |
|---|---|---|---|
| `android/app/google-services.json` | 18 | `AIzaSyC2ZTYE2iOnTVUlXlN0O2Xy6lBpbh-TwE8` | Android |
| `lib/firebase_options.dart` | 41, 49 | `AIzaSyDPOO03OQwROqzvpdTKRLPwYvESoolCxaU` | iOS / Web |
| `lib/firebase_options.dart` | 59 | `AIzaSyC2ZTYE2iOnTVUlXlN0O2Xy6lBpbh-TwE8` | Android |

Ambos os arquivos são gerados pelo FlutterFire CLI (`flutterfire configure`) e contêm **apenas** os identificadores de configuração padrão do Firebase para as plataformas suportadas (`apiKey`, `appId`, `messagingSenderId`, `projectId`, `storageBucket`, `authDomain`, `measurementId`, `project_number`, `package_name`). Não há credenciais secretas nesses arquivos.

### Resultado da varredura de segredos no repositório (2026-10-28)

A varredura completa do repositório **não encontrou nenhum segredo real** além das chaves de configuração web/mobile do Firebase listadas acima:

- Nenhum JSON de conta de serviço (service account) ou chave privada (PKCS#8 / RSA / EC / OpenSSH);
- Nenhuma chave de API server-side: OpenAI (`sk-...`), GitHub (`ghp_...` / `github_pat_...`), AWS (`AKIA...`), Slack (`xox...`);
- Nenhuma senha ou credencial hardcoded em código Dart, scripts (`deploy.ps1`, `deploy_safe.ps1`, `setup_structure.py`), `firebase.json` ou demais configurações;
- O arquivo `.env` (usado para `OPENAI_API_KEY`) está corretamente listado no `.gitignore` e não está versionado; a chave OpenAI é lida apenas em tempo de execução via variável de ambiente ou `flutter_dotenv` (`lib/core/constants/openai_config.dart`);
- Nenhum arquivo de credencial (`.pem`, `.p12`, `.jks`, `.keystore`) versionado;
- Nenhum `GoogleService-Info.plist` iOS no repositório (a configuração iOS é um placeholder).

## Decisão

1. **Manter** `lib/firebase_options.dart` e `android/app/google-services.json` no repositório, sem alterações. Chaves de API Firebase no formato `AIza...` usadas em clientes web/mobile são **públicas por design**: o Firebase as distribui como identificadores de configuração do projeto, não como credenciais secretas. A segurança real do projeto depende das **Firebase Security Rules** e das **restrições aplicadas às chaves** no Google Cloud Console. Remover esses arquivos quebraria a inicialização do Firebase no app — eles são necessários para o funcionamento em todas as plataformas.

2. **Tratar o risco residual como item de configuração de infraestrutura**, não de código: chaves expostas sem restrições podem ser reutilizadas por terceiros (consumo de cota, abuso das APIs habilitadas no projeto) caso as Security Rules não sejam restritivas.

## Ações requeridas (Google Cloud Console + Firebase Console)

Para cada chave `AIza...` do projeto `mathquest6969` (Google Cloud Console → APIs e serviços → Credenciais):

1. **Restrições de aplicativo (Application restrictions):**
   - Chave Android (`AIzaSyC2ZTYE2iOnTVUlXlN0O2Xy6lBpbh-TwE8`): restringir a **apps Android**, informando o nome do pacote `com.example.mathquest` e as impressões digitais SHA-1/SHA-256 dos keystores de assinatura (debug e release);
   - Chave iOS/Web (`AIzaSyDPOO03OQwROqzvpdTKRLPwYvESoolCxaU`): restringir a **apps iOS** (bundle ID) e/ou a **referrers HTTP** dos domínios onde o app web é publicado (ex.: `*.firebaseapp.com` e o domínio do GitHub Pages usado no deploy).
2. **Restrições de API (API restrictions):** limitar cada chave apenas às APIs realmente usadas pelo app (ex.: Identity Toolkit API, Firebase Installations API, Cloud Firestore, Firebase Storage); nunca deixar a opção "All APIs" habilitada.
3. **Firebase Security Rules restritivas:** garantir que as regras do Firestore, do Realtime Database e do Storage sigam o princípio *deny-by-default* — leitura/escrita apenas para usuários autenticados (validando `request.auth`), com validação de esquema por coleção.
4. **Monitoramento:** habilitar alertas de uso anômalo de API no Google Cloud e revisar periodicamente as cotas do projeto.

## Consequências

- **Positivas:** o app continua funcionando normalmente em todas as plataformas; a configuração permanece reproduzível via FlutterFire CLI; o risco de abuso das chaves é mitigado no nível correto (infraestrutura), sem mudanças no código.
- **Risco residual:** enquanto as restrições não forem aplicadas no Google Cloud Console, as chaves expostas podem ser usadas por terceiros para consumir cotas ou atacar as APIs habilitadas do projeto. Este risco **não pode ser corrigido por código** — requer ação manual de administrador no console.
- **Rotacionamento:** em caso de abuso detectado, as chaves podem ser rotacionadas no Google Cloud Console e os arquivos regenerados via `flutterfire configure` (custo baixo, pois são chaves de configuração de cliente).
- Este ADR deve ser revisitado caso o app passe a usar credenciais server-side (contas de serviço, chaves privadas), que **nunca** devem ser versionadas no repositório.

## Referências

- Firebase: chaves de API do Firebase não são secretas por design — https://firebase.google.com/docs/projects/api-keys
- Google Cloud: como proteger chaves de API — https://cloud.google.com/docs/authentication/api-keys#securing
- Firebase Security Rules — https://firebase.google.com/docs/rules
