import requests
from bs4 import BeautifulSoup
import pandas as pd
import sqlite3
from pathlib import Path
from selenium import webdriver
from selenium.webdriver.common.by import By
from selenium.webdriver.support.ui import WebDriverWait
from selenium.webdriver.support import expected_conditions as EC

mapa_unicaribe = {
    "Edificio A": {
        "PB": [
            "Rectoría",
            "Jurídico",
            "Atención y Correspondencia",
            "Unidad de Transparencia",
            "Coordinación Administrativa",
            "Recursos Humanos",
            "Compras",
            "Aula Consorcio",
            "Sala de Juntas Consorcio",
            "Aulas 3A - 7A"
        ],
        "N1": [
            "Economía y Negocios (S y P)",
            "Inclusión Educativa",
            "SITE A",
            "Aulas 8A - 14A"
        ],
        "N2": [
            "Cabina de Radio",
            "Orientación Personal",
            "Aulas 15A - 24A"
        ]
    },
    "Edificio B": {
        "PB": [
            "Secretaría Académica",
            "Desarrollo Académico",
            "Servicios Escolares",
            "Caja Múltiple",
            "Enfermería",
            "Apoyo a la Docencia",
            "Lab. Fisicoquímica",
            "Aula de Proyecciones",
            "Aulas 1B y 2B"
        ],
        "N1": [
            "Desarrollo Humano (S y P)",
            "SITE B",
            "Taller de Alimentos y Bebidas 1",
            "Taller de Panadería",
            "Oficina Talleres Gastronómicos"
        ],
        "N2": [
            "Aulas 3B - 5B"
        ]
    },
    "Edificio C": {
        "PB": [
            "Desarrollo Estudiantil (S y P)",
            "Ludoteca",
            "Idiomas (P)",
            "SITE C",
            "Aulas 5C, 15C, 16C"
        ],
        "N1": [
            "Desarrollo Humano (SAE)",
            "Cámara de Gesell",
            "Aulas 6C - 8C",
            "Aulas de Cómputo 1C - 4C"
        ],
        "N2": [
            "Aulas 9C - 14C"
        ]
    },
    "Edificio D": {
        "PB": [
            "Auditorio Principal",
            "Secretaría de Extensión y Vinculación",
            "Vinculación Universitaria",
            "Servicio Social",
            "Comunicación",
            "Sostenibilidad",
            "Prácticas Profesionales",
            "Tienda Universitaria",
            "Patronato de la Universidad"
        ],
        "N1": [
            "Biblioteca",
            "Centro de Investigación Aplicada"
        ]
    },
    "Edificio E": {
        "PB": [
            "Coordinación Gastronomía (S/O y P)",
            "SITE E",
            "Aulas 1E - 6E"
        ],
        "N1": [
            "Coordinación de Posgrado (S y P)",
            "Taller de Alimentos 2 y 3",
            "Taller de Repostería y Panadería",
            "Almacén Gastronomía",
            "Aula Sensorial",
            "Cámara Gesell"
        ],
        "N2": [
            "Coordinación Turismo Sustentable",
            "Aulas 7E, 8E, 10E - 12E",
            "Taller Turismo Salud"
        ],
        "N3": [
            "Aulas 13E - 18E"
        ]
    },
    "Edificio F": {
        "PB": [
            "Planeación y Desarrollo Institucional",
            "Planeación y Programación",
            "Gestión de la Calidad",
            "Control y Evaluación",
            "Informática",
            "Dirección de Programas de Informática",
            "Órgano de Control"
        ],
        "N1": [
            "SITE F",
            "Caja",
            "Contabilidad",
            "Sistemas",
            "Infraestructura",
            "Control Presupuestal",
            "Tesorería"
        ]
    },
    "Edificio G": {
        "PB": [
            "Academia",
            "Laboratorio de Tecnologías Ambientales",
            "Laboratorio de Microbiología e Inocuidad de Alimentos",
            "Laboratorio de Agua y Suelos",
            "Laboratorio de Redes y Sistemas de Información",
            "Laboratorio de Innovación y Arquitectura de Software"
        ],
        "N1": [
            "Área de Maestros (CBI)",
            "Laboratorio de Automatización",
            "Laboratorio de Ingeniería de Software",
            "Laboratorio de Sistemas de Control de Manufactura",
            "Laboratorio de Instalación de Software y Base de Datos (1 y 2)"
        ],
        "N2": [
            "Área de Maestros (CBI)",
            "Laboratorio de Ingeniería de Métodos",
            "Laboratorio de Logística y Cadena de Suministro",
            "Aulas Smart"
        ],
        "N3": [
            "Aulas 8G - 14G"
        ]
    }
}

