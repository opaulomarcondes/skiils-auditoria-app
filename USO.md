# Como usar

As skills não rodam sozinhas: o Claude as carrega quando o pedido corresponde à descrição de cada uma, ou quando você as chama pelo nome. Um bom pedido informa três coisas: o que auditar (pasta do projeto ou URL de teste), o contexto relevante (stack, país do público, provedores pagos) e se deve apenas diagnosticar ou também corrigir.

## Fluxo recomendado

Comece pelo diagnóstico, sem alterações. Peça a auditoria, leia o relatório, escolha o que corrigir e só então autorize as correções. As skills seguem essa ordem por padrão: aplicam correções somente após aprovação e reexecutam cada teste depois de corrigir.

## Exemplos de pedidos

### Segurança (27 regras)

```text
Use a skill teste-seguranca-27-regras para auditar o projeto em ./meu-app.
O ambiente de teste está em https://staging.meuapp.example. Apenas diagnostique.
```

Esperado: verificação das regras S01 a S27, como autenticação, hash de senhas, HTTPS, validação no servidor, XSS, consultas parametrizadas, CSRF, cookies, CORS, cabeçalhos, segredos, depuração, dependências, arquivos expostos e histórico do Git, com relatório de falhas e correções.

### Conformidade jurídica (35 regras)

```text
Use a skill teste-conformidade-juridica-35-regras no meu site.
Público: Brasil. Há cadastro, assinatura paga e um chatbot com IA.
```

Esperado: verificação das regras J01 a J35, incluindo políticas e termos, banner de cookies com teste em janela anônima, consentimento separado para marketing, exclusão de conta, acessibilidade, avaliações e contagens falsas, licenças, rotulagem de IA, cancelamento de assinatura e taxas escondidas.

### Abuso e custos (35 regras)

```text
Use a skill teste-antiabuso-custos-35-regras. O app chama a API de um modelo de IA
e envia e-mails de verificação. Temos ambiente de homologação com chaves de teste.
```

Esperado: inventário dos pontos que geram custo e teste das regras C01 a C35, com estimativa do custo potencial por hora de abuso e a rajada paralela final (C35) contra a cota.

### Auditoria integrada com padrão europeu

```text
Use a skill auditoria-app-seguranca-juridica-ue. O app é oferecido a usuários
na Alemanha e na França. Controlador no Brasil, sem representante na UE.
```

Esperado: execução das camadas S e J, mapeamento de cada regra para o instrumento europeu equivalente e os testes exclusivos E01 a E18, com verificação de atualidade das datas legais antes de começar.

## O que informar para melhorar o resultado

Indique a pasta do projeto e a stack. Informe a URL do ambiente de teste, nunca a de produção. Diga em quais países ou Estados-Membros há usuários, pois isso muda as regras aplicáveis. Liste os provedores pagos (IA, e-mail, SMS, pagamentos, nuvem) e o teto de gasto tolerado. Avise se o público pode incluir crianças e se há conteúdo gerado por usuários.

## Como ler o relatório

Cada regra recebe um status: APROVADA, PARCIAL, FALHA ou N/A. PARCIAL indica que parte do critério foi comprovada ou que falta uma evidência externa ao código, como a revogação de uma chave no painel do provedor, um acordo de tratamento de dados assinado ou uma configuração de orçamento na nuvem. A severidade orienta a ordem de correção. O relatório termina com as pendências que dependem de pessoas e, na skill europeia, com itens de monitoramento regulatório que ainda não são obrigações.

## Boas práticas e limites

Faça os testes dinâmicos apenas em ambiente de teste e com autorização do responsável. Use chaves de teste, provedores simulados e um teto de gasto no provedor antes de qualquer rajada de requisições. Não use cartões reais. Trate o relatório como registro do que foi verificado em uma data, não como garantia de segurança ou de conformidade, e repita a auditoria a cada mudança relevante. Para decisões jurídicas, consulte advogado com atuação na jurisdição pertinente.

## Combinando as skills

Para um lançamento completo, uma sequência útil é executar primeiro a skill de segurança, depois a antiabuso, e por fim a integrada (jurídica mais europeia). Há sobreposição intencional entre segurança e antiabuso em chaves, limite de requisições e pagamentos; quando um item aparecer nas duas, corrija uma vez e reteste em ambas.
