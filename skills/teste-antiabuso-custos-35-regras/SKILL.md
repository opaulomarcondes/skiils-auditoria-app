---
name: "teste-antiabuso-custos-35-regras"
description: "Audita um app contra as 35 regras de proteção de créditos de API e controle de custos do vídeo afcodehub 'não quero invasores abusando dos meus créditos' e entrega relatório."
---

# Teste das 35 regras de prevenção de abuso e controle de custos

O vídeo parte do pedido "Claude, não quero invasores abusando dos meus créditos de API e me causando milhares de dólares. Então, por favor:" e enumera 35 medidas. O risco central é financeiro: qualquer endpoint que dispare uma chamada paga (modelo de IA, e-mail, SMS, armazenamento, processamento, função sem servidor) e que possa ser acionado por terceiros sem freio transforma um invasor, ou um robô, em fatura. Esta skill converte cada medida em teste verificável, com evidência e critério objetivo de aprovação. Ela complementa, e não substitui, a skill de segurança das 27 regras (em especial as regras de chaves, limite de requisições e pagamentos).

## Procedimento geral

1. Delimite o escopo com o usuário: caminho do projeto, stack, provedores pagos usados (IA, e-mail, SMS, pagamentos, armazenamento, nuvem), ambiente de teste e quem pode autorizar gastos. Pergunte qual é o teto de gasto tolerado por dia, para calibrar os critérios.
2. Faça o inventário de pontos de custo: liste todo código que chama API paga, envia mensagem, grava arquivo, executa função ou consulta o banco com custo variável; para cada um, registre o endpoint que o aciona, quem pode acioná-lo (anônimo, usuário, admin, sistema) e o custo unitário aproximado.
3. Execute os 35 testes (C01 a C35), registrando status (APROVADA, PARCIAL, FALHA, N/A), evidência (arquivo e linha, comando e saída) e severidade, em que a severidade cresce com o custo potencial por hora de abuso.
4. Corrija somente após aprovação e reteste cada item.
5. Entregue o relatório em .docx, salvo pedido diverso.

## Regras de segurança do próprio teste

Testes dinâmicos não podem gerar custo real nem afetar produção. Use ambiente de desenvolvimento ou homologação, chaves de teste (modo de teste do provedor de pagamentos, caixas de saída de e-mail como Mailpit, SMS em sandbox), um servidor simulado (mock) no lugar do provedor pago quando possível, e um teto de gasto configurado no provedor antes de começar. Nunca use cartões reais para testar o checkout. Rajadas de requisições devem ser pequenas (dezenas, não milhares) e dirigidas ao simulador. Se não houver ambiente seguro, restrinja-se à análise estática e marque os testes dinâmicos como PARCIAL, com a justificativa.

## Bloco A. Chaves, acesso e identidade (C01, C02, C07, C08)

**C01. Mantenha chaves secretas fora do front-end.** Busque padrões de chave (`sk-`, `sk_live`, `AKIA`, `api_key`, `Bearer`) em código executado no navegador, em bundles (`dist/`, `build/`, `.next/static`) e em variáveis com prefixo público (`NEXT_PUBLIC_`, `VITE_`, `REACT_APP_`). Aprovada se toda chamada paga passa por um endpoint do servidor. Falha se o navegador envia a chave ao provedor.

**C02. Revogue e substitua as chaves vazadas.** Rode `gitleaks` ou `trufflehog`, ou `git log -p --all -S"sk-"`, para achar chaves no histórico. Para cada achado, exija evidência de rotação: nova chave emitida, antiga revogada no painel do provedor e teste confirmando que a antiga retorna 401. Isso não é comprovável só pelo código; solicite ao usuário a confirmação e registre a data, e mantenha PARCIAL sem ela.

**C07. Separe as chaves de teste e produção.** Verifique que desenvolvimento, homologação e produção usam chaves distintas, cada uma com cota e permissão próprias, em variáveis de ambiente separadas. Falha se o `.env` local aponta para chave de produção ou se uma mesma chave serve a todos os ambientes. Confirme que chaves de produção não estão em máquinas de desenvolvimento nem em CI sem necessidade.

**C08. Verifique o acesso pago no servidor.** Todo recurso premium deve checar plano, assinatura ou crédito no servidor a cada requisição, nunca por flag do cliente. Teste dinâmico: com usuário gratuito, chamar diretamente o endpoint premium (`curl`) e adulterar campos como `plan=pro` ou `isPaid=true` no corpo e nos cookies; esperar 402 ou 403.

## Bloco B. Cadastro, bots e abuso de gratuidade (C03, C04, C09, C10, C11)

