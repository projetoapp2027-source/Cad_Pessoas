from datetime import date
from typing import Literal

from pydantic import BaseModel, EmailStr, Field, field_validator


class PessoaIn(BaseModel):
    nome: str = Field(min_length=1, max_length=150)
    data_nascimento: date
    sexo: Literal["M", "F", "O"]
    email: EmailStr

    @field_validator("nome")
    @classmethod
    def nome_nao_vazio(cls, v: str) -> str:
        v = v.strip()
        if not v:
            raise ValueError("O nome e obrigatorio.")
        return v

    @field_validator("data_nascimento")
    @classmethod
    def data_nao_futura(cls, v: date) -> date:
        if v > date.today():
            raise ValueError("A data de nascimento nao pode estar no futuro.")
        return v


class Pessoa(PessoaIn):
    id: int
