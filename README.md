# 👁️ Sol Lens: MTG Scanner & Deck Builder

Um aplicativo mobile focado em utilidade para jogadores de Magic: The Gathering. Escaneie cartas físicas, consulte o Oracle text em PT-BR, entenda mecânicas instantaneamente e gerencie seus decks com análises de Inteligência Artificial.

## 📊 Status do Projeto
**Progresso Geral:** 60%
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
- [x] Desenvolver a barra de pesquisa por texto (nome/descrição).
- [x] Criar a interface de filtros avançados (Cores, Tipos, Keywords e Edições).
- [x] Exibir resultados em uma lista otimizada com paginação (Infinite Scroll).

### 📸 Épico 3: O Olho do Oráculo (Scanner de Cartas)
- [x] Configurar pacote `camera` e permissões de dispositivo nativo.
- [x] Implementar o visor da câmera com mira de recorte (Overlay).
- [x] Integrar `google_mlkit_text_recognition` para OCR em tempo real.
- [x] Implementar lógica de Auto-Scan e Toque para Escanear.
- [x] Conectar o texto capturado com busca exata na Scryfall (`!"nome"`).

### 📖 Épico 4: O Grimório (Detalhes da Carta & Mecânicas)
- [x] Criar a UI da Tela de Detalhes (Imagem, Custo, Preços e Legalidade).
- [x] Implementar Seletor de Idioma (EN / PT-BR) com tradução via IA (Gemini).
- [x] Renderização de Símbolos de Mana dinâmicos via Markdown customizado.
- [ ] Lógica de exibição: Ler o texto da carta e renderizar os cards explicativos de mecânicas (Dicionário Estático).
- [ ] Adicionar botão "Adicionar ao Deck" com modal listando os decks do usuário.

### 🛡️ Épico 5: Arsenal (Gerenciamento de Decks)
- [ ] Criar a UI principal da aba "Meus Decks" (Listagem de decks).
- [ ] Implementar o fluxo de Criação de novo Deck (Nome, Formato, Capa).
- [ ] Desenvolver a Tela de Detalhes do Deck (Agrupamento por tipos).
- [ ] Implementar funcionalidade de Remoção/Edição de quantidade de cartas.

### 🖨️ Épico 6: Compartilhamento e Inteligência (Exportação & IA)
- [ ] **Geração de PDF:**
  - [ ] Desenhar o layout do PDF (Lista visual, custos e traduções).
  - [ ] Implementar o pacote `pdf` para renderizar o documento localmente.
- [x] **O Mestre (IA):**
  - [x] Integrar a API do Gemini.
  - [x] Desenvolver o prompt do sistema para análise de cartas individuais.
  - [ ] Renderizar a análise de Decks completos (Dicas de Mulligan, Sinergias).