**C03. Adicione verificação de bots a formulários públicos.** Cadastro, login, contato, recuperação de senha e qualquer formulário que dispare custo exigem desafio (CAPTCHA, Turnstile, reCAPTCHA, hCaptcha) validado no servidor. Teste dinâmico: enviar o formulário sem o token ou com token inválido por `curl`; esperar recusa. Falha se a validação ocorre só no navegador.

**C04. Limite cadastros falsos e o abuso de testes grátis.** Verifique mecanismos contra criação em massa de contas: confirmação de e-mail antes de liberar créditos, bloqueio de domínios descartáveis, limite de contas por IP e por dispositivo, e vínculo do teste grátis a um identificador difícil de recriar (e-mail verificado, telefone, meio de pagamento). Teste: criar 10 contas de teste em sequêda e observar se cada uma recebe créditos plenos.

**C09. Proteja o checkout contra testes de cartões.** O fluxo de pagamento deve resistir a card testing: limite de tentativas por IP, usuário e sessão, desafio de bot, regras antifraude do provedor ativas (por exemplo, Stripe Radar), validação de CVC e CEP, e bloqueio temporário após falhas sucessivas. Teste em modo de teste: disparar 10 falhas seguidas com cartões de recusa do provedor e verificar que o bloqueio ocorre. Não crie cobranças por tentativa de valor mínimo sem controle.

**C10. Limite requisições por usuário e IP.** Confirme limitador de taxa em cada endpoint de custo, com chave composta (usuário autenticado e IP, não apenas um deles), armazenamento compartilhado entre instâncias (Redis ou equivalente, não memória local) e resposta 429 com `Retry-After`. Teste: 30 requisições rápidas ao mesmo endpoint e verificar o corte. Cuide do cabeçalho `X-Forwarded-For`: o IP usado deve vir do proxy confiável, não de valor forjado pelo cliente.

**C11. Limite e-mails e mensagens de verificação.** Reenvio de código, link mágico, recuperação de senha e SMS devem ter intervalo mínimo (por exemplo, 60 segundos), teto por destinatário e por hora e teto por IP. Teste: solicitar o reenvio 10 vezes seguidas para o mesmo destinatário e para destinatários diferentes e contar quantas mensagens chegam à caixa de teste. Falha se o app pode ser usado para inundar terceiros ou esgotar a cota de envio.

## Bloco C. Cotas, tokens e chamadas pagas (C05, C06, C12, C13, C14, C15, C16, C17, C18)

**C05. Defina cotas diárias por usuário.** Existe contador de uso por usuário e por período (dia, mês) persistido no servidor, com limite configurável por plano e resposta clara ao exceder? Teste: consumir a cota de uma conta de teste e verificar que a próxima chamada é recusada antes de chegar ao provedor pago (confirme no simulador que não houve chamada).

**C06. Limite tokens de entrada e o histórico do chat.** O servidor impõe tamanho máximo da mensagem do usuário e trunca ou resume o histórico enviado ao modelo. Teste: enviar mensagem muito longa e histórico de centenas de turnos e verificar o corte ou a recusa. Falha se o cliente decide quanto contexto envia, ou se o histórico cresce sem limite a cada turno.

**C12. Fixe modelos e limites de tokens no servidor.** O nome do modelo, `max_tokens`, temperatura e demais parâmetros caros são definidos no servidor, e qualquer valor vindo do cliente é ignorado ou validado contra lista permitida. Teste: enviar `model` de maior custo e `max_tokens` enorme no corpo da requisição e verificar que o servidor mantém os valores fixos.

**C13. Limite os tokens de saída.** Toda chamada a modelo define `max_tokens` (ou equivalente) adequado à função, e prompts não permitem o pedido de saídas ilimitadas. Falha se a chamada não define teto ou usa o valor máximo do modelo por padrão. Verifique também o limite em fluxos de streaming e a interrupção quando o cliente desconecta.

**C14. Limite chamadas pagas a APIs de terceiros.** Para cada API paga, há teto por usuário e global (por minuto, hora e dia) aplicado antes da chamada, com cache de respostas repetidas quando for possível. Teste: repetir a mesma consulta 20 vezes e verificar se o cache evita chamadas redundantes; exceder o teto global e verificar a recusa.

**C15. Limite requisições simultâneas.** Existe teto de requisições em andamento por usuário (por exemplo, 2 a 5) e global para chamadas pagas, com fila ou recusa em excesso. Teste: abrir 20 requisições paralelas de longa duração a um endpoint pago e contar quantas chegam ao simulador do provedor ao mesmo tempo.

**C16. Impeça requisições duplicadas com cobrança.** Operações que cobram usam chave de idempotência ou deduplicação (por usuário, operação e parâmetros). Teste: enviar a mesma requisição com a mesma chave duas e dez vezes; esperar uma única execução e uma única cobrança. Verifique também duplo clique no front-end e reenvio automático por proxy ou fila.

