#!/usr/bin/env python3
from __future__ import annotations

import html
import json
import shutil
from dataclasses import dataclass
from pathlib import Path
from typing import Any

import yaml

ROOT = Path(__file__).resolve().parents[1]
HOMEWORKS_DIR = ROOT / "homeworks"
DOCS_DIR = ROOT / "docs"
OUTPUT_DIR = DOCS_DIR / "homeworks"
RENDERED_DIR = ROOT / ".cache" / "rendered"


@dataclass(frozen=True)
class Homework:
    slug: str
    title: str
    order: int
    description: str
    source_dir: Path
    show_structurizr: bool
    show_plantuml: bool
    show_openapi: bool


def load_homework(directory: Path) -> Homework:
    config_path = directory / "homework.yml"
    if not config_path.is_file():
        raise FileNotFoundError(f"Не найден обязательный файл: {config_path}")

    config: dict[str, Any] = yaml.safe_load(config_path.read_text(encoding="utf-8")) or {}
    return Homework(
        slug=directory.name,
        title=str(config.get("title", directory.name)),
        order=int(config.get("order", 9999)),
        description=str(config.get("description", "")).strip(),
        source_dir=directory,
        show_structurizr=bool(config.get("structurizr", True)),
        show_plantuml=bool(config.get("plantuml", True)),
        show_openapi=bool(config.get("openapi", True)),
    )


def copy_tree(source: Path, destination: Path) -> None:
    if source.is_dir():
        shutil.copytree(source, destination, dirs_exist_ok=True)


def swagger_html(title: str, spec_filename: str = "openapi.yaml") -> str:
    safe_title = html.escape(title)
    config = json.dumps({"url": spec_filename, "dom_id": "#swagger-ui"}, ensure_ascii=False)
    return f"""<!doctype html>
<html lang="ru">
<head>
  <meta charset="utf-8">
  <meta name="viewport" content="width=device-width, initial-scale=1">
  <title>{safe_title} — Swagger UI</title>
  <link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/swagger-ui-dist@5/swagger-ui.css">
  <style>
    html {{ box-sizing: border-box; overflow-y: scroll; }}
    *, *::before, *::after {{ box-sizing: inherit; }}
    body {{ margin: 0; background: #fafafa; }}
  </style>
</head>
<body>
  <div id="swagger-ui"></div>
  <script src="https://cdn.jsdelivr.net/npm/swagger-ui-dist@5/swagger-ui-bundle.js"></script>
  <script src="https://cdn.jsdelivr.net/npm/swagger-ui-dist@5/swagger-ui-standalone-preset.js"></script>
  <script>
    window.onload = () => {{
      SwaggerUIBundle({{
        ...{config},
        deepLinking: true,
        displayRequestDuration: true,
        filter: true,
        persistAuthorization: true,
        presets: [SwaggerUIBundle.presets.apis, SwaggerUIStandalonePreset],
        layout: "StandaloneLayout"
      }});
    }};
  </script>
</body>
</html>
"""


