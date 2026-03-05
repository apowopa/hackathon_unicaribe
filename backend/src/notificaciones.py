import sqlite3
from pathlib import Path

BASE_DIR = Path(__file__).resolve().parent.parent
DB_PATH = BASE_DIR / "data" / "unicaribe.db"


def init_notificaciones():
    conn = sqlite3.connect(DB_PATH)
    conn.execute("""
        CREATE TABLE IF NOT EXISTS notificaciones (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            titulo TEXT NOT NULL,
            mensaje TEXT,
            leida INTEGER DEFAULT 0,
            created_at TEXT DEFAULT (datetime('now'))
        )
    """)
    conn.commit()

    # Insertar datos dummy si la tabla está vacía
    count = conn.execute("SELECT COUNT(*) FROM notificaciones").fetchone()[0]
    if count == 0:
        datos_dummy = [
            ("Cambio de horario en Rectoría", "La Rectoría en Edificio A PB tendrá horario especial del 10 al 14 de marzo.", 0),
            ("Mantenimiento en SITE B", "El SITE B del Edificio B N1 estará fuera de servicio el viernes por mantenimiento programado.", 0),
            ("Nuevo coordinador de Ingeniería en IA", "El Dr. Héctor Fernando Gómez García asume la coordinación del programa de Inteligencia Artificial.", 1),
            ("Cierre temporal de Lab. Fisicoquímica", "El Laboratorio de Fisicoquímica en Edificio B PB permanecerá cerrado por remodelación.", 0),
            ("Convocatoria Servicio Social", "La oficina de Servicio Social en Edificio D PB abre convocatoria para el periodo primavera 2026.", 0),
            ("Actualización de Biblioteca", "La Biblioteca en Edificio D N1 amplía su horario a sábados de 9:00 a 14:00.", 1),
            ("Taller de Gastronomía cancelado", "El Taller de Alimentos y Bebidas 1 en Edificio B N1 se cancela esta semana por falta de insumos.", 0),
            ("Junta departamental CBI", "Se convoca a junta del Departamento de Ciencias Básicas e Ingenierías en Edificio G N1, Área de Maestros.", 0),
            ("Nuevo laboratorio inaugurado", "El Laboratorio de Innovación y Arquitectura de Software en Edificio G PB ya está operativo.", 1),
            ("Inscripción a posgrado abierta", "La Coordinación de Posgrado en Edificio E N1 abre inscripciones para la Maestría en Negocios Electrónicos.", 0),
        ]
        conn.executemany(
            "INSERT INTO notificaciones (titulo, mensaje, leida) VALUES (?, ?, ?)",
            datos_dummy,
        )
        conn.commit()

    conn.close()


def listar_notificaciones() -> list[dict]:
    conn = sqlite3.connect(DB_PATH)
    conn.row_factory = sqlite3.Row
    rows = conn.execute("SELECT * FROM notificaciones ORDER BY created_at DESC").fetchall()
    conn.close()
    return [dict(r) for r in rows]


def crear_notificacion(titulo: str, mensaje: str = "") -> dict:
    conn = sqlite3.connect(DB_PATH)
    conn.row_factory = sqlite3.Row
    cur = conn.execute(
        "INSERT INTO notificaciones (titulo, mensaje) VALUES (?, ?)",
        (titulo, mensaje),
    )
    conn.commit()
    row = conn.execute("SELECT * FROM notificaciones WHERE id = ?", (cur.lastrowid,)).fetchone()
    conn.close()
    return dict(row)


def marcar_leida(notificacion_id: int) -> dict | None:
    conn = sqlite3.connect(DB_PATH)
    conn.row_factory = sqlite3.Row
    conn.execute("UPDATE notificaciones SET leida = 1 WHERE id = ?", (notificacion_id,))
    conn.commit()
    row = conn.execute("SELECT * FROM notificaciones WHERE id = ?", (notificacion_id,)).fetchone()
    conn.close()
    if not row:
        return None
    return dict(row)
