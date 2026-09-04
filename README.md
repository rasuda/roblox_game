# roblox_game

Jogo Roblox desenvolvido por código e publicado automaticamente com Rojo,
GitHub Actions e Roblox Open Cloud.

## Versão atual

Primeira versão do Empire State Building:

- exterior Art Déco escalonado;
- fachada de pedra com janelas em quatro lados;
- algumas janelas iluminadas;
- entrada, marquises e plataformas de observação;
- torre, antena e luz de sinalização;
- praça, calçadas e ponto inicial com visão frontal.
- tapete voador arco-íris gratuito, controlável pelo joystick, com botões para subir e descer.

O interior ainda não faz parte desta primeira versão.

## Como testar com Rojo

1. Instale o plugin **Rojo** no Roblox Studio.
2. Instale o Rojo no computador.
3. Abra este repositório em um terminal e execute:

   ```bash
   rojo serve
   ```

4. No Roblox Studio, abra a experiência.
5. Abra o plugin Rojo, conecte em `localhost:34872` e sincronize.
6. Clique em **Play**.

## Alternativa: gerar um arquivo para abrir no Studio

Com o Rojo instalado, execute:

```bash
rojo build -o roblox_game.rbxlx
```

Depois, abra `roblox_game.rbxlx` no Roblox Studio e clique em **Play**.
