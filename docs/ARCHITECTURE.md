# Architecture

## Autoridade

O servidor decide dinheiro, Speed, contratos, distância, Safe Zone, Signing, raridade, rating, renda e PvP. O cliente envia somente a intenção de usar Slide Tackle e renderiza UI.

## Camadas

- `game/replicated/Config`: valores e conteúdo data-driven.
- `game/replicated/Shared`: estados e nomes compartilhados.
- `game/server/Services`: serviços com responsabilidade única.
- `game/server/Bootstrap.server.lua`: composição e ciclo de vida.
- `game/client/Main.client.lua`: HUD e ações mobile/PC.

## Estado de contrato

`AVAILABLE → CARRIED → DROPPED → CARRIED → DEPOSITED → SIGNING → SIGNED`

Transições inválidas são rejeitadas no `ContractService`.

## Persistência

Schema versionado, `UpdateAsync`, autosave, save on leave e `BindToClose`. Em Studio sem acesso à API, o jogo usa sessão temporária e mantém o loop jogável.
