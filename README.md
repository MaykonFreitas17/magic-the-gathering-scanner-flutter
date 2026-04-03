# 👁️ Sol Lens: MTG Scanner & Deck Builder

Um aplicativo mobile focado em utilidade para jogadores de Magic: The Gathering. Escaneie cartas físicas, consulte o Oracle text em PT-BR, entenda mecânicas instantaneamente e gerencie seus decks com análises de Inteligência Artificial.

## 📊 Status do Projeto
**Progresso Geral:** 25%
*(Marque os checkboxes com um 'x' para acompanhar o desenvolvimento)*

---

## 🗺️ Roadmap de Desenvolvimento

### 🔐 Épico 1: Fundação e Autenticação (Supabase / Firebase)
- [ ] Configurar o projeto no Firebase/Supabase (Auth e Database).
- [ ] Criar interface de Login e Cadastro de Usuário.
- [ ] Implementar a lógica de sessão (manter logado).
- [ ] Criar a estrutura base de navegação (BottomNavigationBar) com as 3 abas principais (Busca, Scanner, Meus Decks).

### 🔍 Épico 2: A Taverna (Busca Manual & Filtros)
- [x] Integrar a API da Scryfall (`http` package).
- [ ] Desenvolver a barra de pesquisa por texto (nome/descrição).
- [ ] Criar a interface de filtros avançados:
  - [ ] Filtro por Cores (Símbolos de Mana).
  - [ ] Filtro por Custo de Mana (CMC).
  - [ ] Filtro por Edição/Data de Lançamento.
- [x] Exibir resultados em uma lista otimizada (ListView/GridView) com paginação (Infinite Scroll).

### 📸 Épico 3: O Olho do Oráculo (Scanner de Cartas)
- [ ] Configurar pacote `camera` e permissões de dispositivo nativo.
- [ ] Implementar o visor da câmera aberto diretamente ao clicar na aba.
- [ ] Integrar `google_mlkit_text_recognition` para capturar o título da carta física.
- [ ] Conectar o texto capturado pelo OCR com a busca exata da Scryfall.
- [ ] Criar a lógica de transição: Câmera -> Feedback de Loading -> Tela de Detalhes.

### 📖 Épico 4: O Grimório (Detalhes da Carta & Mecânicas)
- [x] Criar a UI da Tela de Detalhes (Imagem grande, Custo, Oracle Text, Preços e Legalidade).
- [ ] Construir o Dicionário Estático de Mecânicas:
  - [ ] Criar uma tabela/lista de mapeamento no código para habilidades (ex: *Flying*, *Crew*, *Trample*).
  - [ ] Vincular exemplos práticos em PT-BR a essas mecânicas.
- [ ] Lógica de exibição: Ler o texto da carta e renderizar os cards explicativos na tela dinamicamente.
- [ ] Adicionar botão "Adicionar ao Deck" com modal listando os decks do usuário.

### 🛡️ Épico 5: Arsenal (Gerenciamento de Decks)
- [ ] Criar a UI principal da aba "Meus Decks" (Listagem de decks, ex: "Boros Vehicles (Pioneer)", "Deadly Discovery").
- [ ] Implementar o fluxo de Criação de novo Deck (Nome, Formato, Imagem de Capa).
- [ ] Desenvolver a Tela de Detalhes do Deck (Lista de cartas agrupadas por tipo: Terrenos, Criaturas, etc).
- [ ] Adicionar atalhos de "Adicionar Carta" dentro do deck (via Busca Manual ou abrindo o Scanner diretamente ali).
- [ ] Implementar funcionalidade de Remoção/Edição de quantidade de cartas no deck.

### 🖨️ Épico 6: Compartilhamento e Inteligência (Exportação & IA)
- [ ] **Geração de PDF:**
  - [ ] Desenhar o layout do PDF (Lista visual das cartas, custos e traduções).
  - [ ] Implementar o pacote `pdf` para renderizar o documento localmente.
  - [ ] Adicionar botão para salvar/compartilhar o arquivo final gerado.
- [ ] **O Mestre (IA):**
  - [ ] Integrar a API do Gemini.
  - [ ] Desenvolver o prompt do sistema que envia a lista do deck para a IA.
  - [ ] Renderizar a resposta da IA na tela (Dicas de Mulligan, Sinergias principais, Como pilotar o deck).