def build_homework(homework: Homework) -> None:
    target = OUTPUT_DIR / homework.slug
    target.mkdir(parents=True, exist_ok=True)

    source_readme = homework.source_dir / "README.md"
    if not source_readme.is_file():
        raise FileNotFoundError(f"Не найден обязательный файл: {source_readme}")

    body = source_readme.read_text(encoding="utf-8").strip()
    sections: list[str] = [body]

    assets = homework.source_dir / "assets"
    if assets.is_dir():
        copy_tree(assets, target / "assets")

    plantuml_source = homework.source_dir / "plantuml"
    plantuml_rendered = RENDERED_DIR / "plantuml" / homework.slug
    if homework.show_plantuml and plantuml_source.is_dir():
        copy_tree(plantuml_source, target / "plantuml" / "source")
        if plantuml_rendered.is_dir():
            copy_tree(plantuml_rendered, target / "plantuml")
            svg_files = sorted((target / "plantuml").glob("*.svg"))
            if svg_files:
                sections.append("## PlantUML")
                for svg in svg_files:
                    sections.append(
                        f"### {svg.stem}\n\n"
                        f'<img class="diagram" src="plantuml/{svg.name}" '
                        f'alt="PlantUML: {html.escape(svg.stem)}">'
                    )

    structurizr_source = homework.source_dir / "structurizr"
    structurizr_rendered = RENDERED_DIR / "structurizr" / homework.slug
    if homework.show_structurizr and structurizr_source.is_dir():
        copy_tree(structurizr_source, target / "structurizr-source")
        if structurizr_rendered.is_dir():
            copy_tree(structurizr_rendered, target / "structurizr")
            sections.append(
                "## Structurizr\n\n"
                '<iframe class="arch-frame" '
                'src="structurizr/index.html" '
                'title="Интерактивная архитектурная модель Structurizr" '
                'loading="lazy"></iframe>\n\n'
                "[Открыть Structurizr на отдельной странице](structurizr/index.html)"
            )

    openapi_source = homework.source_dir / "openapi" / "openapi.yaml"
    if homework.show_openapi and openapi_source.is_file():
        openapi_target = target / "openapi"
        openapi_target.mkdir(parents=True, exist_ok=True)
        shutil.copy2(openapi_source, openapi_target / "openapi.yaml")
        (openapi_target / "index.html").write_text(
            swagger_html(homework.title),
            encoding="utf-8",
        )
        sections.append(
            "## OpenAPI / Swagger UI\n\n"
            '<iframe class="swagger-frame" '
            'src="openapi/index.html" '
            'title="Swagger UI" '
            'loading="lazy"></iframe>\n\n'
            "[Открыть Swagger UI на отдельной странице](openapi/index.html) · "
            "[Скачать OpenAPI YAML](openapi/openapi.yaml)"
        )

    (target / "index.md").write_text(
        "\n\n---\n\n".join(sections).rstrip() + "\n",
        encoding="utf-8",
    )
    (target / ".pages").write_text(
        f"title: {json.dumps(homework.title, ensure_ascii=False)}\n",
        encoding="utf-8",
    )


def build_index(homeworks: list[Homework]) -> None:
    cards = [
        "# Домашние задания",
        "",
        "Раздел создаётся автоматически из каталогов `homeworks/*`.",
        "",
    ]
    for homework in homeworks:
        description = homework.description or "Архитектурное домашнее задание."
        cards.extend(
            [
                '<div class="homework-card" markdown>',
                f"## [{homework.title}]({homework.slug}/)",
                "",
                description,
                "",
                f"`{homework.slug}`",
                "</div>",
                "",
            ]
        )

    OUTPUT_DIR.mkdir(parents=True, exist_ok=True)
    (OUTPUT_DIR / "index.md").write_text("\n".join(cards), encoding="utf-8")

    nav_lines = ["nav:", "  - Обзор: index.md"]
    for homework in homeworks:
        nav_lines.append(f"  - {json.dumps(homework.title, ensure_ascii=False)}: {homework.slug}")
    (OUTPUT_DIR / ".pages").write_text("\n".join(nav_lines) + "\n", encoding="utf-8")


def main() -> None:
    if not HOMEWORKS_DIR.is_dir():
        raise FileNotFoundError(f"Каталог домашних заданий не найден: {HOMEWORKS_DIR}")

    if OUTPUT_DIR.exists():
        shutil.rmtree(OUTPUT_DIR)
    OUTPUT_DIR.mkdir(parents=True)

    homeworks = sorted(
        (load_homework(path) for path in HOMEWORKS_DIR.iterdir() if path.is_dir()),
        key=lambda item: (item.order, item.slug),
    )
    if not homeworks:
        raise RuntimeError("В каталоге homeworks нет домашних заданий")

    for homework in homeworks:
        build_homework(homework)

    build_index(homeworks)
    print(f"Собрано домашних заданий: {len(homeworks)}")
    for homework in homeworks:
        print(f"- {homework.slug}: {homework.title}")


if __name__ == "__main__":
    main()
