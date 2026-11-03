# Skills de auditoria para apps feitos com IA

Quatro skills para o Claude que transformam em testes verificáveis as regras apresentadas em três vídeos do perfil @afcodehub sobre como evitar problemas em aplicações criadas com apoio de IA: segurança técnica, conformidade jurídica e abuso de créditos de API. Cada skill percorre as regras uma a uma, registra evidência e severidade, propõe correções e entrega um relatório final.

## O que há no repositório

| Skill | Regras | Foco |
| --- | --- | --- |
| `teste-seguranca-27-regras` | 27 (S01 a S27) | Autenticação, segredos, HTTPS, validação, XSS, CSRF, injeção SQL, cookies, CORS, cabeçalhos, dependências, arquivos expostos, histórico do Git |
| `teste-conformidade-juridica-35-regras` | 35 (J01 a J35) | Privacidade, termos, cookies, consentimento, direitos do titular, acessibilidade, práticas enganosas, licenças, IA, assinaturas, suboperadores |
| `teste-antiabuso-custos-35-regras` | 35 (C01 a C35) | Proteção de créditos de API, cotas, tokens, bots, checkout, uploads, funções sem servidor, orçamento e interruptor de emergência |
| `auditoria-app-seguranca-juridica-ue` | S + J + 18 testes europeus (E01 a E18) | Integra as duas primeiras e acrescenta GDPR, ePrivacy, DSA, European Accessibility Act, AI Act, NIS2, CRA, Diretivas de consumo e Data Act |

As skills de segurança, jurídica e antiabuso funcionam de forma independente. A skill europeia é uma camada integradora: ela executa as de segurança e jurídica sem alterá-las e acrescenta o mapeamento para a legislação da União Europeia.

## Instalação rápida

Para o Claude Code, clone o repositório e execute o instalador:

```bash
git clone https://github.com/opaulomarcondes/skiils-auditoria-app.git
cd skiils-auditoria-app
./scripts/install.sh
```

As skills ficam em `~/.claude/skills/` e passam a estar disponíveis em qualquer projeto. Para o aplicativo Claude (web e desktop), gere os arquivos `.zip` com `./scripts/package.sh` e envie cada um em Configurações, na seção de Skills. Os passos completos, por ambiente, estão em [INSTALACAO.md](INSTALACAO.md).

## Como usar

Basta pedir a auditoria em linguagem natural, indicando o projeto e, quando houver, o ambiente de teste:

```text
Use a skill teste-seguranca-27-regras para auditar o projeto em ./meu-app
```

Exemplos para cada skill, o que esperar do relatório e boas práticas de uso estão em [USO.md](USO.md).

## Cuidados importantes

Os testes dinâmicos (requisições a endpoints, rajadas de chamadas, tentativas de injeção, simulação de checkout) devem ser executados somente em ambiente de desenvolvimento ou homologação, com autorização de quem responde pelo sistema. Nunca aponte uma auditoria de carga ou de abuso para produção, nem use cartões reais. As skills verificam a presença e o funcionamento das medidas; não substituem pentest profissional nem parecer de advogado. A camada europeia indica o instrumento legal aplicável, mas a interpretação final depende do Estado-Membro e do caso concreto.

## Origem das regras

As regras foram extraídas do texto exibido na tela de três vídeos do perfil @afcodehub no TikTok. O áudio não foi transcrito, de modo que a lista segue as legendas e animações. Os procedimentos de teste, os critérios de aprovação, o mapeamento europeu e o modelo de relatório são elaborações próprias deste repositório, e o autor dos vídeos não tem relação com ele. Se o conteúdo falado divergir da legenda, ajuste o `SKILL.md` correspondente.

## Estrutura

```text
skiils-auditoria-app/
  README.md
  LICENSE
  INSTALACAO.md
  USO.md
  scripts/
    install.sh
    package.sh
  skills/
    teste-seguranca-27-regras/SKILL.md
    teste-conformidade-juridica-35-regras/SKILL.md
    teste-antiabuso-custos-35-regras/SKILL.md
    auditoria-app-seguranca-juridica-ue/SKILL.md
```

## Contribuição e manutenção

A legislação digital europeia muda com frequência. A skill europeia exige uma verificação de atualidade antes de cada auditoria, e as datas citadas nela refletem o estado conhecido em novembro de 2026. Ao revisar uma regra, edite o `SKILL.md` correspondente, mantendo o frontmatter (`name` e `description`) e o mesmo identificador de regra, para que os relatórios anteriores continuem comparáveis.

## Autoria

Estas skills foram criadas por Paulo Marcondes, do Instituto Educater, em colaboração com o Claude (modelo Sonnet 5.5, nível de esforço médio).

## Licença

Este repositório é distribuído sob a GNU General Public License v3.0 (ver [LICENSE](LICENSE)).
