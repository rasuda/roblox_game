# Testes no Roblox Studio

Use `Test → Start` com dois jogadores.

1. Confirme que cada jogador recebe um clube diferente.
2. Pegue o mesmo contrato simultaneamente e confirme apenas um vencedor.
3. Morra ou saia carregando; o contrato deve cair/retornar ao mercado.
4. Entre na Safe Zone correta; Guardian deve retornar e Signing começar.
5. Acerte Slide Tackle no portador; contrato deve cair e respeitar cooldown.
6. Aguarde Reveal; jogador deve aparecer no elenco e gerar renda.
7. Fique no treino; Speed deve subir. Compre upgrade e compare o ganho.
8. Reinicie o servidor com API Services habilitada e valide persistência.
9. Force falha de DataStore desabilitando API Services; a sessão deve continuar.
10. Reduza temporariamente `TransferWindowSeconds` e valide o refresh global.
