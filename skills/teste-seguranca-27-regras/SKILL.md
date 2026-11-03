---
name: "teste-seguranca-27-regras"
description: "Audita um projeto web contra as 27 regras de segurança do vídeo 'Claude Code, revisão de segurança' (afcodehub) e entrega relatório de falhas e correções."
---

# Teste das 27 regras de segurança

Esta skill transforma em teste executável as 27 regras apresentadas no vídeo "Não quero hackers invadindo meu app. Então, por favor:". Cada regra possui um procedimento de verificação (estático, no código e na configuração, e dinâmico, contra uma instância em execução quando houver) e um critério objetivo de aprovação. Ao final, a skill entrega um relatório das falhas e das correções, que é a própria vigésima sétima regra.

## Procedimento geral

1. Delimite o escopo com o usuário: diretório do projeto, stack (Node, Python, PHP, WordPress etc.), URL de ambiente de teste (nunca produção sem autorização expressa) e se há banco, autenticação, upload e pagamentos. Marque como N/A as regras que não se aplicam, justificando.
2. Faça o inventário: gerenciador de pacotes, framework, rotas, middlewares, arquivos de configuração, `.env*`, `.gitignore`, pasta pública e build.
3. Execute as 27 verificações abaixo, registrando para cada uma: status (APROVADA, FALHA, PARCIAL, N/A), evidência (arquivo e linha, ou comando e saída) e severidade (crítica, alta, média, baixa).
4. Corrija somente após aprovação do usuário. Cada correção deve ser seguida de novo teste da mesma regra.
5. Entregue o relatório (regra 27) em .docx, salvo se o usuário pedir outro formato.

Padrões de busca úteis: `grep -rnE` sobre o código-fonte, excluindo `node_modules`, `vendor` e `.git`. Ferramentas opcionais, quando instaladas: `npm audit`, `pip-audit`, `composer audit`, `gitleaks`, `trufflehog`, `depcheck`, `curl`.

## As 27 regras e como testá-las

**01. Configure uma autenticação adequada.** Verifique se há fluxo de login real (sessão ou token), senha armazenada com hash, estado de conta (ativa, verificada) checado no servidor e segredos de autenticação em cofre ou variável de ambiente. Falha se houver credencial fixa no código, comparação de senha em texto puro ou rota protegida acessível sem sessão. Teste dinâmico: requisitar rota protegida sem credencial e esperar 401 ou 403.

**02. Esconda as chaves de API.** Busque padrões de chave (`sk_`, `pk_live`, `AKIA`, `api_key`, `apikey`, `Bearer `, `secret`) em arquivos executados no navegador (JS do cliente, HTML, bundles em `dist/` ou `build/`). Falha se uma chave privada aparecer no cliente. Correção: mover a chamada para o servidor (proxy) e usar variável de ambiente.

**03. Proteja meu banco de dados.** Confirme que o banco não é acessível pela internet (porta fechada, sem credencial padrão) e que o acesso aos dados passa por autorização por usuário (um usuário não lê pedidos de outro; ver IDOR). Teste dinâmico: autenticar como usuário A e requisitar o recurso do usuário B, esperando 403 ou 404. Em Supabase ou Firebase, verifique políticas RLS ou regras de segurança ativas em todas as tabelas.

