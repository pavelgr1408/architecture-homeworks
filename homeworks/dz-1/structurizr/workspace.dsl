workspace {

    model {

        user_client = person "Пользователь" {
            description "Клиент мобильного и web приложения"
            tags "Person: Client"
        }
        sys_orderSystem = softwareSystem "Система управления заказами" {
            description "Платформа управления заказами"
            tags "Context: Product"
            cont_mobileApp = container "mobile-app" {
                description "Мобильное приложение клиента"
                technology "Mobile Application"
                tags "Container: Mobile GUI"
                
            }
            cont_webApp = container "web-app" {
                description "Web интерфейс клиента"
                technology "Web Application"
                tags "Container: Web GUI"
            }
            cont_apiGateway = container "api-gateway" {
                description "Единая точка входа REST API"
                technology "REST API Gateway"
                tags "Container: Backend Service"
            }
            db_restaurantDb = container "restaurant-db" {
                description "Данные ресторанов"
                technology "PostgreSQL"
                tags "Container: Database"
            }
            cont_restaurantApi = container "restaurant-service" {
                description "Сервис ресторанов"
                technology "Java, Spring Boot"
                tags "Container: Backend Service"
            }
            
            db_menuDb = container "menu-db" {
                description "Данные меню"
                technology "PostgreSQL"
                tags "Container: Database"
            }
            cont_menuApi = container "menu-service" {
                description "Сервис управления меню"
                technology "Java, Spring Boot"
                tags "Container: Backend Service"
            }
            db_loyaltyDb = container "loyalty-db" {
                description "Данные лояльности"
                technology "PostgreSQL"
                tags "Container: Database"
            }
            cont_loyaltyApi = container "loyalty-service" {
                description "Акции, промокоды и скидки"
                technology "Java, Spring Boot"
                tags "Container: Backend Service"
            }
            db_ordersDb = container "orders-db" {
                description "Данные заказов"
                technology "PostgreSQL"
                tags "Container: Database"
            }
            cont_ordersApi = container "orders-service" {
                description "Корзина и оформление заказа"
                technology "Java, Spring Boot"
                tags "Container: Backend Service"
            }
            db_paymentsDb = container "payment-db" {
                description "Данные платежей"
                technology "PostgreSQL"
                tags "Container: Database"
            }
            cont_paymentsApi = container "payment-service" {
                description "Обработка платежей"
                technology "Java, Spring Boot"
                tags "Container: Backend Service"
            }
            db_deliveryDb = container "delivery-db" {
                description "Данные доставки"
                technology "PostgreSQL"
                tags "Container: Database"
            }
            cont_deliveryApi = container "delivery-service" {
                description "Интеграция доставки"
                technology "Java, Spring Boot"
                tags "Container: Backend Service"
            }
            db_authDb = container "auth-db" {
                description "Пользователи"
                technology "PostgreSQL"
                tags "Container: Database"
            }
            cont_authApi = container "auth-service" {
                description "Авторизация пользователей"
                technology "Java, Spring Boot"
                tags "Container: Backend Service"
            }
            
            cont_restaurantApi -> db_restaurantDb "CRUD операции" "DB" {
                tags "Relation: Synchronous"
            }
            cont_menuApi -> db_menuDb "CRUD операции" "DB" {
                tags "Relation: Synchronous"
            }
            cont_loyaltyApi -> db_loyaltyDb "CRUD операции" "DB" {
                tags "Relation: Synchronous"
            }
            cont_ordersApi -> db_ordersDb "CRUD операции" "DB" {
                tags "Relation: Synchronous"
            }
            cont_paymentsApi -> db_paymentsDb "CRUD операции" "DB" {
                tags "Relation: Synchronous"
            }
            cont_deliveryApi -> db_deliveryDb "CRUD операции" "DB" {
                tags "Relation: Synchronous"
            }
            cont_authApi -> db_authDb "CRUD операции" "DB" {
                tags "Relation: Synchronous"
            }
            cont_apiGateway -> cont_restaurantApi "Получение ресторанов" "HTTP REST" {
                tags "Relation: Synchronous"
            }
            cont_apiGateway -> cont_menuApi "Получение меню" "HTTP REST" {
                tags "Relation: Synchronous"
            }
            cont_apiGateway -> cont_loyaltyApi "Получение акций" "HTTP REST" {
                tags "Relation: Synchronous"
            }
            cont_apiGateway -> cont_ordersApi "Создание заказа" "HTTP REST" {
                tags "Relation: Synchronous"
            }
            cont_apiGateway -> cont_paymentsApi "Оплата заказа" "HTTP REST" {
                tags "Relation: Synchronous"
            }
            cont_apiGateway -> cont_deliveryApi "Получение статуса доставки" "HTTP REST" {
                tags "Relation: Synchronous"
            }
            cont_apiGateway -> cont_authApi "Авторизация" "HTTP REST" {
                tags "Relation: Synchronous"
            }
            cont_loyaltyApi -> cont_ordersApi "Применение промокодов и скидок" "HTTP REST" {
                tags "Relation: Synchronous"
            }
            cont_ordersApi -> cont_paymentsApi "Передача заказа на оплату" "HTTP REST" {
                tags "Relation: Synchronous"
            }
            cont_ordersApi -> cont_deliveryApi "Передача заказа на доставку" "HTTP REST" {
                tags "Relation: Synchronous"
            }
        }

        sys_paymentGateway = softwareSystem "Платежный шлюз" {
            description "Внешняя платежная система"
            tags "Context: External"
        }

        sys_deliverySystem = softwareSystem "Система доставки" {
            description "Внешняя система доставки"
            tags "Context: External"
        }

        user_client -> cont_mobileApp "Использует" {
            tags "Relation: Uses"
        }

        user_client -> cont_webApp "Использует" {
            tags "Relation: Uses"
        }

        cont_mobileApp -> cont_apiGateway "Использует" {
            tags "Relation: Uses"
        }

        cont_webApp -> cont_apiGateway "Использует" {
            tags "Relation: Uses"
        }

        cont_paymentsApi -> sys_paymentGateway "Инициализация оплаты" "HTTP REST" {
            tags "Relation: Synchronous"
        }

        sys_paymentGateway -> cont_paymentsApi "Статус оплаты" "Webhook" {
            tags "Relation: Asynchronous"
        }

        cont_deliveryApi -> sys_deliverySystem "Поиск курьера" "HTTP REST" {
            tags "Relation: Synchronous"
        }

        sys_deliverySystem -> cont_deliveryApi "Статус доставки" "Webhook" {
            tags "Relation: Asynchronous"
        }
    }

    views {
        theme default
        systemLandscape {
            include *
        }
        container sys_orderSystem {
            include *
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
                color #FFFFFF
                style Solid
                routing Direct
            }
            relationship "Relation: Asynchronous" {
                color #FFFFFF
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
}
