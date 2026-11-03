---
name: "teste-conformidade-juridica-35-regras"
description: "Audita um app ou site contra as 35 regras de conformidade jurídica do vídeo 'não quero que meu app feito com IA me traga problemas jurídicos' (afcodehub) e entrega relatório."
---

# Teste das 35 regras de conformidade jurídica

O vídeo parte do pedido "Claude, não quero que meu app feito com IA me traga problemas jurídicos. Então, por favor:" e enumera 35 itens de uma checklist, que fecha com "E o mais importante: não cometa erros". Esta skill transforma cada item em um teste verificável sobre o código, o conteúdo publicado e o comportamento do app em execução. Ela verifica existência, coerência e funcionamento das medidas; não substitui parecer jurídico sobre a validade das cláusulas.

## Procedimento geral

1. Delimite o escopo com o usuário: caminho do projeto, URL de teste, público (inclui crianças?), país de atuação (Brasil: LGPD, CDC, Marco Civil; UE: GDPR; EUA: COPPA, DMCA, CCPA), se há cobrança e assinatura, uso de IA, dependências de terceiros e conteúdo de usuários. Marque como N/A, com justificativa, o que não se aplica.
2. Inventário: páginas e rotas públicas, rodapé, formulário de cadastro, checkout, área da conta, e-mails transacionais e de marketing, `package.json` ou equivalente, scripts de terceiros (`<script src>`), cookies e armazenamento local, imagens, fontes e vídeos.
3. Execute os 35 testes abaixo. Para cada um, registre status (APROVADA, PARCIAL, FALHA, N/A), evidência (arquivo e linha, captura, comando ou URL) e severidade (alta, média, baixa).
4. Proponha correções, aplique somente as aprovadas pelo usuário e reteste cada item corrigido.
5. Entregue o relatório em .docx, salvo pedido diverso.

Testes dinâmicos em navegador devem usar janela anônima e perfil limpo (sem cookies prévios). Ferramentas úteis, se disponíveis: `curl`, Playwright, `axe-core` ou Lighthouse, `license-checker`, `pip-licenses`, `npm ls`, `grep`.

## Bloco A. Documentos legais e cadastro (regras 1, 2, 15, 16, 22, 35)

**01. Adicione uma política de privacidade.** Existe página de política de privacidade acessível por link no rodapé e no cadastro? Deve descrever dados coletados, finalidades, bases legais, compartilhamento, prazo de retenção, direitos do titular e contato do responsável. Falha se o link der 404, apontar para texto de preenchimento ("lorem ipsum", "[nome da empresa]") ou omitir dados efetivamente coletados pelo código.

**02. Adicione termos de uso.** Página de termos acessível e coerente com o serviço real (regras de conta, uso aceitável, propriedade intelectual, limitação de responsabilidade, foro). Falha por texto genérico com placeholders ou por cláusulas que contradizem o produto.

**03. Adicione um banner de cookies.** Em janela anônima, o primeiro carregamento exibe banner com opções de aceitar, rejeitar e personalizar por categoria (essenciais, análise, marketing)? Falha se não houver banner e existirem cookies ou rastreadores não essenciais, ou se rejeitar for mais difícil que aceitar.

**15. Adicione uma caixa para aceitar a política de privacidade e os termos.** O cadastro tem caixa de seleção, desmarcada por padrão, com links para os dois documentos, e o botão "Criar conta" permanece inativo até a marcação? Teste também o envio direto da requisição sem o campo de aceite: o servidor deve recusar.

**16. Adicione uma política de reembolso.** Página clara com quem pode pedir, prazo, como solicitar e para onde vai o valor. No Brasil, confira coerência com o direito de arrependimento de 7 dias em compras fora do estabelecimento (CDC, art. 49).

**22. Registre a aceitação dos termos.** O backend grava, por usuário, a versão dos termos aceita, data e hora e, se possível, IP? Verifique o esquema do banco e o código do cadastro. Falha se só houver a caixa no front-end, sem registro persistido, ou se não houver versionamento (o usuário deve reaceitar quando os termos mudarem).

**35. Adicione os contatos da empresa.** Rodapé ou página de contato com razão social, endereço, e-mail funcional e, para dados pessoais, canal do encarregado (DPO). Teste enviar e-mail ou formulário de teste e verificar o recebimento.

## Bloco B. Privacidade e dados (regras 4, 5, 12, 18, 21, 24, 27, 29, 30, 31, 32)

**04. Permita cancelar e-mails de marketing.** Todo e-mail de marketing contém link de descadastro funcional (um clique, sem login) e a conta tem preferências de e-mail, mantendo e-mails transacionais separados. Teste o link e confirme que o envio cessa.

**05. Defina limites de retenção de dados.** Há prazo documentado e mecanismo real de eliminação ou anonimização (job agendado, TTL, política de banco) para logs, contas inativas, backups e dados de formulários? Falha se a política fala em prazo e o código nunca apaga nada.

**12. Permita acesso aos dados e pedidos de exclusão.** A conta oferece "Baixar meus dados" e "Excluir minha conta"? Teste de ponta a ponta com usuário de teste: exportar (formato legível, cobrindo perfil, histórico e mensagens) e excluir (verificar remoção no banco, em caches, em armazenamento de arquivos e em provedores de terceiros). Relação com LGPD, art. 18.

