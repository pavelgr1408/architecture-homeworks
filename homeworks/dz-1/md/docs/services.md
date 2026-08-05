<!--
  Паспорта микросервисов платформы «Заказ еды» (Система управления заказами).
  Собрано по трём источникам: Structurizr DSL (C4 L2), OpenAPI 3.1 (sync REST + webhooks),
  AsyncAPI 3.0 (Kafka / webhook-receivers / push).

  Плейсхолдеры для ссылок — подставить вручную:
    https://pavelgr1408.github.io/architecture-homeworks/homeworks/dz-1/openapi/      — ссылка на OpenAPI-спецификацию (при необходимости с якорем на operationId/путь)
    https://pavelgr1408.github.io/architecture-homeworks/homeworks/dz-1/asyncapi/kafka-events.html     — ссылка на AsyncAPI-спецификацию (при необходимости с якорем на канал)
    https://pavelgr1408.github.io/architecture-homeworks/homeworks/dz-1/structurizr/#SystemLandscape-001 — ссылка на представление контейнерной диаграммы (C4 L2)
    <команда>      — команда-владелец (в исходниках не задана)

  Разделы без данных в исходниках помечены TODO. Неприменимые — N/A.
-->

# Паспорта микросервисов — Система управления заказами

[← На главную](../README.md) · [← Варианты использования](./use-cases.md)

> **TL;DR:** платформа управления заказами национальной сети кафе/сэндвич-ресторанов: поиск ресторана и меню, корзина и оформление заказа, оплата, доставка, лояльность и уведомления. Синхронный обмен — HTTP/JSON REST через `api-gateway`; асинхронный — события Kafka, входящие вебхуки внешних систем и push (APNs/FCM/HMS).

Документ описывает **интеграционные интерфейсы** каждого микросервиса продуктовой системы. Сами контракты не дублируются — они ведут ссылкой на OpenAPI / AsyncAPI. Архитектура каждого сервиса — контейнер общей диаграммы C4 (Level 2) в Structurizr.

## Обзор (карта сервисов)

| # | Сервис | Bounded Context | Предоставляет (sync) | Публикует (Kafka) | Потребляет (Kafka) |
|---|---|---|---|---|---|
| 1 | `api-gateway` | Инфраструктура (N/A) | Публичный REST-фасад всей платформы | — | — |
| 2 | `auth-service` | Идентификация и доступ | REST (login, verify, authorize, me) | — | — |
| 3 | `restaurant-service` | Рестораны | REST (поиск, детали) | — | — |
| 4 | `menu-service` | Меню | REST (меню, валидация позиций) | — | — |
| 5 | `loyalty-service` | Лояльность и акции | REST (управление акциями) | `promotions.discount` | — |
| 6 | `orders-service` | Заказы | REST (корзина, заказы, ETA, выдача) | `orders.state`, `orders.status` | `orders.payments.status`, `orders.dish.status`, `orders.delivery.status`, `promotions.discount`, `production.lead.time` |
| 7 | `payment-service` | Платежи | REST (способы, платежи, POS) + вебхуки | `orders.payments.status`, `orders.payments.link` | `orders.state`, `orders.status` |
| 8 | `delivery-service` | Доставка | REST (инфо о доставке, координаты) + вебхук | `orders.delivery.status` | `orders.state`, `orders.payments.link` |
| 9 | `notification-service` | Уведомления | REST (push-токены) | — | `orders.status` |

> **Внешние / общие системы** (паспорта не ведём, приведены как зависимости): платёжный шлюз, кассовая система (POS), курьерская система, APNs / FCM / HMS, платформа карт (Яндекс.Карты / Mapkit), **система производства** (контекст «Common»: продюсер `orders.dish.status`, `production.lead.time`; консьюмер `orders.state`).

---

## 1. api-gateway

> **TL;DR:** единая точка входа для клиентских и персональных запросов; проверяет токен и маршрутизирует вызовы в продуктовые сервисы.

| | |
|---|---|
| **Bounded Context** | `Инфраструктура` (собственного контекста/ресурсов нет) |
| **Владелец** | `<команда>` |
| **Статус** | `Active` |

### 1.1. Назначение и контекст

Единая точка входа платформы. Принимает запросы клиентских (mobile/web) и персональных приложений, проверяет токен через `auth-service` и маршрутизирует вызовы в сервисы-владельцы ресурсов. Собственных бизнес-ресурсов не имеет.

### 1.2. Возможности

- **Терминация и маршрутизация** — приём HTTPS-запросов и проброс в продуктовые сервисы по HTTP REST.
- **Проверка токена/сессии** — валидация JWT через `auth-service` на каждом входящем запросе.

### 1.3. Границы

