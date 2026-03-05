import sqlite3
from pathlib import Path
from contextlib import asynccontextmanager
from fastapi import FastAPI, HTTPException
from fastapi.middleware.cors import CORSMiddleware
from src.scrapper import UnicaribeScrapper
from src.notificaciones import init_notificaciones, listar_notificaciones, crear_notificacion, marcar_leida

BASE_DIR = Path(__file__).resolve().parent
DB_PATH = BASE_DIR / "data" / "unicaribe.db"


@asynccontextmanager
async def lifespan(app: FastAPI):
    if not DB_PATH.exists():
        scrapper = UnicaribeScrapper()
        scrapper.etl()
    init_notificaciones()
    yield


app = FastAPI(title="Unicaribe API", lifespan=lifespan)

app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_methods=["*"],
    allow_headers=["*"],
)


def get_db():
    conn = sqlite3.connect(DB_PATH)
    conn.row_factory = sqlite3.Row
    return conn


@app.get("/edificios")
def listar_edificios():
    conn = get_db()
    rows = conn.execute("SELECT * FROM edificios").fetchall()
    conn.close()
    return [dict(r) for r in rows]


@app.get("/edificios/{edificio_id}")
def obtener_edificio(edificio_id: int):
    conn = get_db()
    row = conn.execute("SELECT * FROM edificios WHERE id = ?", (edificio_id,)).fetchone()
    if not row:
        conn.close()
        raise HTTPException(status_code=404, detail="Edificio no encontrado")
    edificio = dict(row)
    deptos = conn.execute(
        "SELECT * FROM departamentos WHERE edificio_id = ?", (edificio_id,)
    ).fetchall()
    conn.close()
    edificio["departamentos"] = [dict(d) for d in deptos]
    return edificio


@app.get("/departamentos")
def listar_departamentos():
    conn = get_db()
    rows = conn.execute(
        """
        SELECT d.*, e.nombre as edificio_nombre
        FROM departamentos d
        JOIN edificios e ON d.edificio_id = e.id
        """
    ).fetchall()
    conn.close()
    return [dict(r) for r in rows]


@app.get("/departamentos/{depto_id}")
def obtener_departamento(depto_id: int):
    conn = get_db()
    row = conn.execute(
        """
        SELECT d.*, e.nombre as edificio_nombre
        FROM departamentos d
        JOIN edificios e ON d.edificio_id = e.id
        WHERE d.id = ?
        """,
        (depto_id,),
    ).fetchone()
    if not row:
        conn.close()
        raise HTTPException(status_code=404, detail="Departamento no encontrado")
    depto = dict(row)
    profesores = conn.execute(
        "SELECT * FROM profesores WHERE departamento_id = ?", (depto_id,)
    ).fetchall()
    conn.close()
    depto["profesores"] = [dict(p) for p in profesores]
    return depto


@app.get("/profesores")
def listar_profesores():
    conn = get_db()
    rows = conn.execute(
        """
        SELECT p.*, d.nombre as departamento_nombre, e.nombre as edificio_nombre
        FROM profesores p
        LEFT JOIN departamentos d ON p.departamento_id = d.id
        LEFT JOIN edificios e ON d.edificio_id = e.id
        """
    ).fetchall()
    conn.close()
    return [dict(r) for r in rows]


@app.get("/profesores/{profesor_id}")
def obtener_profesor(profesor_id: int):
    conn = get_db()
    row = conn.execute(
        """
        SELECT p.*, d.nombre as departamento_nombre, e.nombre as edificio_nombre
        FROM profesores p
        LEFT JOIN departamentos d ON p.departamento_id = d.id
        LEFT JOIN edificios e ON d.edificio_id = e.id
        WHERE p.id = ?
        """,
        (profesor_id,),
    ).fetchone()
    conn.close()
    if not row:
        raise HTTPException(status_code=404, detail="Profesor no encontrado")
    return dict(row)


@app.get("/notificaciones")
def get_notificaciones():
    return listar_notificaciones()


@app.post("/notificaciones")
def post_notificacion(titulo: str, mensaje: str = ""):
    return crear_notificacion(titulo, mensaje)


@app.patch("/notificaciones/{notificacion_id}/leida")
def patch_notificacion_leida(notificacion_id: int):
    result = marcar_leida(notificacion_id)
    if not result:
        raise HTTPException(status_code=404, detail="Notificación no encontrada")
    return result