**18. Pare de coletar dados desnecessários.** Compare cada campo coletado em formulários, parâmetros e rastreadores com a finalidade declarada. Falha para campos sem uso (data de nascimento, telefone, documento) e para eventos de rastreamento que ninguém consulta. Princípio da minimização.

**21. Obtenha consentimento dos responsáveis antes de coletar dados de crianças.** Se o público pode incluir menores (de 13 anos nos EUA, de 18 no Brasil, com regras específicas para crianças até 12 anos), o fluxo exige verificação de idade, pedido de autorização ao responsável, aprovação e só então coleta. Teste cadastrar com idade de menor: a coleta deve ficar pausada. N/A se o serviço for comprovadamente restrito a adultos, com barreira real.

**24. Separe o consentimento para marketing.** O consentimento de marketing é caixa própria, desmarcada, distinta do aceite de termos. Falha se estiver agrupada ("aceito os termos e os e-mails de marketing") ou pré-marcada. Teste: criar conta sem marcar e verificar que não entra em listas de marketing.

**27. Impeça treinamento de IA não autorizado com dados dos usuários.** Mapeie todo envio de dados de usuários a APIs de IA. Confirme: termos do provedor que vedam treino com os dados (ou opt-out ativo), minimização e anonimização antes do envio, menção na política de privacidade e opção do usuário quando aplicável. Falha se dados pessoais forem enviados a modelos sem base contratual ou sem divulgação.

**29. Audite SDKs, análise e rastreamento de terceiros.** Liste todo SDK e script externo (análise, anúncios, relatórios de falhas, chat, mapas, fontes) a partir de `package.json`, tags `<script>` e do tráfego de rede (aba Network ou Playwright). Para cada um, registre quais dados envia (IP, ID do aparelho, e-mail, localização, logs) e se está descrito na política. Falha para itens não divulgados.

**30. Estabeleça acordos de tratamento de dados.** Para cada operador que processa dados pessoais (hospedagem, e-mail, análise, pagamento, IA), verifique a existência de acordo de processamento de dados (DPA) aceito ou assinado. Isso não é comprovável só no código: solicite ao usuário o comprovante de cada DPA e registre; sem ele, status PARCIAL.

**31. Bloqueie rastreadores até o consentimento do usuário.** Teste decisivo: em janela anônima, antes de qualquer clique no banner, inspecione a rede e os cookies. Nenhum rastreador não essencial (analytics, pixels de anúncio) pode disparar. Depois recuse e confirme que continuam bloqueados; ao aceitar, devem ativar. Falha se disparam no carregamento.

**32. Publique uma lista de suboperadores.** Existe página pública (por exemplo, `/subprocessors`) com nome, finalidade, tipo de dado e localização de cada suboperador, coerente com o resultado da regra 29? Falha se a lista estiver ausente, desatualizada ou incompleta frente ao inventário.

## Bloco C. Acessibilidade e interface (regras 6, 7, 8, 9, 13)

**06. Corrija o contraste das cores.** Meça a razão de contraste texto/fundo: mínimo 4,5:1 para texto normal e 3:1 para texto grande e componentes de interface (WCAG 2.1 AA). Use `axe-core` ou Lighthouse e calcule manualmente os casos duvidosos, incluindo botões desabilitados e texto sobre imagem.

**07. Remova contagens regressivas falsas.** Procure temporizadores ("oferta termina em 00:04:57") e verifique se refletem prazo real: recarregue a página, abra em outra sessão e limpe o armazenamento. Se o relógio reinicia ou usa `Date.now() + constante` no cliente, é falso. Falha também para "restam 3 unidades" fixo.

**08. Adicione texto alternativo às imagens.** Todo `<img>` informativo tem `alt` descritivo; decorativas têm `alt=""`. Falha para `alt` ausente, nomes de arquivo como alt ou "imagem". Verifique também ícones-botão com `aria-label`.

**09. Permita navegar pelo teclado.** Percorra o site apenas com Tab, Shift+Tab, Enter, Espaço e Esc: todos os controles devem ser alcançáveis, com foco visível, ordem lógica, sem armadilha de foco, e modais devem fechar com Esc. Falha para `div` clicável sem `tabindex` e `role`, e para `outline: none` sem substituto.

**13. Remova padrões enganosos.** Revise fluxos de cancelamento, banners, preços e telas de saída em busca de: caixas pré-marcadas para extras, botão de recusar disfarçado ou culpabilizante ("não, prefiro pagar mais"), opções escondidas, urgência fabricada, adição automática de itens ao carrinho. Falha para qualquer um que induza o usuário contra o próprio interesse.

## Bloco D. Conteúdo, licenças e propriedade intelectual (regras 10, 11, 14, 19, 20, 23, 25, 26)

**10. Não use logos de clientes sem permissão.** Liste logos de terceiros em seções como "equipes que confiam em nós" e peça ao usuário a autorização escrita de cada marca. Sem comprovação, FALHA e sugerir remoção. Logos fictícios devem ser claramente identificados como exemplo.

