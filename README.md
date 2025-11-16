# Atividade de Recuperação – Linguagem de Programação

Frontend em JavaScript + Backend em Haskell (JSON)  
Tema: **Cálculo de Juros Compostos**

## Descrição

Aplicação web simples que calcula o montante de juros compostos usando a fórmula:

A = P · (1 + r/n)^(n · t)

Onde:

- **P**: valor inicial (principal)
- **r**: taxa anual em decimal (ex.: 0.12 para 12%)
- **n**: número de capitalizações por ano
- **t**: tempo em anos
- **A**: montante final

O frontend envia um JSON para o backend Haskell via `POST /api/compound` e recebe o
resultado em JSON.

## Arquitetura

- **Backend**: Haskell + Scotty + Aeson
  - Endpoint: `POST /api/compound`
  - Entrada (JSON):
    ```json
    {
      "principal": 1000.0,
      "rate": 0.12,
      "timesPerYear": 12,
      "years": 2.0
    }
    ```
  - Respostas:
    - **200 OK** – JSON de sucesso:
      ```json
      {
        "amount": 1268.2418,
        "interest": 268.2418
      }
      ```
    - **400 Bad Request** – JSON de erro:
      ```json
      {
        "error": "Dados inválidos",
        "details": "Mensagem explicando o problema"
      }
      ```

- **Frontend**: HTML + JavaScript
  - Formulário com campos de entrada.
  - Chama a API via `fetch`.
  - Exibe o montante e os juros formatados em **BRL (pt-BR)**.

## Como rodar o backend localmente

Requisitos:

- Haskell Stack instalado.

Passos:

```bash
cd backend
stack build
stack run
```

O servidor iniciará em `http://localhost:8080`.

## Como testar a API via curl

```bash
curl -X POST http://localhost:8080/api/compound   -H "Content-Type: application/json"   -d '{
        "principal": 1000.0,
        "rate": 0.12,
        "timesPerYear": 12,
        "years": 2.0
      }'
```

## Como rodar o frontend localmente

Abra o arquivo `frontend/index.html` no navegador ou sirva com um servidor estático:

```bash
cd frontend
python -m http.server 8000
```

Ajuste a constante `API_URL` no `index.html` para `http://localhost:8080/api/compound`
quando estiver testando localmente.

## Deploy

### Backend

- Hospedar em um serviço gratuito (Render, Railway, Fly.io, etc.).
- Configurar a porta (ex.: variável `PORT`) e CORS.
- Exemplo de URL de produção (substitua):
  `https://seu-backend.onrender.com/api/compound`

### Frontend

- Hospedar em um serviço de estáticos (Vercel, Netlify, etc.).
- Ajustar `API_URL` no `index.html` para apontar para a URL do backend em produção.
- Exemplo de URL de produção (substitua):
  `https://seu-frontend.vercel.app`

## Links de Produção

- **Frontend (aplicação funcionando)**: https://seu-frontend.vercel.app
- **Backend (API)**: https://seu-backend.onrender.com/api/compound
