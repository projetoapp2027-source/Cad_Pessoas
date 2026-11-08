import os

from dotenv import load_dotenv
from psycopg.rows import dict_row
from psycopg_pool import ConnectionPool

load_dotenv()

DATABASE_URL = os.environ.get("DATABASE_URL")
if not DATABASE_URL:
    raise RuntimeError("Variavel de ambiente DATABASE_URL nao definida.")

pool = ConnectionPool(
    DATABASE_URL,
    min_size=1,
    max_size=5,
    kwargs={"row_factory": dict_row},
    open=False,
)

DDL = """
CREATE TABLE IF NOT EXISTS pessoas (
    id               SERIAL PRIMARY KEY,
    nome             VARCHAR(150) NOT NULL,
    data_nascimento  DATE         NOT NULL,
    sexo             CHAR(1)      NOT NULL CHECK (sexo IN ('M', 'F', 'O')),
    email            VARCHAR(254) NOT NULL
);
"""


def init_db() -> None:
    pool.open()
    with pool.connection() as conn:
        conn.execute(DDL)
