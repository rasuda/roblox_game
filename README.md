# Football Transfer Heist

Branch: `football-transfer-game`

Protótipo multiplayer mobile-first de coleção, roubo de contratos, perseguição e progressão com jogadores de futebol fictícios.

## Vertical slice atual

- duas bases atribuídas automaticamente;
- uma zona Street com três contratos;
- contrato server-authoritative com estados explícitos;
- carregar, derrubar, recuperar e depositar;
- um Guardian com estados de perseguição;
- Safe Zones;
- Signing e Reveal;
- renda passiva agregada;
- treino de Speed e upgrade de treinamento;
- Slide Tackle com validação e cooldown;
- Transfer Window global;
- persistência com schema versionado e autosave;
- HUD responsiva criada por código.

## Desenvolvimento

```text
rojo serve default.project.json
```

Para testar multiplayer no Studio, use **Test → Start** com dois jogadores.

Documentação curta em [`docs/`](docs/).
