workspace {

    model {
        user_client = person "Пользователь" {
            description "Клиент мобильного и web приложения"
            tags "Person: Client"
        }
        sys_paymentGateway = softwareSystem "Платежный шлюз" {
            description "Внешняя платежная система"
            tags "Context: External"
        }
        sys_deliverySystem = softwareSystem "Курьерская система" {
            description "Внешняя система доставки и оплаты мерчантов"
            tags "Context: External"
        }
        sys_orderSystem = softwareSystem "Система управления заказами" {
            description "Платформа управления заказами"
            tags "Context: Product"

            cont_mobileApp = container "mobile-app" {
                description "Мобильное приложение клиента"
                technology "Mobile Application"
                tags "Container: Mobile GUI"
                user_client -> this "Использует" {
                    tags "Relation: Uses"
                }
            }
            cont_webApp = container "web-app" {
                description "Web интерфейс клиента"
                technology "Web Application"
                tags "Container: Web GUI"
                user_client -> this "Использует" {
                    tags "Relation: Uses"
                }
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
                this -> db_restaurantDb "CRUD операции" "JDBC" {
                    tags "Relation: Synchronous"
                }
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
                this -> db_menuDb "CRUD операции" "JDBC" {
                    tags "Relation: Synchronous"
                }
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
                this -> db_loyaltyDb "CRUD операции" "JDBC" {
                    tags "Relation: Synchronous"
                }
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
                this -> db_ordersDb "CRUD операции" "JDBC" {
                    tags "Relation: Synchronous"
                }
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
                this -> db_paymentsDb "CRUD операции" "JDBC" {
                    tags "Relation: Synchronous"
                }
                this -> sys_paymentGateway "Инициализация оплаты" "HTTP REST" {
                    tags "Relation: Synchronous"
                }
                this -> sys_paymentGateway "Запрос статуса оплаты" "HTTP REST" {
                    tags "Relation: Synchronous"
                }
                sys_paymentGateway -> this "Статус оплаты" "Webhook" {
                    tags "Relation: Asynchronous"
                }
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
                this -> db_deliveryDb "CRUD операции" "JDBC" {
                    tags "Relation: Synchronous"
                }
                cont_ordersApi -> this "Передача заказа на доставку" "Kafka" {
                    tags "Relation: Asynchronous"
                }
                this -> sys_deliverySystem "Поиск курьера" "HTTP REST" {
                    tags "Relation: Synchronous"
                }
                sys_deliverySystem -> this "Статус доставки" "Webhook" {
                    tags "Relation: Asynchronous"
                }
                this -> cont_ordersApi "передача статуса доставки" "Kafka" {
                    tags "Relation: Asynchronous"
                }
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
                this -> db_authDb "CRUD операции" "JDBC" {
                    tags "Relation: Synchronous"
                }
            }
            cont_apiGateway = container "api-gateway" {
                description "Единая точка входа"
                technology "API Gateway"
                tags "Container: Backend Service"
                this -> cont_restaurantApi "Получение ресторанов" "HTTP REST" {
                    tags "Relation: Synchronous"
                }
                this -> cont_menuApi "Получение меню" "HTTP REST" {
                    tags "Relation: Synchronous"
                }
                this -> cont_loyaltyApi "Получение акций" "HTTP REST" {
                    tags "Relation: Synchronous"
                }
                this -> cont_ordersApi "Создание заказа" "HTTP REST" {
                    tags "Relation: Synchronous"
                }
                this -> cont_paymentsApi "Оплата заказа" "HTTP REST" {
                    tags "Relation: Synchronous"
                }
                this -> cont_authApi "Авторизация" "HTTP REST" {
                    tags "Relation: Synchronous"
                }
                cont_mobileApp -> this "Выполнить запрос пользователя" "HTTPS REST" {
                    tags "Relation: Synchronous"
                }
                cont_webApp -> this "Выполнить запрос пользователя" "HTTPS REST" {
                    tags "Relation: Synchronous"
                }
                this -> cont_deliveryApi "Получение информации о доставке/курьере" "HTTP REST" {
                    tags "Relation: Synchronous"
                }
            }
            cont_broker = container "kafka" {
                description "Message Broker"
                tags "Container: Message Broker"
                cont_ordersApi -> this "produser. orders.state: Передача заказа" "Kafka" {
                    tags "Relation: Asynchronous"
                }
                this -> cont_paymentsApi "consumer. orders.state: Получение заказа" "Kafka" {
                    tags "Relation: Asynchronous"
                }
                cont_loyaltyApi -> this "produser. promotions.discount: Передача промо и акций" "Kafka" {
                    tags "Relation: Asynchronous"
                }
                this -> cont_ordersApi "consumer. promotions.discount: Получение промо и акций" "Kafka" {
                    tags "Relation: Asynchronous"
                }
            }
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
                width 1500
                height 200
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
                color #FFFFFF
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
