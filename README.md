# roblox_game

Primeira versão mínima para validar o fluxo entre GitHub, Rojo e Roblox Studio.

## O que aparece no teste

- uma plataforma verde;
- um ponto de nascimento laranja;
- três blocos coloridos;
- mensagens de confirmação na janela **Output** do Roblox Studio.

## Como testar com Rojo

1. Instale o plugin **Rojo** no Roblox Studio.
2. Instale o Rojo no computador.
3. Abra este repositório em um terminal e execute:

   ```bash
   rojo serve
   ```

4. No Roblox Studio, crie ou abra uma experiência vazia.
5. Abra o plugin Rojo, conecte em `localhost:34872` e sincronize.
6. Clique em **Play**.

O script `Main` aparecerá em `ServerScriptService`. Durante o teste, a janela
**Output** deve mostrar:

```text
[roblox_game] Mundo de validação carregado com sucesso.
```

## Alternativa: gerar um arquivo para abrir no Studio

Com o Rojo instalado, execute:

```bash
rojo build -o roblox_game.rbxlx
```

Depois, abra `roblox_game.rbxlx` no Roblox Studio e clique em **Play**.