**C17. Reserve a cota antes da chamada paga.** A cota deve ser reservada (decrementada de forma atômica) antes de chamar o provedor, e devolvida se a chamada falhar, em vez de verificada e debitada depois. Confira no código a ordem das operações e a atomicidade (transação, `UPDATE ... WHERE saldo >= custo`, script Lua no Redis, `INCR` com teto). Falha para o padrão "ler saldo, chamar, depois gravar", que permite corrida (ver C35).

**C18. Limite novas tentativas e ignore erros permanentes.** Novas tentativas têm número máximo, intervalo crescente com jitter e são aplicadas só a erros transitórios (timeout, 429, 5xx). Erros permanentes (400, 401, 403, 404, validação) não são repetidos. Procure laços `while(true)`, bibliotecas com retentativa infinita ou filas sem limite de entrega. Teste: fazer o simulador responder 400 e verificar uma única tentativa; responder 503 e contar o número de repetições.

## Bloco D. Arquivos, armazenamento e dados (C19, C20, C21, C22, C23, C24)

**C19. Limite o tamanho dos uploads e o tempo de processamento.** O servidor (e o proxy ou CDN à frente) rejeita arquivos acima de um limite antes de armazená-los, com tempo máximo de processamento por arquivo. Teste: enviar arquivo acima do limite e verificar rejeição precoce (413) sem leitura integral em memória. Falha se o limite existe só no navegador.

**C20. Bloqueie bombas de ZIP e imagens gigantes.** Para arquivos compactados, limite tamanho descompactado total, número de entradas, profundidade de aninhamento e razão de compressão; bloqueie caminhos com `..` (zip slip). Para imagens, limite dimensões em pixels (não só bytes) e memória de decodificação. Teste com arquivo de teste de alta razão de compressão (gerado localmente, de tamanho controlado) e com imagem de dimensões muito grandes, observando uso de memória e tempo.

**C21. Use URLs assinadas e com validade.** Downloads e uploads de arquivos privados usam URLs pré-assinadas com expiração curta (minutos), escopo restrito ao objeto e ao método, e restrição de tipo e tamanho no upload. Teste: reutilizar uma URL após a expiração e alterar o caminho do objeto; esperar 403. Falha se objetos privados têm URL pública permanente.

**C22. Bloqueie gravações públicas no armazenamento.** O bucket ou container não permite escrita anônima ou por qualquer usuário autenticado fora do próprio prefixo. Verifique as políticas (S3 Block Public Access, regras do Firebase Storage, políticas do Supabase Storage). Teste: tentar gravar um objeto sem credencial e com credencial de outro usuário; esperar 403. Uma gravação pública permite encher o armazenamento e gerar custo de transferência.

**C23. Exclua arquivos temporários vencidos.** Há ciclo de vida ou tarefa agendada que apaga uploads órfãos, saídas intermediárias e exportações antigas depois de um prazo. Verifique regras de ciclo de vida do bucket ou o job de limpeza, e teste criando um arquivo temporário com validade curta para confirmar a remoção.

**C24. Defina limites de retenção de logs.** Logs de aplicação, de acesso e de depuração têm prazo de retenção configurado (por exemplo, 14 a 90 dias, conforme a necessidade) e nível de detalhe adequado em produção. Falha se logs crescem sem limite ou se registram corpos completos de requisição e resposta, o que aumenta custo e expõe dados pessoais.

## Bloco E. Funções, tarefas e infraestrutura (C25, C26, C27, C28, C29)

**C25. Impeça gatilhos recursivos de funções.** Funções acionadas por eventos (gravação no banco, upload, mensagem em fila) não devem gerar o mesmo evento que as dispara. Mapeie cada gatilho e sua saída: uma função que grava no mesmo bucket ou tabela que a aciona cria laço infinito. Aprovada com prefixos distintos, filtros de evento, campo de marcação (por exemplo, `processed=true`) ou profundidade máxima de encadeamento.

**C26. Defina o tempo máximo das tarefas.** Toda função, tarefa em segundo plano e consulta tem timeout explícito e razoável, inclusive chamadas HTTP de saída. Falha se há chamada sem timeout, tarefa que pode rodar indefinidamente ou timeout da plataforma deixado no máximo sem necessidade.

**C27. Impeça tarefas agendadas de se sobreporem.** Tarefas periódicas (cron) usam trava distribuída ou verificação de execução em andamento, para que uma execução lenta não seja iniciada de novo por cima da anterior. Teste: simular uma execução longa e disparar a próxima; esperar que a segunda seja ignorada ou enfileirada. Verifique também se múltiplas instâncias do app executam o mesmo cron.

