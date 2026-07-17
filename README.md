# Architecture Homeworks

Готовый шаблон репозитория для публикации нескольких домашних заданий на одном сайте GitHub Pages.

Каждое домашнее задание находится в отдельном каталоге `homeworks/<идентификатор>` и может содержать:

- `README.md` — основной текст домашнего задания;
- `structurizr/workspace.dsl` — модель Structurizr DSL;
- `plantuml/*.puml` — одна или несколько PlantUML-диаграмм;
- `openapi/openapi.yaml` — спецификация OpenAPI;
- `assets/*` — изображения и другие статические файлы;
- `homework.yml` — название, порядок и параметры публикации.

## Структура

```text
.
├── .github/workflows/pages.yml
├── docs/
│   ├── index.md
│   └── stylesheets/extra.css
├── homeworks/
│   ├── dz-1/
│   └── dz-2/
├── scripts/build_site.py
├── mkdocs.yml
└── requirements.txt
```

Папка `docs/homeworks` создаётся автоматически во время сборки. Её не нужно редактировать вручную.

## Как добавить новое ДЗ

Скопируйте каталог `homeworks/dz-2`, назовите его, например, `homeworks/dz-3`, затем измените:

1. `homework.yml`;
2. `README.md`;
3. файлы в `structurizr`, `plantuml`, `openapi` и `assets`.

Меню сайта и ссылки на все материалы будут созданы автоматически.

## Локальная сборка

Требуются Python 3.12 и Docker.

```bash
python -m pip install -r requirements.txt
bash scripts/render_diagrams.sh
python scripts/build_site.py
mkdocs serve
```

Локальный сайт:

```text
http://127.0.0.1:8000/
```

## GitHub Pages

После публикации репозитория под именем `architecture-homeworks` сайт будет доступен по адресу:

```text
https://pavelgr1408.github.io/architecture-homeworks/
```

В настройках репозитория откройте **Settings → Pages** и выберите **Source: GitHub Actions**.
