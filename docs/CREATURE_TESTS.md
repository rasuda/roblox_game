# Pelúcio e ouro — primeira versão

Um Pelúcio compartilhado aparece em SPACE. Use o botão Pegar e caminhe para dentro
do próprio castelo. Ele fica exposto e rende 100 moedas por segundo online.
Limite inicial: uma criatura por jogador. Nova criatura aparece após 12 segundos.
Morte/reset/desconexão durante o transporte devolvem a criatura à área final.

## Persistência

DataStore separado `MagicCreatureGold_v1`: Schema, Gold, HasCreature e bloqueio de
sessão com validade de 180 segundos. UpdateAsync valida o dono da sessão antes de
salvar. Autosave a cada 30 segundos, ao depositar, ao sair e ao fechar servidor.
Falha de carregamento bloqueia entrada; nunca substitui progresso por dados vazios.
Falha de salvamento aparece no HUD e é tentada novamente. Após falhas prolongadas,
a renda pausa antes de expirar a sessão. Uma queda abrupta pode perder o progresso
desde o último salvamento. Sem renda offline. Não alterar o nome do DataStore.

## Teste com duas contas no jogo publicado

1. Entrar em duas bases distintas; observar ouro e renda no topo direito.
2. Tentar pegar o mesmo Pelúcio simultaneamente: apenas uma conta deve carregar.
3. Entrar no castelo alheio: não deve depositar. Entrar no próprio: deve depositar.
4. Esperar 10 segundos: aproximadamente +1.000 ouro, com contador de +100/s.
5. Outra conta pega o novo Pelúcio após 12 segundos; saldos devem ser independentes.
6. Sair e voltar: mesmo ouro salvo, criatura na nova base e renda retomada.
7. Morrer durante transporte: sem criatura contratada ou renda; criatura reaparece.
8. Resetar após contratar: criatura e saldo permanecem; respawn na própria base.
9. Quinta base ocupada: conta sem base aguarda e não coleta até receber uma vaga.

Para Studio, usar uma experiência de testes separada e habilitar acesso a API
Services nela. Não habilitar gravações de testes sobre os dados de produção.
Testes locais de persistência com serviços simulados:
`luatex --luaonly tests/profile_store_test.lua` (ou Lua 5.3+).

Validação automática não substitui teste multiplayer, física e DataStore real.
