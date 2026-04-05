# 👁️ Sol Lens: MTG Scanner & Deck Builder

Um aplicativo mobile focado em utilidade para jogadores de Magic: The Gathering. Escaneie cartas físicas, consulte o Oracle text em PT-BR, entenda mecânicas instantaneamente e gerencie seus decks com análises de Inteligência Artificial.

## 📊 Status do Projeto
**Progresso Geral:** 65%
*(Marque os checkboxes com um 'x' para acompanhar o desenvolvimento)*

---

## 🗺️ Roadmap de Desenvolvimento

### 🔐 Épico 1: Fundação e Autenticação (Firebase)
- [ ] Configurar o projeto no Firebase (Auth e Firestore).
- [ ] Implementar **Google Sign-In** (Login com um toque).
- [ ] Criar a estrutura base de navegação (BottomNavigationBar) com as 3 abas principais.
- [ ] Sincronizar banco de dados local com a nuvem.

### 🔍 Épico 2: A Taverna (Busca Manual & Filtros)
- [x] Integrar a API da Scryfall (`http` package).
- [x] Desenvolver a barra de pesquisa por texto (nome/descrição).
- [x] Criar a interface de filtros avançados (Cores, Tipos, Keywords e Edições).
- [x] Exibir resultados em uma lista otimizada com paginação.

### 📸 Épico 3: O Olho do Oráculo (Scanner de Cartas)
- [x] Configurar pacote `camera` e permissões de dispositivo nativo.
- [x] Implementar o visor da câmera com mira de recorte (Overlay).
- [x] Integrar `google_mlkit_text_recognition` para OCR em tempo real.
- [x] Implementar lógica de Auto-Scan e Toque para Escanear.
- [x] Conectar o texto capturado com busca exata na Scryfall (`!"nome"`).

### 📖 Épico 4: O Grimório (Detalhes da Carta & Mecânicas)
- [x] Criar a UI da Tela de Detalhes (Imagem, Custo, Preços e Legalidade).
- [x] Implementar Seletor de Idioma (EN / PT-BR) com tradução via IA (Gemini).
- [x] Renderização de Símbolos de Mana dinâmicos.
- [ ] Lógica de exibição: Ler o texto da carta e renderizar os cards explicativos de mecânicas.
- [x] Adicionar botão "Adicionar ao Deck" (Main ou Sideboard).

### 🛡️ Épico 5: Arsenal (Gerenciamento de Decks)
- [x] Criar a UI principal da aba "Meus Decks" (Listagem com capas dinâmicas).
- [x] Implementar o fluxo de Criação e Edição de Decks (Nome, Formato, Capa).
- [x] Desenvolver a Tela de Detalhes do Deck com **Agrupamento por Tipos**.
- [x] Implementar suporte a **Sideboard** (Separação visual e lógica).
- [x] Implementar funcionalidade de incremento/decremento de quantidades (+/-).
- [x] Identidade de cor do Deck gerada automaticamente pelos símbolos de mana.

### 🖨️ Épico 6: Compartilhamento e Inteligência (Exportação & IA)
- [ ] **Geração de PDF:**
  - [ ] Desenhar o layout do PDF (Lista visual, custos e traduções).
  - [ ] Implementar o pacote `pdf` para renderizar o documento localmente.
- [x] **O Mestre (IA):**
  - [x] Integrar a API do Gemini.
  - [x] Desenvolver o prompt do sistema para análise de cartas individuais.
  - [ ] Renderizar a análise de Decks completos (Sinergias e Sugestões de melhoria).