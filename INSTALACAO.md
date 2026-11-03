# Instalação

Cada skill é uma pasta com um arquivo `SKILL.md`. O formato é o mesmo em todos os ambientes; muda apenas o lugar onde a pasta é colocada. Escolha o ambiente que você usa.

## Requisitos

Para o instalador e o empacotador, basta um terminal com `bash`. O empacotador usa o utilitário `zip` (ou, se ele não existir, o Python 3). Para executar as auditorias sobre um projeto, o Claude precisa de acesso ao código e, nos testes dinâmicos, a um ambiente de teste acessível. Ferramentas opcionais melhoram a cobertura: `gitleaks` ou `trufflehog` (segredos no histórico do Git), `npm audit`, `pip-audit` ou `composer audit` (dependências), `depcheck`, `license-checker`, `curl`, `k6` ou `ab` (rajadas de requisições), Playwright e `axe-core` (acessibilidade e rastreadores).

## Opção 1. Claude Code (recomendada)

### Instalação pessoal, para todos os projetos

```bash
git clone https://github.com/opaulomarcondes/skiils-auditoria-app.git
cd skiils-auditoria-app
./scripts/install.sh
```

O script copia as quatro skills para `~/.claude/skills/`. Para instalar apenas algumas, informe os nomes:

```bash
./scripts/install.sh teste-seguranca-27-regras teste-antiabuso-custos-35-regras
```

Para manter as skills ligadas ao repositório, de modo que um `git pull` atualize tudo sem nova instalação, use links simbólicos:

```bash
./scripts/install.sh --link
```

### Instalação em um projeto específico

Para que as skills acompanhem o projeto e sejam compartilhadas com a equipe pelo controle de versão:

```bash
./scripts/install.sh --projeto /caminho/do/meu-app
```

As skills são colocadas em `/caminho/do/meu-app/.claude/skills/`.

### Instalação manual

```bash
mkdir -p ~/.claude/skills
cp -r skills/* ~/.claude/skills/
```

### Verificação

Abra o Claude Code (reinicie a sessão se ele já estava aberto) e peça: "liste as skills disponíveis". As quatro devem aparecer. Também é possível chamá-las diretamente pelo nome, por exemplo `/teste-seguranca-27-regras`.

## Opção 2. Aplicativo Claude (web e desktop)

1. Gere os pacotes: `./scripts/package.sh`. Os arquivos `.zip` ficam na pasta `dist/`, cada um contendo a pasta da skill com o `SKILL.md` na raiz dela.
2. No Claude, abra as Configurações, entre na seção de Capacidades (Capabilities) e localize Skills. O nome exato do menu pode variar conforme a versão do aplicativo e o tipo de plano.
3. Escolha a opção de enviar uma skill e selecione o `.zip`. Repita para cada skill.
4. Ative a chave de cada skill depois do envio.

Em planos de equipe e empresariais, o envio de skills pode depender de permissão do administrador da organização.

## Opção 3. Claude Agent SDK ou outros agentes compatíveis

Qualquer agente que leia o padrão de skills em pastas (`SKILL.md` com `name` e `description` no frontmatter) pode usar estas skills. Copie as pastas de `skills/` para o diretório de skills configurado no seu agente.

## Instalação da skill europeia

A `auditoria-app-seguranca-juridica-ue` executa as skills de segurança e jurídica como etapas internas. Para ela funcionar plenamente, instale as quatro juntas. Se apenas a europeia estiver instalada, ela usa os títulos das regras como roteiro mínimo, com cobertura menos detalhada.

## Atualização

Com clone e instalação por cópia, atualize assim:

```bash
cd skiils-auditoria-app
git pull
./scripts/install.sh
```

Com `--link`, basta o `git pull`. No aplicativo Claude, gere novos `.zip` e envie-os novamente, substituindo os anteriores.

## Remoção

```bash
rm -rf ~/.claude/skills/teste-seguranca-27-regras \
       ~/.claude/skills/teste-conformidade-juridica-35-regras \
       ~/.claude/skills/teste-antiabuso-custos-35-regras \
       ~/.claude/skills/auditoria-app-seguranca-juridica-ue
```

## Solução de problemas

Se uma skill não aparecer, confirme que a pasta contém `SKILL.md` diretamente (e não uma pasta extra dentro dela), que o frontmatter começa na primeira linha com `---` e que `name` coincide com o nome da pasta. Se o aplicativo recusar o `.zip`, verifique se ele contém a pasta da skill na raiz, e não os arquivos soltos. Se o instalador reclamar de permissão, execute `chmod +x scripts/*.sh`.