**C28. Limite os lotes e os resultados das consultas.** Consultas e listagens usam paginação com `LIMIT` máximo imposto no servidor (parâmetro `limit` do cliente tem teto), e processamentos em lote têm tamanho máximo. Teste: pedir `limit=1000000` e verificar o corte. Em bancos cobrados por leitura (Firestore, DynamoDB, BigQuery), isso é diretamente financeiro.

**C29. Limite o escalonamento automático e a concorrência de funções sem servidor.** Verifique nas configurações da plataforma (Vercel, Lambda, Cloud Run, Functions) o número máximo de instâncias, a concorrência reservada ou máxima, e o limite de memória e duração. Falha se o escalonamento é ilimitado em endpoints expostos publicamente, pois um ataque volumétrico vira fatura proporcional.

## Bloco F. Monitoramento, orçamento e contenção (C30, C31, C32, C33, C34)

**C30. Acompanhe os gastos por usuário e serviço.** O app registra, a cada chamada paga, usuário, serviço, modelo, tokens ou unidades e custo estimado, e há relatório ou painel que agrega por usuário e por serviço. Teste: executar chamadas de teste com duas contas e confirmar que o painel as distingue. Sem isso, não é possível identificar quem causa o gasto.

**C31. Detecte picos de gastos.** Há detecção automática de desvio (por exemplo, gasto horário acima de N vezes a média, usuário fora do padrão) com alerta. Verifique regras de anomalia do provedor de nuvem e métricas próprias; simule um pico no ambiente de teste e confirme que o alerta dispara.

**C32. Alerte antes de atingir o orçamento.** Existem orçamentos configurados nos provedores (nuvem, IA, e-mail) com alertas em limiares progressivos (por exemplo, 50, 80 e 100 por cento) para canais que alguém realmente lê (e-mail monitorado, mensagem instantânea). Falha se o alerta chega a uma caixa abandonada ou só ao estourar o limite.

**C33. Interrompa requisições pagas quando o orçamento acabar.** Ao esgotar o orçamento ou a cota global, o app para de chamar o provedor pago e responde de forma degradada e clara (por exemplo, 503 com mensagem), em vez de continuar gastando. Teste: reduzir o orçamento simulado a zero e verificar que as chamadas deixam de ser feitas. Atenção: muitos orçamentos de nuvem apenas alertam; o corte precisa ser implementado no código ou em automação.

**C34. Adicione um interruptor de emergência para gastos.** Existe um mecanismo rápido (variável de ambiente, flag, comando, botão administrativo) que desliga todas as chamadas pagas, ou as de um serviço específico, sem novo deploy e com efeito em segundos. Teste: acionar o interruptor no ambiente de teste e medir o tempo até a cessação das chamadas; documentar quem pode aciona-lo e como (runbook).

## Regra final

**C35. Teste se requisições paralelas não conseguem burlar os limites.** Esta é a verificação integradora, que valida na prática C05, C10, C14, C15, C16 e C17. Em ambiente de teste, com cota pequena (por exemplo, 5 chamadas) e provedor simulado, dispare 20 a 50 requisições simultâneas da mesma conta (por exemplo, com `xargs -P`, `ab`, `k6` ou um script assíncrono) e conte quantas chegam ao provedor. Aprovada somente se o total aceito for menor ou igual à cota. Repita variando: mesma conta com vários IPs simulados, várias contas novas do mesmo IP, mesma chave de idempotência em paralelo e esgotamento do saldo no mesmo instante. Qualquer excesso indica condição de corrida na reserva da cota e deve ser classificado como severidade alta.

## Modelo do relatório

Abrir com resumo em prosa: escopo, provedores pagos, ambiente e data dos testes, contagem de status e os cinco riscos de maior exposição financeira, com estimativa do custo potencial por hora de abuso quando for possível calculá-lo (taxa por requisição multiplicada pelo ritmo máximo permitido pelo limitador atual). Em seguida, tabela com identificador (C01 a C35), regra, status inicial, evidência, severidade, correção aplicada e status final. Depois, uma seção em parágrafos para cada falha de severidade alta, com o cenário de abuso e a correção. Encerrar com as pendências que dependem do usuário (rotação de chaves nos provedores, orçamentos e alertas nos painéis, limites de escalonamento) e com o runbook do interruptor de emergência.

## Limites

A skill avalia as medidas de prevenção e contenção descritas no vídeo; não garante imunidade a abuso nem substitui testes de carga e de intrusão por especialistas. Itens que dependem de configurações nos painéis dos provedores (C02, C07, C29, C32 e C33) não são comprováveis apenas pelo código e permanecem PARCIAL até haver captura de tela ou exportação da configuração fornecida pelo usuário.