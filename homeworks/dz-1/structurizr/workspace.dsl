workspace {

    model {

        client = person "Пользователь" "Клиент мобильного и web приложения" {
            tags "Person: Client"
        }

        mobileApp = softwareSystem "Mobile приложение" "Мобильное приложение клиента" {
            tags "Container: Mobile GUI"
        }

        webApp = softwareSystem "Web приложение" "Web интерфейс клиента" {
            tags "Container: Web GUI"
        }

        apiGateway = softwareSystem "API Gateway" "Единая точка входа REST API" {
            apiGatewayContainer = container "API Gateway Service" "Маршрутизация запросов" "Backend Service" {
                tags "Container: Backend Service"
            }
        }

        restaurants = softwareSystem "Сервис ресторанов" "Получение ресторанов и координат" {
            restaurantApi = container "Restaurant API" "Backend сервис ресторанов" "Backend Service" {
                tags "Container: Backend Service"
            }
            restaurantDb = container "PostgreSQL" "Данные ресторанов" "PostgreSQL" {
                tags "Container: Database"
            }
            restaurantApi -> restaurantDb "Читает и записывает данные"
        }

        menu = softwareSystem "Сервис меню" "Управление меню ресторанов" {
            menuApi = container "Menu API" "Backend сервис меню" "Backend Service" {
                tags "Container: Backend Service"
            }
            menuDb = container "PostgreSQL" "Данные меню" "PostgreSQL" {
                tags "Container: Database"
            }
            menuApi -> menuDb "Читает и записывает данные"
        }

        loyalty = softwareSystem "Сервис лояльности" "Акции, промокоды, скидки" {
            loyaltyApi = container "Loyalty API" "Backend сервис лояльности" "Backend Service" {
                tags "Container: Backend Service"
            }
            loyaltyDb = container "PostgreSQL" "Данные лояльности" "PostgreSQL" {
                tags "Container: Database"
            }
            loyaltyBroker = container "Kafka" "События лояльности" "Message Broker" {
                tags "Container: Message Broker"
            }
            loyaltyApi -> loyaltyDb "Читает и записывает данные"
        }

        orders = softwareSystem "Сервис заказов" "Корзина и оформление заказа" {
            ordersApi = container "Orders API" "Backend сервис заказов" "Backend Service" {
                tags "Container: Backend Service"
            }
            ordersDb = container "PostgreSQL" "Данные заказов" "PostgreSQL" {
                tags "Container: Database"
            }
            ordersApi -> ordersDb "Читает и записывает данные"
        }

        payments = softwareSystem "Сервис оплаты" "Обработка платежей" {
            paymentsApi = container "Payment API" "Backend сервис оплаты" "Backend Service" {
                tags "Container: Backend Service"
            }
            paymentsDb = container "PostgreSQL" "Данные платежей" "PostgreSQL" {
                tags "Container: Database"
            }
            paymentsApi -> paymentsDb "Читает и записывает данные"
        }

        delivery = softwareSystem "Сервис доставки" "Поиск курьера и статусы доставки" {
            deliveryApi = container "Delivery API" "Backend сервис доставки" "Backend Service" {
                tags "Container: Backend Service"
            }
            deliveryDb = container "PostgreSQL" "Данные доставки" "PostgreSQL" {
                tags "Container: Database"
            }
            deliveryApi -> deliveryDb "Читает и записывает данные"
        }

        auth = softwareSystem "Сервис авторизации" "Авторизация пользователей" {
            authApi = container "Auth API" "Backend сервис авторизации" "Backend Service" {
                tags "Container: Backend Service"
            }
            authDb = container "PostgreSQL" "Пользователи" "PostgreSQL" {
                tags "Container: Database"
            }
            authApi -> authDb "Читает и записывает данные"
        }

        paymentGateway = softwareSystem "Платежный шлюз" "Внешняя платежная система" {
            tags "Context: External"
        }

        deliverySystem = softwareSystem "Система доставки" "Внешняя система доставки" {
            tags "Context: External"
        }

        client -> mobileApp "Использует"
        client -> webApp "Использует"

        mobileApp -> apiGatewayContainer "REST API" {
            tags "Relation: Asynchronous"
        }
        webApp -> apiGatewayContainer "REST API" {
            tags "Relation: Asynchronous"
        }

        apiGatewayContainer -> restaurantApi "Получить рестораны" "REST API" {
            tags "Relation: Asynchronous"
        }
        apiGatewayContainer -> menuApi "Получить меню" "REST API" {
            tags "Relation: Asynchronous"
        }
        apiGatewayContainer -> loyaltyApi "Получить акции" "REST API" {
            tags "Relation: Asynchronous"
        }
        apiGatewayContainer -> ordersApi "Создать заказ" "REST API" {
            tags "Relation: Asynchronous"
        }
        apiGatewayContainer -> paymentsApi "Оплата" "REST API" {
            tags "Relation: Asynchronous"
        }
        apiGatewayContainer -> deliveryApi "Статус доставки" "REST API" {
            tags "Relation: Asynchronous"
        }
        apiGatewayContainer -> authApi "Авторизация" "REST API" {
            tags "Relation: Asynchronous"
        }

        loyaltyApi -> ordersApi "Промокоды и скидки" {
            tags "Relation: Asynchronous"
        }

        ordersApi -> paymentsApi "Передать заказ на оплату" "Kafka" {
            tags "Relation: Asynchronous"
        }

        paymentsApi -> paymentGateway "Инициализация оплаты" "REST API" {
            tags "Relation: Asynchronous"
        }
        paymentGateway -> paymentsApi "Статус оплаты" "Webhook" {
            tags "Relation: Asynchronous"
        }

        ordersApi -> deliveryApi "Передать заказ на доставку через" "Kafka" {
            tags "Relation: Asynchronous"
        }

        deliveryApi -> deliverySystem "Поиск курьера"
        deliverySystem -> deliveryApi "Статус доставки" "Webhook" {
            tags "Relation: Asynchronous"
        }
    }

    views {
        systemLandscape {
            include *
            autoLayout lr
        }
        styles {
            element "Person: Client" {
                background #8fbc8f
                color #000000
                shape Person
                description true
            }

            element "Person: Employee" {
                background #87cefa
                color #000000
                shape Person
                description true
            }

            element "Person: Partner" {
                background #d3d3d3
                color #000000
                shape Person
                description true
            }

            element "Context: Product" {
                background #87cefa
                color #000000
                shape Box
                description true
            }

            element "Context: External" {
                background #c0c0c0
                color #000000
                shape Box
                description true
            }

            element "Context: Common" {
                background #b0c4de
                color #000000
                shape Box
                description true
            }

            element "Container: Backend Service" {
                background #87cefa
                color #000000
                shape Hexagon
                description true
            }

            element "Container: Database" {
                background #87cefa
                color #000000
                shape Cylinder
                description true
            }

            element "Container: Message Broker" {
                background #87cefa
                color #000000
                shape Pipe
                description true
            }

            element "Container: Web GUI" {
                background #87cefa
                color #000000
                shape WebBrowser
                description true
            }

            element "Container: Mobile GUI" {
                background #87cefa
                color #000000
                shape MobileDevicePortrait
                description true
            }

            element "Container: Target" {
                background #008080
                color #ffffff
            }

            element "Container: Deprecated" {
                background #666633
                color #c0c0c0
            }

            element "Container: Abstract" {
                background #c0c0c0
                color #000000
                shape Folder
                opacity 50
            }

            relationship "Relation: Based On" {
                color #a9a9a9
                style Solid
                routing Direct
                opacity 50
            }

            relationship "Relation: Deleted" {
                color #ff0000
            }

            relationship "Relation: Added" {
                color #008000
            }

            relationship "Relation: Deprecated" {
                color #666633
            }

            relationship "Relation: Target" {
                color #008080
            }

            relationship "Relation: Uses" {
                color #008000
                style Dashed
                routing Direct
            }

            relationship "Relation: Synchronous" {
                color #000000
                style Solid
                routing Direct
            }

            relationship "Relation: Asynchronous" {
                color #000000
                style Dashed
                routing Direct
            }

            relationship "Relation: Interacts" {
                color #808080
                style Dashed
                routing Direct
            }
        }
    }

    configuration {
        scope softwaresystem
    }
}