- **In scope:** аутентификационная проверка на входе, маршрутизация, единый публичный контракт.
- **Out of scope:** бизнес-логика и хранение данных (в сервисах-владельцах); выпуск/проверка токенов (это делает `auth-service`).

### 1.4. Интеграционные интерфейсы

#### 1.4.1. Предоставляемые

**Синхронные**

| Интерфейс | Протокол | Спецификация |
|---|---|---|
| Публичный REST-фасад платформы (все клиентские/персональные операции сервисов ниже доступны через gateway) | HTTPS/JSON | [OpenAPI](https://pavelgr1408.github.io/architecture-homeworks/homeworks/dz-1/openapi/) |

**Асинхронные** — N/A.

#### 1.4.2. Потребляемые

| Зависимость | Стиль | Контракт |
|---|---|---|
| `auth-service` (проверка токена, `verifyToken`) | Sync REST | [OpenAPI](https://pavelgr1408.github.io/architecture-homeworks/homeworks/dz-1/openapi/) |
| `restaurant-service`, `menu-service`, `loyalty-service`, `orders-service`, `payment-service`, `delivery-service`, `notification-service` | Sync REST | [OpenAPI](https://pavelgr1408.github.io/architecture-homeworks/homeworks/dz-1/openapi/) |

### 1.5. Архитектура

Контейнерная диаграмма (C4, Level 2): [Structurizr](https://pavelgr1408.github.io/architecture-homeworks/homeworks/dz-1/structurizr/#SystemLandscape-001)

> На общей диаграмме сервис представлен контейнером **`api-gateway`**.

### 1.6. Данные

Собственного хранилища нет (N/A).

### 1.7. Нефункциональные требования

<!-- TODO -->

### 1.8. Наблюдаемость

<!-- TODO -->

---

## 2. auth-service

> **TL;DR:** аутентификация пользователей и проверка полномочий (клиент, сотрудник кафе, владелец франшизы, сотрудник головной компании).

| | |
|---|---|
| **Bounded Context** | `Идентификация и доступ` |
| **Владелец** | `<команда>` |
| **Статус** | `Active` |

### 2.1. Назначение и контекст

Отвечает за аутентификацию пользователей и авторизацию действий: выдачу и проверку токенов, определение субъекта с ролями, проверку полномочий на действие (уровень акции local/national, привязка владельца франшизы к ресторану). Хранилище — `auth-db`.

### 2.2. Возможности

- **Аутентификация** — выдача пары токенов по учётным данным.
- **Проверка токена/сессии** — валидация JWT и возврат субъекта с ролями (internal).
- **Авторизация действия** — решение по полномочиям для конкретного действия/области (internal).

### 2.3. Границы

- **In scope:** учётные данные, токены, роли и решения авторизации.
- **Out of scope:** бизнес-проверки предметных областей (выполняют сервисы-владельцы, опираясь на решение авторизации).

### 2.4. Интеграционные интерфейсы

#### 2.4.1. Предоставляемые

**Синхронные**

| Интерфейс | Протокол | Спецификация |
|---|---|---|
| `POST /auth/login` — аутентификация | HTTP/JSON | [OpenAPI](https://pavelgr1408.github.io/architecture-homeworks/homeworks/dz-1/openapi/) |
| `POST /auth/token/verify` — проверка токена (internal) | HTTP/JSON | [OpenAPI](https://pavelgr1408.github.io/architecture-homeworks/homeworks/dz-1/openapi/) |
| `POST /auth/authorize` — проверка полномочий (internal) | HTTP/JSON | [OpenAPI](https://pavelgr1408.github.io/architecture-homeworks/homeworks/dz-1/openapi/) |
| `GET /auth/me` — текущий субъект | HTTP/JSON | [OpenAPI](https://pavelgr1408.github.io/architecture-homeworks/homeworks/dz-1/openapi/) |

**Асинхронные** — N/A.

#### 2.4.2. Потребляемые

| Зависимость | Стиль | Контракт |
|---|---|---|
| `auth-db` (PostgreSQL) | Sync (JDBC) | N/A |

### 2.5. Архитектура

Контейнерная диаграмма (C4, Level 2): [Structurizr](https://pavelgr1408.github.io/architecture-homeworks/homeworks/dz-1/structurizr/#SystemLandscape-001)

> На общей диаграмме сервис представлен контейнером **`auth-service`**.

### 2.6. Данные

Хранилище — `auth-db` (PostgreSQL): пользователи, роли, привязки. <!-- модель данных: TODO -->

### 2.7. Нефункциональные требования

<!-- TODO -->

### 2.8. Наблюдаемость

<!-- TODO -->

---

## 3. restaurant-service

> **TL;DR:** поиск и выбор ресторанов сети с учётом режима работы и признака доставки.

| | |
|---|---|
| **Bounded Context** | `Рестораны` |
| **Владелец** | `<команда>` |
| **Статус** | `Active` |

### 3.1. Назначение и контекст

Подбор ресторанов по геопозиции/адресу с признаком доставки и режимом работы; выдача деталей выбранного ресторана как контекста сессии. Геопозиция определяется на клиенте (Mapkit), бэкенд к картам не обращается. Хранилище — `restaurant-db`. (UC-FND-01)

### 3.2. Возможности

- **Поиск ресторанов** — по геопозиции/адресу, фильтры «доставка», «открыт сейчас», радиус.
- **Детали ресторана** — адрес, координаты, режим работы.

### 3.3. Границы

- **In scope:** справочник ресторанов, режим работы, признак доставки.
- **Out of scope:** построение маршрута и работа с картами (клиент, Mapkit → `Платформа карт`); меню и цены (это делает `menu-service`).

### 3.4. Интеграционные интерфейсы

#### 3.4.1. Предоставляемые

**Синхронные**

| Интерфейс | Протокол | Спецификация |
|---|---|---|
| `GET /restaurants` — поиск ресторанов | HTTP/JSON | [OpenAPI](https://pavelgr1408.github.io/architecture-homeworks/homeworks/dz-1/openapi/) |
| `GET /restaurants/{restaurantId}` — детали ресторана | HTTP/JSON | [OpenAPI](https://pavelgr1408.github.io/architecture-homeworks/homeworks/dz-1/openapi/) |

**Асинхронные** — N/A.

#### 3.4.2. Потребляемые

| Зависимость | Стиль | Контракт |
|---|---|---|
| `restaurant-db` (PostgreSQL) | Sync (JDBC) | N/A |

### 3.5. Архитектура

Контейнерная диаграмма (C4, Level 2): [Structurizr](https://pavelgr1408.github.io/architecture-homeworks/homeworks/dz-1/structurizr/#SystemLandscape-001)

> На общей диаграмме сервис представлен контейнером **`restaurant-service`**.

### 3.6. Данные

Хранилище — `restaurant-db` (PostgreSQL): рестораны, адреса/координаты, режимы работы. <!-- модель данных: TODO -->

### 3.7. Нефункциональные требования

<!-- TODO -->

### 3.8. Наблюдаемость

<!-- TODO -->

---

## 4. menu-service

> **TL;DR:** меню и актуальные цены ресторана, проверка доступности позиций.

| | |
|---|---|
| **Bounded Context** | `Меню` |
| **Владелец** | `<команда>` |
| **Статус** | `Active` |

### 4.1. Назначение и контекст

Отдаёт меню с актуальными ценами для выбранного ресторана и проверяет доступность/цены переданных позиций против актуального меню (в т. ч. при вводе заказа сотрудником и пересчёте корзины). Хранилище — `menu-db`. (UC-ORD-01/02/03)

### 4.2. Возможности

- **Меню и цены** — актуальное меню ресторана.
- **Валидация позиций** — доступность и актуальные цены, возврат недоступных позиций (сценарий E1).

### 4.3. Границы

- **In scope:** меню, цены, доступность позиций.
- **Out of scope:** корзина и расчёт итоговой суммы с акциями (это делает `orders-service`).

### 4.4. Интеграционные интерфейсы

#### 4.4.1. Предоставляемые

**Синхронные**

| Интерфейс | Протокол | Спецификация |
|---|---|---|
| `GET /restaurants/{restaurantId}/menu` — меню и цены | HTTP/JSON | [OpenAPI](https://pavelgr1408.github.io/architecture-homeworks/homeworks/dz-1/openapi/) |
| `POST /restaurants/{restaurantId}/menu/validation` — проверка позиций | HTTP/JSON | [OpenAPI](https://pavelgr1408.github.io/architecture-homeworks/homeworks/dz-1/openapi/) |

**Асинхронные** — N/A.

#### 4.4.2. Потребляемые

| Зависимость | Стиль | Контракт |
|---|---|---|
| `menu-db` (PostgreSQL) | Sync (JDBC) | N/A |

### 4.5. Архитектура

Контейнерная диаграмма (C4, Level 2): [Structurizr](https://pavelgr1408.github.io/architecture-homeworks/homeworks/dz-1/structurizr/#SystemLandscape-001)

> На общей диаграмме сервис представлен контейнером **`menu-service`**.

### 4.6. Данные

Хранилище — `menu-db` (PostgreSQL): позиции меню, цены, модификаторы, доступность. <!-- модель данных: TODO -->

### 4.7. Нефункциональные требования

<!-- TODO -->

### 4.8. Наблюдаемость

<!-- TODO -->

---

## 5. loyalty-service

> **TL;DR:** акции, промокоды и скидки: просмотр действующих предложений клиентом и управление акциями персоналом (локальные / общенациональные).

| | |
|---|---|
| **Bounded Context** | `Лояльность и акции` |
| **Владелец** | `<команда>` |
| **Статус** | `Active` |

### 5.1. Назначение и контекст

Управление акциями и скидками и их публикация. Клиент видит объединённые национальные и локальные действующие предложения; персонал создаёт/изменяет/активирует/завершает акции в пределах полномочий. Действующие акции публикуются в `orders-service` асинхронно через Kafka для расчёта корзины. Хранилище — `loyalty-db`. (UC-PRM-01/02/03/04)

### 5.2. Возможности

- **Просмотр действующих акций** — национальные + локальные по региону/ресторану.
- **Управление акциями (персонал)** — создание, изменение, активация/публикация, завершение с проверкой полномочий и приоритетов.
- **Публикация реплики акций** — событие `promotions.discount` для оформления заказа.

### 5.3. Границы

- **In scope:** акции, промо, скидки, их жизненный цикл и публикация.
- **Out of scope:** применение акций к корзине и итоговый расчёт (это делает `orders-service`); проверка полномочий субъекта (это делает `auth-service`).

### 5.4. Интеграционные интерфейсы

#### 5.4.1. Предоставляемые

**Синхронные**

| Интерфейс | Протокол | Спецификация |
|---|---|---|
| `GET /promotions` — действующие акции | HTTP/JSON | [OpenAPI](https://pavelgr1408.github.io/architecture-homeworks/homeworks/dz-1/openapi/) |
| `POST /promotions` — создать акцию (персонал) | HTTP/JSON | [OpenAPI](https://pavelgr1408.github.io/architecture-homeworks/homeworks/dz-1/openapi/) |
| `GET /promotions/{promotionId}` — параметры акции | HTTP/JSON | [OpenAPI](https://pavelgr1408.github.io/architecture-homeworks/homeworks/dz-1/openapi/) |
| `PUT /promotions/{promotionId}` — изменить акцию | HTTP/JSON | [OpenAPI](https://pavelgr1408.github.io/architecture-homeworks/homeworks/dz-1/openapi/) |
| `POST /promotions/{promotionId}/activation` — активировать/опубликовать | HTTP/JSON | [OpenAPI](https://pavelgr1408.github.io/architecture-homeworks/homeworks/dz-1/openapi/) |
| `POST /promotions/{promotionId}/completion` — завершить | HTTP/JSON | [OpenAPI](https://pavelgr1408.github.io/architecture-homeworks/homeworks/dz-1/openapi/) |

**Асинхронные** (продюсер)

| Событие / канал | Транспорт | Спецификация |
|---|---|---|
| Публикация акций и скидок | `Kafka: promotions.discount` | [AsyncAPI](https://pavelgr1408.github.io/architecture-homeworks/homeworks/dz-1/asyncapi/kafka-events.html) |

#### 5.4.2. Потребляемые

| Зависимость | Стиль | Контракт |
|---|---|---|
| `auth-service` (проверка полномочий на управление акциями) | Sync REST | [OpenAPI](https://pavelgr1408.github.io/architecture-homeworks/homeworks/dz-1/openapi/) |
| `loyalty-db` (PostgreSQL) | Sync (JDBC) | N/A |

### 5.5. Архитектура

Контейнерная диаграмма (C4, Level 2): [Structurizr](https://pavelgr1408.github.io/architecture-homeworks/homeworks/dz-1/structurizr/#SystemLandscape-001)

> На общей диаграмме сервис представлен контейнером **`loyalty-service`**.

### 5.6. Данные

Хранилище — `loyalty-db` (PostgreSQL): акции, условия, приоритеты, статусы, привязка к ресторану/сети. <!-- модель данных: TODO -->

### 5.7. Нефункциональные требования

<!-- TODO -->

### 5.8. Наблюдаемость

<!-- TODO -->

---

## 6. orders-service

> **TL;DR:** корзина, оформление и жизненный цикл заказа — расчёт суммы с учётом акций, способ получения, оценка ETA, поиск заказа и отметка выдачи персоналом.

| | |
|---|---|
| **Bounded Context** | `Заказы` |
| **Владелец** | `<команда>` |
| **Статус** | `Active` |

### 6.1. Назначение и контекст

Центральный сервис оформления: корзина, пересчёт суммы с учётом акций (по реплике `promotions.discount`), выбор способа получения, оценка времени готовности/доставки (по реплике `production.lead.time`, без синхронного обращения к производству), создание заказа и его жизненный цикл, поиск и выдача заказа персоналом. Оформленный заказ передаётся в обработку асинхронно через `orders.state` (после подтверждения оплаты). Хранилище — `orders-db`. (UC-ORD-*, UC-RCV-*)

### 6.2. Возможности

- **Корзина** — создание (в т. ч. гостевое), обновление состава, пересчёт с акциями.
- **Способ получения** — доставка / в кафе, адрес, пересчёт.
- **Оформление заказа** — фиксация состава/суммы, присвоение номера.
- **ETA и интервал получения** — оценка времени, фиксация желаемого слота.
- **Обслуживание персоналом** — поиск заказа по номеру, отметка выдачи и закрытие.

### 6.3. Границы

- **In scope:** корзина, оформление, статусная модель заказа, ETA, выдача.
- **Out of scope:** проведение платежей (это делает `payment-service`); приготовление (это делает `Система производства`); доставка (это делает `delivery-service`); правила акций (это делает `loyalty-service`).

### 6.4. Интеграционные интерфейсы

#### 6.4.1. Предоставляемые

**Синхронные**

| Интерфейс | Протокол | Спецификация |
|---|---|---|
| `POST /carts` — создать корзину | HTTP/JSON | [OpenAPI](https://pavelgr1408.github.io/architecture-homeworks/homeworks/dz-1/openapi/) |
| `GET /carts/{cartId}` — состав и сумма корзины | HTTP/JSON | [OpenAPI](https://pavelgr1408.github.io/architecture-homeworks/homeworks/dz-1/openapi/) |
| `PUT /carts/{cartId}/items` — обновить состав корзины | HTTP/JSON | [OpenAPI](https://pavelgr1408.github.io/architecture-homeworks/homeworks/dz-1/openapi/) |
| `PUT /carts/{cartId}/fulfillment` — способ получения | HTTP/JSON | [OpenAPI](https://pavelgr1408.github.io/architecture-homeworks/homeworks/dz-1/openapi/) |
| `POST /orders` — оформить заказ | HTTP/JSON | [OpenAPI](https://pavelgr1408.github.io/architecture-homeworks/homeworks/dz-1/openapi/) |
| `GET /orders/{orderId}` — получить заказ | HTTP/JSON | [OpenAPI](https://pavelgr1408.github.io/architecture-homeworks/homeworks/dz-1/openapi/) |
| `GET /orders/{orderId}/eta` — время получения | HTTP/JSON | [OpenAPI](https://pavelgr1408.github.io/architecture-homeworks/homeworks/dz-1/openapi/) |
| `PUT /orders/{orderId}/pickup-slot` — интервал получения | HTTP/JSON | [OpenAPI](https://pavelgr1408.github.io/architecture-homeworks/homeworks/dz-1/openapi/) |
| `GET /orders/search` — поиск заказа по номеру (персонал) | HTTP/JSON | [OpenAPI](https://pavelgr1408.github.io/architecture-homeworks/homeworks/dz-1/openapi/) |
| `POST /orders/{orderId}/issuance` — отметить выдачу (персонал) | HTTP/JSON | [OpenAPI](https://pavelgr1408.github.io/architecture-homeworks/homeworks/dz-1/openapi/) |

**Асинхронные** (продюсер)

| Событие / канал | Транспорт | Спецификация |
|---|---|---|
| Передача заказа в обработку | `Kafka: orders.state` | [AsyncAPI](https://pavelgr1408.github.io/architecture-homeworks/homeworks/dz-1/asyncapi/kafka-events.html) |
| Статус заказа | `Kafka: orders.status` | [AsyncAPI](https://pavelgr1408.github.io/architecture-homeworks/homeworks/dz-1/asyncapi/kafka-events.html) |

#### 6.4.2. Потребляемые

**Синхронные**

| Зависимость | Стиль | Контракт |
|---|---|---|
| `menu-service` (валидация позиций/цен) | Sync REST | [OpenAPI](https://pavelgr1408.github.io/architecture-homeworks/homeworks/dz-1/openapi/) |
| `orders-db` (PostgreSQL) | Sync (JDBC) | N/A |

**Асинхронные** (консьюмер)

| Событие / канал | Транспорт (продюсер) | Контракт |
|---|---|---|
| Статус оплаты | `Kafka: orders.payments.status` (`payment-service`) | [AsyncAPI](https://pavelgr1408.github.io/architecture-homeworks/homeworks/dz-1/asyncapi/kafka-events.html) |
| Статусы блюд | `Kafka: orders.dish.status` (`Система производства`) | [AsyncAPI](https://pavelgr1408.github.io/architecture-homeworks/homeworks/dz-1/asyncapi/kafka-events.html) |
| Статус доставки | `Kafka: orders.delivery.status` (`delivery-service`) | [AsyncAPI](https://pavelgr1408.github.io/architecture-homeworks/homeworks/dz-1/asyncapi/kafka-events.html) |
| Акции для расчёта корзины | `Kafka: promotions.discount` (`loyalty-service`) | [AsyncAPI](https://pavelgr1408.github.io/architecture-homeworks/homeworks/dz-1/asyncapi/kafka-events.html) |
| Загрузка производства (ETA) | `Kafka: production.lead.time` (`Система производства`) | [AsyncAPI](https://pavelgr1408.github.io/architecture-homeworks/homeworks/dz-1/asyncapi/kafka-events.html) |

### 6.5. Архитектура

Контейнерная диаграмма (C4, Level 2): [Structurizr](https://pavelgr1408.github.io/architecture-homeworks/homeworks/dz-1/structurizr/#SystemLandscape-001)

> На общей диаграмме сервис представлен контейнером **`orders-service`**.

### 6.6. Данные

Хранилище — `orders-db` (PostgreSQL): корзины, заказы, состав, статусы, суммы, способ получения/оплаты; локальные реплики акций и загрузки производства. <!-- модель данных: TODO -->

### 6.7. Нефункциональные требования

<!-- TODO -->

### 6.8. Наблюдаемость

<!-- TODO -->

---

## 7. payment-service

> **TL;DR:** обработка платежей — способы оплаты, онлайн-оплата, оплата на кассе/терминале, статус платежа; интеграция с платёжным шлюзом и кассовой системой.

| | |
|---|---|
| **Bounded Context** | `Платежи` |
| **Владелец** | `<команда>` |
| **Статус** | `Active` |

### 7.1. Назначение и контекст

Проведение платежей по заказу: доступные способы оплаты, инициализация онлайн-оплаты (платёжный шлюз) и оплаты на кассе/терминале (POS, в т. ч. наличные с фискальным чеком), возврат платёжной ссылки, статус платежа. Знает о заказе из события `orders.state`; итоговый статус публикует в `orders.payments.status`, платёжную ссылку для оплаты курьеру — в `orders.payments.link`. Подтверждения приходят вебхуками. Хранилище — `payment-db`. (UC-PAY-01/02/03/04)

### 7.2. Возможности

- **Способы оплаты** — по выбранному способу получения (онлайн / курьеру / в ресторане).
- **Онлайн-оплата** — инициализация в шлюзе, платёжная ссылка, статус.
- **Оплата на кассе/терминале (персонал)** — POS-платёж, включая наличные с чеком.
- **Публикация статуса и ссылки** — события `orders.payments.status`, `orders.payments.link`.

### 7.3. Границы

- **In scope:** платежи, статусы оплаты, интеграция со шлюзом и POS.
- **Out of scope:** жизненный цикл заказа (это делает `orders-service`); передача ссылки курьеру на доставке (это делает `delivery-service`, потребитель `orders.payments.link`).

### 7.4. Интеграционные интерфейсы

#### 7.4.1. Предоставляемые

**Синхронные**

| Интерфейс | Протокол | Спецификация |
|---|---|---|
| `GET /orders/{orderId}/payment-methods` — способы оплаты | HTTP/JSON | [OpenAPI](https://pavelgr1408.github.io/architecture-homeworks/homeworks/dz-1/openapi/) |
| `POST /orders/{orderId}/payments` — инициировать платёж | HTTP/JSON | [OpenAPI](https://pavelgr1408.github.io/architecture-homeworks/homeworks/dz-1/openapi/) |
| `POST /orders/{orderId}/payments/pos` — оплата на кассе (персонал) | HTTP/JSON | [OpenAPI](https://pavelgr1408.github.io/architecture-homeworks/homeworks/dz-1/openapi/) |
| `GET /orders/{orderId}/payments/{paymentId}` — статус платежа | HTTP/JSON | [OpenAPI](https://pavelgr1408.github.io/architecture-homeworks/homeworks/dz-1/openapi/) |

**Асинхронные** — вебхуки (входящие обратные вызовы) и события Kafka (продюсер)

| Событие / канал | Транспорт | Спецификация |
|---|---|---|
| Webhook платёжного шлюза | `HTTP POST /webhooks/payments/gateway` | [AsyncAPI](https://pavelgr1408.github.io/architecture-homeworks/homeworks/dz-1/asyncapi/kafka-events.html) · [OpenAPI](https://pavelgr1408.github.io/architecture-homeworks/homeworks/dz-1/openapi/) |
| Webhook кассовой системы (POS) | `HTTP POST /webhooks/payments/pos` | [AsyncAPI](https://pavelgr1408.github.io/architecture-homeworks/homeworks/dz-1/asyncapi/kafka-events.html) · [OpenAPI](https://pavelgr1408.github.io/architecture-homeworks/homeworks/dz-1/openapi/) |
| Итоговый статус оплаты | `Kafka: orders.payments.status` | [AsyncAPI](https://pavelgr1408.github.io/architecture-homeworks/homeworks/dz-1/asyncapi/kafka-events.html) |
| Платёжная ссылка (оффлайн-сценарии) | `Kafka: orders.payments.link` | [AsyncAPI](https://pavelgr1408.github.io/architecture-homeworks/homeworks/dz-1/asyncapi/kafka-events.html) |

#### 7.4.2. Потребляемые

**Синхронные**

| Зависимость | Стиль | Контракт |
|---|---|---|
| `Платёжный шлюз` (инициализация оплаты, запрос статуса) | Sync REST | внешний контракт |
| `Кассовая система (POS)` (инициализация оплаты на кассе) | Sync REST | внешний контракт |
| `payment-db` (PostgreSQL) | Sync (JDBC) | N/A |

**Асинхронные** (консьюмер)

| Событие / канал | Транспорт (продюсер) | Контракт |
|---|---|---|
| Передача заказа в обработку | `Kafka: orders.state` (`orders-service`) | [AsyncAPI](https://pavelgr1408.github.io/architecture-homeworks/homeworks/dz-1/asyncapi/kafka-events.html) |
| Статус заказа | `Kafka: orders.status` (`orders-service`) | [AsyncAPI](https://pavelgr1408.github.io/architecture-homeworks/homeworks/dz-1/asyncapi/kafka-events.html) |

### 7.5. Архитектура

Контейнерная диаграмма (C4, Level 2): [Structurizr](https://pavelgr1408.github.io/architecture-homeworks/homeworks/dz-1/structurizr/#SystemLandscape-001)

> На общей диаграмме сервис представлен контейнером **`payment-service`**.

### 7.6. Данные

Хранилище — `payment-db` (PostgreSQL): платежи, статусы, ссылки на операции во внешних системах, фискальные данные. <!-- модель данных: TODO -->

### 7.7. Нефункциональные требования

<!-- TODO: идемпотентность (Idempotency-Key), безопасность webhook (подпись) — уточнить. -->

### 7.8. Наблюдаемость

<!-- TODO -->

---

## 8. delivery-service

> **TL;DR:** интеграция доставки — сведения о доставке и координаты курьера (пулинг); интеграция с внешней курьерской системой.

| | |
|---|---|
| **Bounded Context** | `Доставка` |
| **Владелец** | `<команда>` |
| **Статус** | `Active` |

### 8.1. Назначение и контекст

Интеграция с внешней курьерской системой: назначение курьера по событию `orders.state`, сведения о доставке, координаты курьера (пулинг во внешней системе, кэш в `delivery-Redis`), передача платёжной ссылки курьеру (по `orders.payments.link`). Статус доставки публикуется в `orders.delivery.status`; входящие статусы приходят вебхуком. Хранилища — `delivery-db`, `delivery-Redis`. (UC-RCV-02, UC-PAY-03)

### 8.2. Возможности

- **Сведения о доставке** — статус и назначенный курьер по заказу.
- **Координаты курьера** — последние координаты из `delivery-Redis` (пулинг).
- **Публикация статуса доставки** — событие `orders.delivery.status`.

### 8.3. Границы

- **In scope:** интеграция доставки, статусы, координаты курьера.
- **Out of scope:** проведение оплаты (это делает `payment-service`); отображение курьера на карте (клиент, Mapkit).

### 8.4. Интеграционные интерфейсы

#### 8.4.1. Предоставляемые

**Синхронные**

| Интерфейс | Протокол | Спецификация |
|---|---|---|
| `GET /orders/{orderId}/delivery` — информация о доставке | HTTP/JSON | [OpenAPI](https://pavelgr1408.github.io/architecture-homeworks/homeworks/dz-1/openapi/) |
| `GET /orders/{orderId}/delivery/courier-location` — координаты курьера | HTTP/JSON | [OpenAPI](https://pavelgr1408.github.io/architecture-homeworks/homeworks/dz-1/openapi/) |

**Асинхронные** — вебхук (входящий) и событие Kafka (продюсер)

| Событие / канал | Транспорт | Спецификация |
|---|---|---|
| Webhook курьерской системы | `HTTP POST /webhooks/delivery/status` | [AsyncAPI](https://pavelgr1408.github.io/architecture-homeworks/homeworks/dz-1/asyncapi/kafka-events.html) · [OpenAPI](https://pavelgr1408.github.io/architecture-homeworks/homeworks/dz-1/openapi/) |
| Статус доставки | `Kafka: orders.delivery.status` | [AsyncAPI](https://pavelgr1408.github.io/architecture-homeworks/homeworks/dz-1/asyncapi/kafka-events.html) |

#### 8.4.2. Потребляемые

**Синхронные**

| Зависимость | Стиль | Контракт |
|---|---|---|
| `Курьерская система` (поиск курьера, пулинг координат, передача ссылки, запрос статуса) | Sync REST | внешний контракт |
| `delivery-db` (PostgreSQL) | Sync (JDBC) | N/A |
| `delivery-Redis` (координаты курьера) | Sync (RESP) | N/A |

**Асинхронные** (консьюмер)

| Событие / канал | Транспорт (продюсер) | Контракт |
|---|---|---|
| Передача заказа для доставки | `Kafka: orders.state` (`orders-service`) | [AsyncAPI](https://pavelgr1408.github.io/architecture-homeworks/homeworks/dz-1/asyncapi/kafka-events.html) |
| Платёжная ссылка (оплата курьеру) | `Kafka: orders.payments.link` (`payment-service`) | [AsyncAPI](https://pavelgr1408.github.io/architecture-homeworks/homeworks/dz-1/asyncapi/kafka-events.html) |

### 8.5. Архитектура

Контейнерная диаграмма (C4, Level 2): [Structurizr](https://pavelgr1408.github.io/architecture-homeworks/homeworks/dz-1/structurizr/#SystemLandscape-001)

> На общей диаграмме сервис представлен контейнером **`delivery-service`**.

### 8.6. Данные

Хранилища — `delivery-db` (PostgreSQL): доставки, статусы, курьеры; `delivery-Redis`: последние координаты курьера. <!-- модель данных: TODO -->

### 8.7. Нефункциональные требования

<!-- TODO -->

### 8.8. Наблюдаемость

<!-- TODO -->

---

## 9. notification-service

> **TL;DR:** уведомления — регистрация разрешений и push-токенов устройств; рассылка push по событиям статуса заказа через APNs / FCM / HMS.

| | |
|---|---|
| **Bounded Context** | `Уведомления` |
| **Владелец** | `<команда>` |
| **Статус** | `Active` |

### 9.1. Назначение и контекст

Регистрирует push-токены и разрешения устройств и рассылает push-уведомления только на мобильные приложения по событиям `orders.status` через APNs / FCM / HMS (асинхронно). Хранилище — `notification-db`.

### 9.2. Возможности

- **Регистрация push-токенов** — токен и разрешения устройства.
- **Управление токенами** — список и отзыв токенов.
- **Рассылка push** — по событиям статуса заказа через APNs / FCM / HMS.

### 9.3. Границы

- **In scope:** токены/разрешения, доставка push.
- **Out of scope:** формирование статусов заказа (это делает `orders-service`, продюсер `orders.status`); web-уведомления (push только на мобильные приложения).

### 9.4. Интеграционные интерфейсы

#### 9.4.1. Предоставляемые

**Синхронные**

| Интерфейс | Протокол | Спецификация |
|---|---|---|
| `POST /notifications/device-tokens` — зарегистрировать токен | HTTP/JSON | [OpenAPI](https://pavelgr1408.github.io/architecture-homeworks/homeworks/dz-1/openapi/) |
| `GET /notifications/device-tokens` — токены пользователя | HTTP/JSON | [OpenAPI](https://pavelgr1408.github.io/architecture-homeworks/homeworks/dz-1/openapi/) |
| `DELETE /notifications/device-tokens/{tokenId}` — отозвать токен | HTTP/JSON | [OpenAPI](https://pavelgr1408.github.io/architecture-homeworks/homeworks/dz-1/openapi/) |

**Асинхронные** — N/A (событий в шину не публикует).

#### 9.4.2. Потребляемые

**Синхронные / исходящие**

| Зависимость | Стиль | Контракт |
|---|---|---|
| `notification-db` (PostgreSQL) | Sync (JDBC) | N/A |
| Push-провайдеры `APNs` / `FCM` / `HMS` (отправка push) | Async (внешний) | [AsyncAPI](https://pavelgr1408.github.io/architecture-homeworks/homeworks/dz-1/asyncapi/kafka-events.html) |

**Асинхронные** (консьюмер)

| Событие / канал | Транспорт (продюсер) | Контракт |
|---|---|---|
| Статус заказа | `Kafka: orders.status` (`orders-service`) | [AsyncAPI](https://pavelgr1408.github.io/architecture-homeworks/homeworks/dz-1/asyncapi/kafka-events.html) |

### 9.5. Архитектура

Контейнерная диаграмма (C4, Level 2): [Structurizr](https://pavelgr1408.github.io/architecture-homeworks/homeworks/dz-1/structurizr/#SystemLandscape-001)

> На общей диаграмме сервис представлен контейнером **`notification-service`**.

### 9.6. Данные

Хранилище — `notification-db` (PostgreSQL): устройства, push-токены, разрешения. <!-- модель данных: TODO -->

### 9.7. Нефункциональные требования

<!-- TODO -->

### 9.8. Наблюдаемость

<!-- TODO -->
