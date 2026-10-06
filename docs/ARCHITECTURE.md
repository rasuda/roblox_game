# Architecture v2

O servidor decide dinheiro, Speed, acesso às zonas, contratos, ratings, Editions, tackle, assinatura, renda e upgrades. O cliente envia somente intenção de tackle/venda e renderiza UI.

- `Config`: conteúdo e balanceamento data-driven.
- `PlayerDataService`: schema, DataStore, autosave e snapshots.
- `ClubService`: graybox, seis bases, quatro zonas e showroom.
- `ContractService`: máquina de estados, spawn, carry, drop, signing e reveal.
- `GuardianService`: quatro máquinas de estado em um scheduler central.
- `EconomyService`: renda agregada e venda.
- `TrainingService`: Speed, chuteiras, slots e upgrades.
- `PvPService`: slide tackle server-authoritative.
- `TransferWindowService`: relógio e refresh compartilhado.

Estado: `AVAILABLE → CARRIED → DROPPED → CARRIED → DEPOSITED → SIGNING → SIGNED`.