**04. Exija HTTPS.** Teste `curl -sI http://dominio` e espere redirecionamento 301 ou 308 para HTTPS; verifique o cabeçalho `Strict-Transport-Security`. Falha se houver recurso misto (http:// em páginas https) ou login servido em HTTP.

**05. Senhas protegidas com hash.** Localize o código de cadastro e login. Aprovada somente com algoritmo adequado (bcrypt, scrypt, argon2, PBKDF2 com iterações altas) e salt. Falha com MD5, SHA1, SHA256 simples, texto puro ou criptografia reversível. Verifique também se a senha não aparece em logs.

**06. Valide formulários no servidor.** Para cada endpoint que recebe dados, confirme validação no servidor (tipo, intervalo, tamanho, formato), independentemente da validação do navegador. Teste dinâmico: enviar `quantity=-3`, texto onde se espera número e campos ausentes por `curl` direto; esperar 400 ou 422, nunca 200.

**07. Proteja contra XSS.** Envie `<script>alert(1)</script>` e `"><img src=x onerror=alert(1)>` em todo campo que reaparece em página (comentários, perfil, busca). Falha se o texto retornar sem codificação de saída. Verifique no código o uso de `innerHTML`, `dangerouslySetInnerHTML`, `v-html`, `|safe`, `{!! !!}` e `echo` sem escape.

**08. Monitore atividades suspeitas.** Confirme que há registro (log) de falhas de login, acessos negados e erros, com carimbo de tempo e IP, e algum alerta ou limiar (por exemplo, 5 falhas em poucos segundos). Teste dinâmico: gerar várias falhas de login e verificar se constam no log sem expor a senha digitada.

**09. Restrinja as rotas de admin.** Liste rotas `/admin`, `/dashboard`, `/painel`, `/wp-admin` e APIs administrativas. Teste dinâmico: acessar sem login (esperar redirecionamento ou 401), com usuário comum (esperar 403) e com admin (esperar 200). Verifique que a checagem de papel ocorre no servidor, não apenas ocultando o link na interface.

**10. Use consultas parametrizadas.** Busque concatenação de entrada em SQL (`"SELECT ... " + var`, template strings com `${}` em queries, `f"...{var}"`, `$wpdb->query` sem `prepare`). Aprovada com prepared statements, ORM ou query builder com parâmetros. Teste dinâmico: injetar `' OR '1'='1` e `1; --` em parâmetros e verificar ausência de erro SQL ou de alteração de resultado.

**11. Confira as variáveis de ambiente.** Verifique que variáveis expostas ao navegador (prefixos `NEXT_PUBLIC_`, `VITE_`, `PUBLIC_`, `REACT_APP_`) não contêm segredos (chaves secretas, senhas de banco, `DATABASE_URL`, `SECRET`). Confirme que `.env` está no `.gitignore` e que existe `.env.example` sem valores reais.

**12. Limite as requisições.** Confirme rate limiting em login, cadastro, redefinição de senha e APIs públicas. Teste dinâmico: disparar 30 a 100 requisições rápidas ao mesmo endpoint (em ambiente de teste) e esperar resposta 429 com cabeçalho `Retry-After`. Falha se todas retornarem 200.

**13. Restrinja o CORS.** Procure `Access-Control-Allow-Origin: *` combinado com credenciais, ou reflexão cega do cabeçalho `Origin`. Teste dinâmico: `curl -H "Origin: https://outro-site.example" -I URL` e verificar que a origem desconhecida não é autorizada, enquanto a origem legítima é.

**14. Adicione cabeçalhos de segurança.** Teste `curl -sI URL` e verifique a presença de `Content-Security-Policy`, `X-Content-Type-Options: nosniff`, `X-Frame-Options` ou `frame-ancestors`, `Referrer-Policy`, `Strict-Transport-Security` e `Permissions-Policy`. Classifique como PARCIAL quando faltar parte deles. Verifique também a ausência de `X-Powered-By` e de versões de servidor reveladoras.

**15. Proteja os cookies de sessão.** Inspecione `Set-Cookie` do login: exigir `Secure`, `HttpOnly` e `SameSite=Lax` (ou `Strict`), além de expiração razoável. Falha se o token de sessão estiver em `localStorage` acessível a scripts quando houver alternativa por cookie.

**16. Proteja contra CSRF.** Para rotas que alteram estado (POST, PUT, PATCH, DELETE) autenticadas por cookie, confirme token anti-CSRF ou `SameSite` adequado com verificação de origem. Teste dinâmico: reenviar a requisição sem o token ou com `Origin` de outro site; esperar rejeição (403). Rotas autenticadas por cabeçalho `Authorization` (Bearer) ficam fora do risco clássico de CSRF, o que deve ser registrado.

**17. Links de redefinição devem expirar.** Verifique no código que o token de redefinição de senha é aleatório e criptograficamente forte, de uso único e com validade curta (por exemplo, até 1 hora). Teste dinâmico: reutilizar um token já consumido e usar um token expirado; ambos devem ser rejeitados. O token não deve aparecer em logs nem ser previsível.

**18. Restrinja tipos e tamanhos de arquivos.** Em cada upload, confirme lista permitida de tipos (extensão e MIME conferidos no servidor, idealmente por assinatura do arquivo), limite de tamanho e armazenamento fora da pasta executável com nome gerado pelo servidor. Teste dinâmico: enviar `.php`, `.html`, `.svg` com script e arquivo acima do limite; esperar rejeição.

**19. Verifique preços e pagamentos.** Confirme que preço, desconto, frete e total são calculados no servidor a partir do catálogo, nunca aceitos do cliente. Teste dinâmico: alterar o preço no corpo da requisição (de 100,00 para 1,00) e esperar que o servidor ignore ou rejeite. Confirme verificação da assinatura dos webhooks do provedor de pagamento e idempotência na confirmação.

**20. Desative o debug em produção.** Verifique `DEBUG=False`, `NODE_ENV=production`, `APP_DEBUG=false`, `WP_DEBUG=false` e ausência de páginas de erro detalhadas. Teste dinâmico: provocar um erro (rota inexistente, entrada inválida) e verificar que a resposta não mostra stack trace, caminhos de arquivo, SQL ou variáveis de ambiente.

**21. Atualize dependências vulneráveis.** Execute `npm audit --omit=dev`, `pip-audit`, `composer audit` ou equivalente. Reporte vulnerabilidades por severidade, com versão corrigida. Falha com qualquer vulnerabilidade crítica ou alta sem justificativa documentada. Verifique que existe lockfile versionado.

**22. Remova pacotes sem uso.** Execute `depcheck` (Node) ou equivalente e cruze com os `import` e `require` reais. Liste dependências declaradas e não utilizadas, bem como pacotes abandonados. Cada pacote removido reduz a superfície de ataque; confirme que os testes e o build continuam passando após a remoção.

**23. Verifique arquivos expostos.** Liste o conteúdo da pasta pública ou do artefato publicado e procure `.env`, `.env.backup`, `*.sql`, `*.dump`, `*.bak`, `*.zip`, `.git/`, `config.json`, `phpinfo.php`, `*.map` com código-fonte sensível. Teste dinâmico: `curl -s -o /dev/null -w "%{http_code}" URL/.env`, `/.git/config`, `/db-dump.sql`, `/backup.zip`; esperar 403 ou 404. Falha com qualquer 200.

**24. Procure segredos no histórico do Git.** Execute `gitleaks detect` ou `trufflehog git file://.`; sem as ferramentas, use `git log -p --all -S"sk_" -S"password" -S"api_key"` e `git log --all --diff-filter=D -- .env`. Falha se qualquer segredo, mesmo removido do código atual, constar em commits antigos. Remover o arquivo não basta: o segredo deve ser tratado como comprometido (regra 25).

**25. Revogue e substitua chaves comprometidas.** Para cada segredo achado nas regras 02, 11, 23 e 24, verifique se há evidência de rotação: nova chave emitida, antiga revogada no provedor e testada (requisição com a chave antiga deve retornar 401). Esta regra não pode ser comprovada apenas pelo código: peça ao usuário a confirmação da revogação em cada provedor e registre a data. Sem confirmação, o status é PARCIAL.

**26. Faça uma revisão de segurança.** Faça uma passada geral de lógica de acesso: fluxos de autorização, endpoints esquecidos (liste todas as rotas e confira quais exigem autenticação), comentários com credenciais, TODOs de segurança, logs com dados sensíveis, CORS e permissões de serviços de terceiros. Registre achados que não se enquadrem nas demais regras.

**27. Teste as proteções e entregue um relatório das falhas e das correções.** Depois de aplicar as correções aprovadas, reexecute todas as verificações que falharam e confirme a mudança de status. Produza o relatório final conforme o modelo abaixo.

## Modelo do relatório final

O relatório deve abrir com um resumo em prosa (escopo, ambiente testado, data, quantas das 27 regras foram aprovadas, parcialmente aprovadas, reprovadas e N/A, e os três riscos mais graves). Em seguida, uma tabela com as colunas: número, regra, status antes, evidência, severidade, correção aplicada, status depois. Depois, uma seção por falha crítica ou alta, em parágrafos, explicando o risco, o cenário de exploração e a correção. Encerrar com pendências que dependem do usuário (por exemplo, revogação de chaves em provedores) e recomendações de reteste periódico.

## Cuidados

Testes dinâmicos de carga, injeção e força bruta só podem ser feitos em ambiente de desenvolvimento ou homologação, com autorização do responsável. Nunca imprima segredos encontrados no relatório: mostre apenas os quatro primeiros caracteres e o local. O relatório documenta o que foi verificado; ausência de falha nas 27 regras não equivale a garantia de segurança total, pois o conjunto cobre as proteções mais comuns, não todas as classes de vulnerabilidade.