**11. Verifique as licenças de imagens, fontes e código.** Para cada imagem, fonte tipográfica e trecho de código copiado, identifique a origem e a licença, inclusive uso comercial. Procure imagens sem procedência (metadados EXIF, pasta `assets`), fontes pagas servidas por arquivo local e trechos com cabeçalho de licença. Registre em planilha de ativos com origem, licença e comprovação.

**14. Identifique conteúdo gerado por IA.** Textos, imagens, áudios e respostas de chat produzidos por IA trazem rótulo visível (por exemplo, "gerado por IA"), e conversas com agente automatizado deixam claro que não é pessoa. Falha se conteúdo sintético for apresentado como humano ou de autoria de pessoa real.

**19. Remova avaliações falsas.** Verifique depoimentos e estrelas: são de clientes reais, com consentimento e verificáveis? Falha para nomes e fotos inventados, notas fixas no código ou depoimentos gerados por IA apresentados como reais. Alternativa: exibir avaliações reais ou remover a seção.

**20. Remova afirmações sem comprovação.** Liste alegações objetivas ("garantia de dobrar sua receita", "o mais rápido", "100% seguro", "resultados em 7 dias", "cura") e exija evidência documentada para cada uma. Sem prova, reescrever de forma verificável ou remover. Atenção especial a promessas de resultado, saúde e finanças.

**23. Confira as obrigações das licenças de código aberto.** Gere o inventário de licenças das dependências (`license-checker --summary`, `pip-licenses`). Verifique: avisos de copyright e licença incluídos (página de créditos ou arquivo NOTICE), compatibilidade com o modelo comercial (atenção a GPL, AGPL e licenças copyleft em código distribuído ou servido por rede) e termos de uso de licenças não comerciais.

**25. Remova falsas alegações de conformidade SOC 2.** Procure em páginas, rodapé, material comercial e metadados menções a SOC 2, ISO 27001, HIPAA, LGPD "totalmente em conformidade" ou selos. Cada uma exige relatório ou certificado válido; "criado com foco em segurança" não equivale a conformidade. Sem comprovante, remover ou reformular (por exemplo, "alinhado às práticas do SOC 2, sem certificação").

**26. Confira os requisitos de registro da DMCA.** Se o app hospeda conteúdo de usuários, verifique agente designado (registro no Copyright Office, no caso dos EUA), página de aviso e retirada com e-mail de contato, procedimento de contranotificação e política de reincidentes. N/A se não houver conteúdo de terceiros. Para o Brasil, confira equivalente de notificação e retirada (Marco Civil da Internet, art. 19).

## Bloco E. Cobrança, assinaturas e comunicação comercial (regras 17, 28, 33, 34)

**17. Facilite cancelar as assinaturas.** Conte os cliques entre o login e o cancelamento efetivo. O cancelamento deve ser feito online, sem exigir contato com atendimento, sem telas de dissuasão em excesso e com confirmação por e-mail e indicação da data em que o acesso termina. Teste com assinatura de teste.

**28. Informe sobre as renovações automáticas.** Antes da compra, a tela de assinatura informa valor, periodicidade, data da próxima cobrança e que renova automaticamente, com consentimento explícito. Verifique também lembrete por e-mail antes da renovação em planos longos.

**33. Assuma compromissos realistas de disponibilidade.** Procure promessas como "100% de disponibilidade garantida". Compare com a infraestrutura real (SLA dos provedores, ausência de redundância). Aprovada com metas verificáveis (por exemplo, 99,9%), forma de medição, exclusões (manutenção programada) e remédio previsto (crédito).

**34. Remova taxas escondidas.** Simule o checkout completo até a última tela e compare o total com o preço anunciado. Falha se surgirem taxas de serviço, conveniência ou impostos só na última etapa; o total deve ser apresentado desde o início ou de forma clara antes do pagamento.

## Regra final: não cometa erros

O vídeo encerra com "E o mais importante: não cometa erros". Na prática, isso é o reteste: após as correções, reexecute todo item que falhou ou ficou parcial, confirme que a correção não quebrou outro fluxo (cadastro, checkout, login) e registre o status final de cada uma das 35 regras.

## Modelo do relatório

Abrir com resumo em prosa: escopo, jurisdições consideradas, ambiente e data do teste, contagem de aprovadas, parciais, falhas e N/A, e os cinco riscos mais graves. Em seguida, tabela com número, regra, status inicial, evidência, severidade, correção aplicada e status final. Depois, uma seção em parágrafos para cada falha de severidade alta, com o risco, o cenário e a correção. Encerrar com as pendências que dependem de pessoas (autorização de logos, DPAs, comprovantes de certificação, revisão por advogado dos textos legais) e com a periodicidade recomendada de reteste.

## Limites

A skill verifica a presença e o funcionamento das medidas, não a suficiência jurídica dos textos; o parecer final sobre políticas, termos e obrigações de cada jurisdição cabe a profissional habilitado. Itens que dependem de documentos externos (regras 10, 11, 25, 26 e 30) ficam PARCIAL até o usuário apresentar o comprovante.