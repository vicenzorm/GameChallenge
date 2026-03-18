# 🏰 Zenith, the Endless Tower

**Ascenda, lute e sobreviva até o topo!**

Zenith é um jogo indie de ação *top-down* focado em sobrevivência e combate. Desenvolvido nativamente para o ecossistema Apple utilizando **SpriteKit** e **GameplayKit**, o projeto adota a arquitetura **ECS (Entity-Component-System)** para garantir um código modular, escalável e de alta performance. 

Fortemente inspirado na estrutura de salas e progressão do clássico *The Binding of Isaac*, Zenith traz uma reviravolta ao focar intensamente no combate de curta distância com ataques físicos e mecânicas dinâmicas de colisão. Todos os assets utilizados no projeto são *open source*.

## 🎮 Gameplay & Mecânicas

* **Objetivo:** Sobreviva às hordas de inimigos, limpe o andar e encontre a saída para subir a torre. Tente chegar ao andar mais alto que conseguir!
* **Combate Dinâmico:** Domine o espaço ao seu redor utilizando ataques físicos brutais corpo a corpo, gerenciando o tempo de recarga e o posicionamento para evitar danos.
* **Progressão Infinita:** A dificuldade aumenta gradativamente a cada novo andar da torre. Inimigos mais fortes, mais rápidos e em maior número tentarão impedir sua ascensão.
* **Arquitetura ECS:** Tudo no jogo — de jogadores a inimigos e projéteis — é uma Entidade. Habilidades, saúde e movimento são Componentes modulares, processados por Sistemas do GameplayKit.

## ⚒️ Guia para Desenvolvedores

Este repositório segue boas práticas de desenvolvimento colaborativo. Antes de contribuir, atente-se às orientações abaixo.

### 0. Idioma

O idioma de mensagens de commit ou dos nomes para as branches devem **SEMPRE** estar em **inglês**.

### 1. Organização de Branches

* `main`: branch estável, sempre pronta para deploy.
* `dev`: branch de integração, onde as features são testadas antes de irem para `main`.
* `feat-TK<numero-da-task>/<nome-da-feature>`: novas funcionalidades e novos componentes ECS.
* `fix/<nome-do-bug>`: correções de bugs.
* `hotfix/<nome-do-hotfix>`: correções urgentes que devem ir direto para produção.
* `test/<nome-do-teste>`: experimentos ou provas de conceito.

⚠️ **Nunca** faça commits diretamente em `main` ou `dev`.

### 2. Mensagens de Commit

As mensagens de commit devem ser claras, concisas e no **imperativo presente** (como se fossem instruções).

**Formato recomendado:** `<tipo>: <descrição curta>`

**Tipos mais comuns:**
* `feat`: nova funcionalidade (ex: novos inimigos, sistemas do GameplayKit).
* `fix`: correção de bug.
* `docs`: mudanças em documentação.
* `style`: formatação (sem alteração de código).
* `refactor`: refatoração de código (sem mudar comportamento, ex: otimização de um Component).
* `test`: adição ou modificação de testes.
* `chore`: manutenção, dependências, configs de assets, etc.

✅ **Exemplos:**
* `feat: add melee attack component to player entity`
* `fix: collision detection on enemy spawn`
* `docs: att README with ECS architecture`

❌ **Evite commits vagos como:**
* `ajustes no combate`
* `update inimigos`
* `testes na torre`

### 3. Testes

Os testes são parte fundamental para garantir a qualidade e a estabilidade da arquitetura do jogo. Antes de abrir um PR, **rode todos os testes locais** e certifique-se de que estão passando.

Use o framework de **Testing** padrão da Apple para escrever casos de teste.

**Testes devem cobrir:**
* Lógica de cálculo de dano, vida (HealthComponent) e morte das entidades.
* Integrações críticas de ECS (garantir que os Systems processam os Components corretamente a cada *update frame*).
* Lógica de geração de andares e *spawn* de inimigos.

📌 *Pull requests sem cobertura mínima de testes lógicos serão rejeitados.*

### 4. Pull Requests (PRs)

Os PRs devem ser pequenos, objetivos e com descrição clara do que está sendo alterado.

**Antes de abrir um PR:**
1. Certifique-se de que sua branch está atualizada com `dev`

Revise seu código localmente (verifique memory leaks com texturas do SpriteKit!).

Rode os testes e garanta que todos passam.

Descreva o que foi feito e o motivo da mudança.

Checklist para PR:

[ ] Código testado localmente

[ ] Testes criados/atualizados

[ ] Assets open source devidamente creditados (se aplicável)

[ ] Documentação ajustada (se necessário)

[ ] Sem conflitos com a dev
