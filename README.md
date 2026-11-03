# Planejamentos 2L

Plataforma para montar o planejamento mensal dos clientes: pacote, datas de gravação (puxadas da Google Agenda) e artes por semana. Gera um arquivo pronto para mandar ao cliente pelo WhatsApp.

Tudo é gratuito: o site fica no **GitHub Pages**, os dados e as artes ficam no **Supabase** (plano free) e a agenda é lida pela **API do Google Calendar**.

Arquivos:

| Arquivo | Para que serve |
|---|---|
| `index.html` | A plataforma |
| `config.js` | Onde você cola as chaves do Supabase e do Google |
| `supabase.sql` | Cria as tabelas e a pasta das artes no Supabase |

Sem preencher o `config.js`, a página abre em **modo demonstração** (salva só no navegador). Bom para testar antes de configurar.

---

## 1. Supabase (dados e artes)

1. Crie uma conta em https://supabase.com e clique em **New project**. Região: *South America (São Paulo)*. Anote a senha do banco.
2. No menu lateral, abra **SQL Editor > New query**, cole todo o conteúdo de `supabase.sql` e clique em **Run**.
3. **Feche o cadastro público** (importante, senão qualquer pessoa cria conta):
   **Authentication > Sign In / Providers** e desligue **Allow new users to sign up**.
4. **Crie o login da equipe**: **Authentication > Users > Add user > Create new user**. Coloque e-mail e senha de cada pessoa e marque **Auto Confirm User**.
5. Copie as chaves em **Project Settings > API** (ou **Data API**):
   - **Project URL** → `SUPABASE_URL`
   - **anon public** → `SUPABASE_ANON_KEY`

   Cole no `config.js`. A chave *anon* pode ficar pública, quem protege os dados é o login.

> O plano grátis tem 1 GB para imagens. As artes são comprimidas (cerca de 200 KB cada), o que dá uns 5 mil artes. Quando estiver enchendo, use **Ajustes > Apagar imagens antigas**. Os textos continuam salvos e os arquivos já enviados aos clientes não são afetados.

> Projetos grátis do Supabase **pausam depois de 7 dias sem acesso**. Como vocês usam a plataforma só 1 ou 2 vezes por mês, isso aconteceria. Para evitar, o repositório já vem com uma tarefa automática do GitHub que acessa o Supabase a cada 3 dias. Ela é ligada no passo 2.5.

## 2. GitHub Pages (hospedagem)

1. Crie um repositório no GitHub (pode ser privado só se a conta for paga; no grátis, deixe **público**. Não tem problema: o código não tem dados de clientes).
2. Envie os arquivos `index.html`, `config.js`, `supabase.sql`, `README.md` e a pasta `.github` (**Add file > Upload files**; se a pasta oculta não aparecer, crie o arquivo `.github/workflows/manter-ativo.yml` em **Add file > Create new file** e cole o conteúdo). Pelo Claude Code isso vai junto sozinho.
3. Vá em **Settings > Pages**, em *Source* escolha **Deploy from a branch**, branch **main**, pasta **/ (root)**, e salve.
4. Em 1 ou 2 minutos o endereço aparece no topo da página, algo como
   `https://seu-usuario.github.io/planejamentos/`

5. **Ligue a tarefa que mantém o Supabase ativo:** no repositório, vá em **Settings > Secrets and variables > Actions > New repository secret** e crie dois segredos com os mesmos valores do `config.js`:
   - `SUPABASE_URL`
   - `SUPABASE_ANON_KEY`

   Depois abra a aba **Actions**, clique em **Manter Supabase ativo > Run workflow** para testar. Se ficar verde, está funcionando e passa a rodar sozinho.

   Se um dia o Supabase pausar mesmo assim, entre no painel e clique em **Restore project**. Os dados não se perdem. Faça isso em até 90 dias: depois disso o Supabase só libera o backup para baixar.

Quer usar um domínio próprio (ex.: `planejamento.2ldigitalhub.com.br`)? Em **Settings > Pages > Custom domain** coloque o endereço e crie um registro **CNAME** no seu provedor de domínio apontando para `seu-usuario.github.io`.

## 3. Primeiro acesso

