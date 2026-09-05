# Neon Desert City — Roblox

Cidade original inspirada na escala, iluminação e atmosfera da Las Vegas Strip. O mapa é gerado integralmente por código, com arquitetura modular e foco em desempenho no iPhone.

## MVP atual

- Strip com 3 faixas por sentido, canteiro, calçadas, cruzamentos e sinalização;
- cinco complexos originais: bairro europeu, skyline metropolitano, resort de vidro, pirâmide temática e resort tropical;
- grande fonte preparada para futura coreografia de água, luz e música;
- palmeiras, postes, tráfego cenográfico e bairros de transição;
- deserto e montanhas em todo o horizonte;
- ciclo automático de dia/noite com fachadas, placas e monumentos luminosos;
- `StreamingEnabled`, baixa quantidade de luzes reais e fachadas simplificadas;
- tapete voador e VW Nivus GTS dirigível preservados da versão anterior.

## Parâmetros principais

Edite `src/server/CityModules/CityConfig.lua` para alterar:

- comprimento e largura da Strip;
- recuo, distância entre complexos e escala de altura dos prédios;
- faixas, calçadas e distância entre cruzamentos;
- densidade de palmeiras, postes, tráfego e prédios secundários;
- duração e horários do ciclo dia/noite;
- raios de streaming e sombras decorativas;
- tamanho do mundo e distância das montanhas.

Os construtores dos cinco complexos ficam em `src/server/CityModules/Complexes.lua`. A geração das ruas, deserto e decoração urbana fica em `CityBuilder.lua`.

## Testar no Roblox Studio

### Com Rojo

1. Instale o plugin **Rojo** no Roblox Studio.
2. No diretório deste repositório, execute `rojo serve`.
3. Abra a experiência no Studio, conecte o plugin em `localhost:34872` e sincronize.
4. Clique em **Play** e confira a janela **Output**.

### Gerar um Place completo

```bash
rojo build default.project.json --output roblox_game.rbxlx
```

Abra `roblox_game.rbxlx` no Studio e clique em **Play**.

## Teste mobile recomendado

1. No Studio, use **Test > Device Emulator > iPhone**.
2. Valide caminhada, direção do carro e tapete voador.
3. Em **View > Stats**, observe memória, renderização e física.
4. Publique e faça o teste final no iPhone real, especialmente durante a noite.

## Regeneração segura

Ao iniciar, o gerador remove o cenário existente do `Workspace` e limpa o `Terrain`. Sistemas em `ServerScriptService`, `StarterPlayer`, `ReplicatedStorage` e demais serviços são preservados. Para preservar manualmente um objeto do `Workspace`, adicione o atributo booleano `PreserveAcrossCityRebuild = true`.
