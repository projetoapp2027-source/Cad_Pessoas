import os
from contextlib import asynccontextmanager

from fastapi import FastAPI, HTTPException, status
from fastapi.middleware.cors import CORSMiddleware

from .db import init_db, pool
from .schemas import Pessoa, PessoaIn

CAMPOS = "id, nome, data_nascimento, sexo, email"


@asynccontextmanager
async def lifespan(_: FastAPI):
    init_db()
    yield
    pool.close()


app = FastAPI(title="Cadastro de Pessoas", lifespan=lifespan)

origins = [o.strip() for o in os.environ.get("CORS_ORIGINS", "*").split(",") if o.strip()]
app.add_middleware(
    CORSMiddleware,
    allow_origins=origins,
    allow_methods=["*"],
    allow_headers=["*"],
)


def _nao_encontrado(pessoa_id: int) -> HTTPException:
    return HTTPException(status.HTTP_404_NOT_FOUND, f"Registro {pessoa_id} nao encontrado.")


@app.get("/health")
def health():
    with pool.connection() as conn:
        conn.execute("SELECT 1")
    return {"status": "ok"}


@app.get("/pessoas", response_model=list[Pessoa])
def listar():
    with pool.connection() as conn:
        return conn.execute(f"SELECT {CAMPOS} FROM pessoas ORDER BY nome, id").fetchall()


@app.get("/pessoas/{pessoa_id}", response_model=Pessoa)
def obter(pessoa_id: int):
    with pool.connection() as conn:
        row = conn.execute(f"SELECT {CAMPOS} FROM pessoas WHERE id = %s", (pessoa_id,)).fetchone()
    if not row:
        raise _nao_encontrado(pessoa_id)
    return row


@app.post("/pessoas", response_model=Pessoa, status_code=status.HTTP_201_CREATED)
def incluir(dados: PessoaIn):
    with pool.connection() as conn:
        return conn.execute(
            f"INSERT INTO pessoas (nome, data_nascimento, sexo, email) "
            f"VALUES (%s, %s, %s, %s) RETURNING {CAMPOS}",
            (dados.nome, dados.data_nascimento, dados.sexo, dados.email),
        ).fetchone()


@app.put("/pessoas/{pessoa_id}", response_model=Pessoa)
def alterar(pessoa_id: int, dados: PessoaIn):
    with pool.connection() as conn:
        row = conn.execute(
            f"UPDATE pessoas SET nome = %s, data_nascimento = %s, sexo = %s, email = %s "
            f"WHERE id = %s RETURNING {CAMPOS}",
            (dados.nome, dados.data_nascimento, dados.sexo, dados.email, pessoa_id),
        ).fetchone()
    if not row:
        raise _nao_encontrado(pessoa_id)
    return row


@app.delete("/pessoas/{pessoa_id}", status_code=status.HTTP_204_NO_CONTENT)
def excluir(pessoa_id: int):
    with pool.connection() as conn:
        cur = conn.execute("DELETE FROM pessoas WHERE id = %s", (pessoa_id,))
    if cur.rowcount == 0:
        raise _nao_encontrado(pessoa_id)