Abra o endereço, entre com o e-mail e senha criados no passo 1.4 e cadastre os clientes (só uma vez). Os dados ficam salvos no Supabase: pode fechar, trocar de computador ou celular, tudo continua lá. Em **Ajustes > Baixar backup** você baixa uma cópia de tudo em um arquivo.

## 4. Google Agenda (puxar as gravações sozinho)

A plataforma lê **todas as agendas que a sua conta Google enxerga**, procura no mês os eventos com o nome do cliente no título e preenche as datas de gravação.

1. Entre em https://console.cloud.google.com com o e-mail que tem acesso às agendas e crie um projeto (ex.: *Planejamentos 2L*).
2. **APIs e serviços > Biblioteca**, busque **Google Calendar API** e clique em **Ativar**.
3. **APIs e serviços > Tela de consentimento OAuth** (ou *Google Auth Platform*):
   - Tipo de usuário: **Externo** (ou **Interno**, se vocês usam Google Workspace com domínio próprio).
   - Nome do app: *Planejamentos 2L*, e-mail de suporte: o seu.
   - Em **Escopos/Acesso a dados**, adicione `.../auth/calendar.readonly`.
   - Em **Usuários de teste/Público**, adicione os e-mails da equipe que vão puxar a agenda.
4. **APIs e serviços > Credenciais > Criar credenciais > ID do cliente OAuth**:
   - Tipo: **Aplicativo da Web**
   - **Origens JavaScript autorizadas**: o endereço do site **sem a barra no final e sem a pasta**, por exemplo `https://seu-usuario.github.io` (e o domínio próprio, se tiver).
   - Crie e copie o **ID do cliente** para `GOOGLE_CLIENT_ID` no `config.js`.
5. Suba o `config.js` atualizado no GitHub.

Na primeira vez que clicar em **Puxar da Google Agenda**, o Google abre uma janela pedindo permissão. Como o app fica em modo de teste, ele avisa que “o Google não verificou este app”: clique em **Avançado > Acessar** (é o app de vocês mesmo). O acesso dura cerca de 1 hora, depois ele pede de novo com um clique.

**Como a agenda é lida**
- Nada entra no planejamento sozinho. O que vem da agenda aparece como **sugestão** e você escolhe: **Confirmar**, **A definir** ou **Não é desse cliente**. Dá para corrigir dia e horário antes.
- O nome não precisa estar completo. *Black Car Multimarcas* acha eventos com *Black Car*; *Manella Veículos* acha *Manella*. Palavras como multimarcas, veículos, automóveis e motors são ignoradas. Esses casos aparecem com a etiqueta “nome parecido”.
- Gravações em conjunto funcionam: *Gravação Manella e StartSeg* entra para os dois clientes. E *Gravação WR Consórcios* não entra para a *WR Veículos*, só para a WR Consórcios.
- Feriados nacionais (incluindo Carnaval e Corpus Christi) são marcados sozinhos e a sugestão já vem como **A definir**. O mesmo vale para eventos com “a definir” no título. Feriados de Londrina ou de outra cidade você coloca em **Ajustes**.
- No arquivo do cliente, a data a definir aparece tracejada com a etiqueta “A definir”.
- Se você mudar uma gravação na agenda depois de confirmar, ao puxar de novo aparece “A agenda agora diz…” com um botão para atualizar.
- Se o nome na agenda for bem diferente do cadastro, coloque em **Editar pacote > Outros nomes na agenda**.

## Rotina do mês

1. Escolha o mês no topo.
2. Abra cada cliente e clique em **Puxar da Google Agenda**. Confira as gravações sugeridas e arraste as artes **na ordem**. Elas são divididas sozinhas pelas semanas conforme o pacote (4 artes = uma por semana, 8 artes = duas por semana). Dá para trocar a semana de cada uma.
   **Carrossel:** suba só a capa como arte e, no cartão dela, clique em **+ Adicionar cards** (ou arraste as imagens em cima dela). O carrossel conta como uma arte do pacote e o cliente vê a capa e desliza para os outros cards. A seta ← no card 2 transforma ele em capa.
3. **Visualizar** para conferir, **Baixar arquivo** ou **Compartilhar** (no celular abre direto o WhatsApp; no computador, **Enviar no WhatsApp Web** baixa o arquivo e abre o WhatsApp Web para você anexar na conversa).
4. Marque **Enviado ao cliente**. A lista mostra quem falta.
