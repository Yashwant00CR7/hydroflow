## Hydraulic Assistant – Flutter + AI (RAG)

### Overview
Hydraulic Assistant is a Flutter application that provides an AI expert for hydraulic hose pressure and systems. Users can ask questions and receive safety-focused, context-aware answers sourced from a domain knowledge base.

This is an ongoing project. Future work includes AI-driven automatic UI changes so users can access orders or browse items purely through AI guidance without manually searching.

### What’s Implemented in the AI Layer
- **Retrieval-Augmented Generation (RAG)**:
  - Embeds user queries and retrieves relevant context from a vector database before asking the LLM.
  - Files: `lib/pinecone_grok_service.dart`, `lib/embedding_service.dart`.

- **Vector Store: Pinecone**:
  - Upsert/query endpoints used via REST (`upsertToPinecone`, `queryPinecone`).
  - Configured through `EnvConfig` (API key, base URL, index).

- **Embeddings**:
  - `EmbeddingService` provides a lightweight, deterministic fallback embedding (`generateSimpleEmbedding`) and an async wrapper (`generateApiEmbedding`).
  - Easily swappable for external APIs (OpenAI/Cohere, etc.).

- **LLM: Groq (OpenAI-compatible API)**:
  - Generates final answers conditioned on retrieved context (`askGroq`).
  - Supports token streaming over SSE for a responsive UI (`askGroqStream`).

- **End-to-end Answering**:
  - `answerUserQuery` and `answerUserQueryStream` implement the full pipeline: embed → retrieve context → call LLM → stream tokens.

### Primary Use Case
- **Hydraulic knowledge assistant** for:
  - Pressure ratings, safety factors, and standards
  - Hose selection and sizing
  - Calculations and troubleshooting
  - Best practices and safety guidance

### Why It’s Useful
- **Speed and accuracy**: Context retrieval improves answer relevance.
- **Safety-first guidance**: System prompt is tuned for hydraulic safety.
- **Great UX**: Streaming “typewriter” responses reduce perceived latency.
- **Persistence**: Chat history is stored locally for continuity.

### Flutter App Details (brief)
- Screen: `lib/chat_page.dart`
  - Stateful chat UI with message bubbles for user and AI.
  - **Streaming UI**: typewriter effect, blinking cursor, smooth autoscroll.
  - **Local storage**: chat history via `SharedPreferences`.
  - **Connectivity checks**: user-friendly errors and basic network tests.

### About the Company (brief)
This app is built for our client, Sabari Hydro Pneumatics, operating since 2010. They specialize in hydraulics and pneumatics solutions, with an emphasis on reliability, safety, and operational efficiency. The assistant helps technicians, engineers, and support staff make faster, safer decisions.

### Future Roadmap (in progress)
- **AI-driven automatic UI**: Dynamically adapt screens based on conversation intent.
  - Example: Jump straight to “Orders” or “Browse Items” views via AI intent detection—no manual search.
  - Surface relevant items, filters, or actions based on user goals.
- Improved embeddings using a production-grade service (OpenAI/Cohere/local models).
- Richer knowledge base ingestion and metadata for better retrieval.

### Configuration (high level)
- Create/configure `lib/config/env_config.dart` to provide:
  - Pinecone API key and base URL
  - Pinecone index name
  - Groq API key and base URL (OpenAI-compatible)

Example keys (names only; do not commit secrets):
- `EnvConfig.pineconeApiKey`
- `EnvConfig.pineconeBaseUrl`
- `EnvConfig.groqApiKey`
- `EnvConfig.groqBaseUrl`

### File Map (relevant)
- `lib/chat_page.dart`: Flutter chat UI, streaming UX, persistence
- `lib/pinecone_grok_service.dart`: RAG pipeline, Pinecone + Groq integration
- `lib/embedding_service.dart`: Embedding generation abstraction
- `lib/network_test.dart`: Connectivity diagnostics (internet/Pinecone/Groq)

### Status
Ongoing development. See “Future Roadmap” for upcoming features.



<img src="https://github.com/user-attachments/assets/7bdbe6a3-1cfd-462f-8b58-bfa7a5367942" width="250" height="500" />

<img src="https://github.com/user-attachments/assets/a21fd2f6-142c-44d0-99ce-3462b32e1ba3" width="250" height="500" />

<img src="https://github.com/user-attachments/assets/1e93f91e-0ad7-4a21-9374-9404d6d319df" width="250" height="500" />