class UnicaribeScrapper:
    URL_DIRECTORIO = "https://unicaribe.mx/directorio"
    URL_DIRECTORIO_DETALLE = [
        "https://unicaribe.mx/licenciaturas/ingenieria-industrial",
        "https://unicaribe.mx/licenciaturas/ingenieria-inteligencia-artificial",
        "https://unicaribe.mx/licenciaturas/ingenieria-industrias-alimentarias",
        "https://unicaribe.mx/licenciaturas/ingenieria-logistica",
        "https://unicaribe.mx/licenciaturas/ingenieria-datos",
        "https://unicaribe.mx/licenciaturas/ingenieria-ambiental",
        "https://unicaribe.mx/licenciaturas/innovacion-empresarial",
        "https://unicaribe.mx/licenciaturas/negocios-internacionales",
        "https://unicaribe.mx/licenciaturas/gastronomia",
        "https://unicaribe.mx/licenciaturas/turismo-sustentable",
        "https://unicaribe.mx/licenciaturas/turismo-alternativo",
    ]

    headers = {
        "User-Agent": "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36"
    }

    def _get(self, url: str) -> BeautifulSoup:
        response = requests.get(url, headers=self.headers)
        response.raise_for_status()
        return BeautifulSoup(response.text, "html.parser")

    def scrap_directorio(self) -> list[dict]:
        soup = self._get(self.URL_DIRECTORIO)
        tabla = soup.find("table")
        filas = tabla.find_all("tr")

        datos = []
        for fila in filas:
            celdas = fila.find_all("td")
            if len(celdas) >= 5:
                datos.append(
                    {
                        "Nombre": celdas[1].get_text(strip=True),
                        "Correo": celdas[2].get_text(strip=True),
                        "Extension": celdas[3].get_text(strip=True),
                        "Departamento": celdas[4].get_text(strip=True),
                        "Ubicacion": celdas[5].get_text(strip=True),
                    }
                )
        return datos

    def _init_driver(self) -> webdriver.Chrome:
        options = webdriver.ChromeOptions()
        options.add_argument("--headless")
        options.add_argument("--no-sandbox")
        options.add_argument("--disable-dev-shm-usage")
        return webdriver.Chrome(options=options)

    def scrap_directorio_detalle(self, url: str) -> list[dict]:
        driver = self._init_driver()
        try:
            driver.get(url)
            tab = WebDriverWait(driver, 3).until(
                EC.element_to_be_clickable((By.ID, "tabContacto"))
            )
            tab.click()
            WebDriverWait(driver, 3).until(
                EC.visibility_of_element_located((By.CSS_SELECTOR, "#contacto"))
            )
            soup = BeautifulSoup(driver.page_source, "html.parser")
            contacto = soup.select_one("#contacto")

            personas = []
            for card in contacto.select(".item-info"):
                nombre = card.select_one("h3.title")
                nombre = nombre.get_text(strip=True) if nombre else ""

                correo_tag = card.select_one("p.email a")
                correo = correo_tag.get_text(strip=True) if correo_tag else ""

                puesto_tag = card.select_one("p.puesto")
                puesto = puesto_tag.get_text(strip=True) if puesto_tag else ""

                # Telefono: parrafo que empieza con "of."
                telefono = ""
                # Biografia: parrafos sin clase que no son telefono
                biografia = ""
                for p in card.find_all("p"):
                    if p.get("class"):
                        continue
                    texto = p.get_text(strip=True)
                    if texto.startswith("of."):
                        telefono = texto
                    else:
                        biografia = texto

                img_tag = card.find_parent("div", class_="media")
                imagen = ""
                if img_tag:
                    img = img_tag.select_one("img")
                    if img and img.get("src"):
                        imagen = img["src"]

                personas.append(
                    {
                        "Correo": correo,
                        "Puesto": puesto,
                        "Telefono": telefono,
                        "Biografia": biografia,
                        "Imagen": imagen,
                    }
                )
            return personas
        finally:
            driver.quit()

    def etl(self):
        data_dir = Path("data")
        data_dir.mkdir(exist_ok=True)

        directorio_csv = data_dir / "directorio_unicaribe.csv"

        # Si ya existe el CSV base, cargar; si no, scrapear
        if directorio_csv.exists():
            print(f"Cargando datos existentes de {directorio_csv}")
            df = pd.read_csv(directorio_csv)
        else:
            print("Scrapeando directorio...")
            datos = self.scrap_directorio()
            df = pd.DataFrame(datos)

            detalle_datos = []
            for url in self.URL_DIRECTORIO_DETALLE:
                print(f"Scrapeando detalle: {url}")
                personas = self.scrap_directorio_detalle(url)
                detalle_datos.extend(personas)

            df_detalle = pd.DataFrame(detalle_datos)
            df_detalle = df_detalle.sort_values(
                "Biografia", key=lambda s: s.str.len(), ascending=False
            )
            df_detalle = df_detalle.drop_duplicates(subset="Correo", keep="first")
            df = df.merge(df_detalle, on="Correo", how="left")
            df.to_csv(directorio_csv, index=False, encoding="utf-8-sig")
            print(f"{len(df)} registros guardados en {directorio_csv}")

        # --- Dataset: Edificios ---
        edificios_rows = []
        edificio_id = 0
        for edificio in mapa_unicaribe:
            edificio_id += 1
            edificios_rows.append({"id": edificio_id, "nombre": edificio})
        df_edificios = pd.DataFrame(edificios_rows)
        df_edificios.to_csv(data_dir / "edificios.csv", index=False, encoding="utf-8-sig")
        print(f"{len(df_edificios)} edificios guardados")

        # --- Dataset: Departamentos ---
        departamentos_rows = []
        depto_id = 0
        edificio_id = 0
        for edificio, pisos in mapa_unicaribe.items():
            edificio_id += 1
            for piso, deptos in pisos.items():
                for depto in deptos:
                    depto_id += 1
                    departamentos_rows.append({
                        "id": depto_id,
                        "nombre": depto,
                        "piso": piso,
                        "edificio_id": edificio_id,
                    })
        df_departamentos = pd.DataFrame(departamentos_rows)
        df_departamentos.to_csv(data_dir / "departamentos.csv", index=False, encoding="utf-8-sig")
        print(f"{len(df_departamentos)} departamentos guardados")

        # --- Dataset: Profesores ---
        edificio_name_to_id = {r["nombre"]: r["id"] for r in edificios_rows}
        depto_lookup = {}
        for r in departamentos_rows:
            depto_lookup[(r["nombre"], r["edificio_id"])] = r["id"]

        profesores_rows = []
        prof_id = 0
        for _, row in df.iterrows():
            prof_id += 1
            d_id = None
            ubicacion = row.get("Ubicacion", "")
            departamento = row.get("Departamento", "")
            if pd.notna(ubicacion) and pd.notna(departamento):
                e_id = edificio_name_to_id.get(ubicacion)
                if e_id:
                    d_id = depto_lookup.get((departamento, e_id))

            profesores_rows.append({
                "id": prof_id,
                "nombre": row.get("Nombre", ""),
                "correo": row.get("Correo", ""),
                "extension": row.get("Extension", ""),
                "telefono": row.get("Telefono", ""),
                "puesto": row.get("Puesto", ""),
                "biografia": row.get("Biografia", ""),
                "imagen": row.get("Imagen", ""),
                "departamento_id": d_id,
            })
        df_profesores = pd.DataFrame(profesores_rows)
        df_profesores.to_csv(data_dir / "profesores.csv", index=False, encoding="utf-8-sig")
        print(f"{len(df_profesores)} profesores guardados")

        # --- Cargar a SQLite ---
        db_path = data_dir / "unicaribe.db"
        conn = sqlite3.connect(db_path)
        cur = conn.cursor()

        cur.executescript("""
            DROP TABLE IF EXISTS profesores;
            DROP TABLE IF EXISTS departamentos;
            DROP TABLE IF EXISTS edificios;

            CREATE TABLE edificios (
                id INTEGER PRIMARY KEY,
                nombre TEXT NOT NULL UNIQUE
            );

            CREATE TABLE departamentos (
                id INTEGER PRIMARY KEY,
                nombre TEXT NOT NULL,
                piso TEXT,
                edificio_id INTEGER NOT NULL,
                FOREIGN KEY (edificio_id) REFERENCES edificios(id)
            );

            CREATE TABLE profesores (
                id INTEGER PRIMARY KEY,
                nombre TEXT NOT NULL,
                correo TEXT,
                extension TEXT,
                telefono TEXT,
                puesto TEXT,
                biografia TEXT,
                imagen TEXT,
                departamento_id INTEGER,
                FOREIGN KEY (departamento_id) REFERENCES departamentos(id)
            );
        """)

        df_edificios.to_sql("edificios", conn, if_exists="append", index=False)
        df_departamentos.to_sql("departamentos", conn, if_exists="append", index=False)
        df_profesores.to_sql("profesores", conn, if_exists="append", index=False)

        conn.commit()
        conn.close()
        print(f"Base de datos guardada en {db_path}")


if __name__ == "__main__":
    scrapper = UnicaribeScrapper()
    scrapper.etl()
