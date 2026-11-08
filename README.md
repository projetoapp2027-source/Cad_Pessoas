# Cadastro de Pessoas

CRUD simples (nome, data de nascimento, sexo, e-mail).

| Camada   | Pasta       | Tecnologia                         |
|----------|-------------|------------------------------------|
| Frontend | `Frontend/` | Flutter Web (servido por Caddy)    |
| Backend  | `Backend/`  | Python 3.12 + FastAPI + psycopg 3  |
| Banco    | Railway     | PostgreSQL (projeto `nurturing-imagination`) |

A tabela `pessoas` é criada automaticamente na inicialização da API.

## API

| Método | Rota             | Ação           |
|--------|------------------|----------------|
| GET    | `/pessoas`       | Listar         |
| GET    | `/pessoas/{id}`  | Obter um       |
| POST   | `/pessoas`       | Incluir        |
| PUT    | `/pessoas/{id}`  | Alterar        |
| DELETE | `/pessoas/{id}`  | Excluir        |
| GET    | `/health`        | Saúde          |

Documentação interativa: `<url-da-api>/docs`.

## Rodar localmente

Backend:

```powershell
cd Backend
python -m venv .venv
.venv\Scripts\activate
pip install -r requirements.txt
copy .env.example .env   # preencha DATABASE_URL com a URL pública do Postgres
uvicorn app.main:app --reload --port 8000
```

Frontend:

```powershell
cd Frontend
flutter run -d chrome --dart-define=API_URL=http://localhost:8000
```

## Deploy no Railway

Dois serviços no projeto, ambos a partir do mesmo repositório GitHub:

1. **backend**: Root Directory `/Backend`
   - Variáveis: `DATABASE_URL=${{Postgres.DATABASE_URL}}`, `CORS_ORIGINS=<url-do-frontend>`
   - Start: `uvicorn app.main:app --host 0.0.0.0 --port $PORT`
   - Healthcheck: `/health`
2. **frontend**: Root Directory `/Frontend` (usa o `Dockerfile`)
   - Variável: `API_URL=<url-publica-do-backend>` (usada no build)
