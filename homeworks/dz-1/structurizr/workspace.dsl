    workspace {

    model {
        user_client = person "Пользователь" {
            description "Клиент мобильного и web приложения"
            tags "Person: Client"
        }
        user_staff = person "Сотрудник кафе" {
            description "Сотрудник кафе"
            tags "Person: Employee"
        }
        user_staff2 = person "Владелец франшизы" {
            description "Владелец франшизы"
            tags "Person: Employee"
        }
        user_staff3 = person "Сотрудник головной компании" {
            description "Сотрудник головной компании"
            tags "Person: Employee"
        }
        sys_paymentGateway = softwareSystem "Платежный шлюз" {
            description "Внешняя платежная система"
            tags "Context: External"
        }
        sys_FCM = softwareSystem "Firebase Cloud Messaging" {
            description "Firebase Cloud Messaging"
            tags "Context: External"
        }
        sys_apple = softwareSystem "Apple Push Notification service" {
            description "Apple Push Notification service"
            tags "Context: External"
        }
        sys_huawei = softwareSystem "Huawei Mobile Services" {
            description "Huawei Mobile Services"
            tags "Context: External"
        }
        sys_posSystem = softwareSystem "Кассовая система" {
            description "POS/касса ресторана: наличные, карта на терминале, фискализация"
            tags "Context: External"
        }
        sys_maps = softwareSystem "Платформа карт. Яндекс-карты" {
            description "латформа карт. Яндекс-карты"
            tags "Context: External"
        }
        sys_deliverySystem = softwareSystem "Курьерская система" {
            description "Внешняя система доставки и оплаты мерчантов"
            tags "Context: External"
        }
        sys_orderProductionSystem = softwareSystem "Система производства" {
            description "Система производства/приготовления"
            tags "Context: Common"
        }
        sys_orderSystem = softwareSystem "Система управления заказами" {
            description "Платформа управления заказами"
            tags "Context: Product"
            cont_mobileAppleApp = container "mobile-app-apple" {
                description "Мобильное приложение клиента apple"
                technology "Swift"
                tags "Container: Mobile GUI"
                rel_con_1 = user_client -> this "Использует" {
                    tags "Relation: Uses"
                }
                rel_con_2 = sys_apple -> this "Отправка push" {
                    tags "Relation: Asynchronous"
                }
                rel_con_3 = this -> sys_maps "Mapkit карт" "HTTP" {
                    tags "Relation: Asynchronous"
                }
                rel_depl_01 = sys_apple -> this "Взаимодействует" {
                    tags "Relation: Asynchronous"
                }
                rel_depl_02 = this -> sys_maps "Взаимодействует" "HTTP" {
                    tags "Relation: Asynchronous"
                }
            }
            cont_mobileAndroidApp = container "mobile-app-Android" {
                description "Мобильное приложение клиента Android"
                technology "Kotlin"
                tags "Container: Mobile GUI"
                rel_con_4 = user_client -> this "Использует" {
                    tags "Relation: Uses"
                }
                rel_con_5 = sys_FCM -> this "Отправка push" {
                    tags "Relation: Asynchronous"
                }
                rel_con_6 = sys_huawei -> this "Отправка push" {
                    tags "Relation: Asynchronous"
                }
                rel_con_7 = this -> sys_maps "Mapkit карт" "HTTP" {
                    tags "Relation: Asynchronous"
                }
                rel_depl_03 = sys_FCM -> this "Взаимодействует" {
                    tags "Relation: Asynchronous"
                }
                rel_depl_04 = sys_huawei -> this "Взаимодействует" {
                    tags "Relation: Asynchronous"
                }
                rel_depl_05 = this -> sys_maps "Взаимодействует" "HTTP" {
                    tags "Relation: Asynchronous"
                }
            }
            cont_webApp = container "web-app" {
                description "Web интерфейс клиента"
                technology "Web Application"
                tags "Container: Web GUI"
                rel_con_8 = user_client -> this "Использует" {
                    tags "Relation: Uses"
                }
                rel_con_9 = this -> sys_maps "Mapkit карт" "HTTP" {
                    tags "Relation: Asynchronous"
                }
                rel_depl_06 = this -> sys_maps "Взаимодействует" "HTTP" {
                    tags "Relation: Asynchronous"
                }
            }
            cont_webAppStaff = container "web-app-staff" {
                description "Web интерфейс персонала"
                technology "Web Application"
                tags "Container: Web GUI"
                rel_con_10 = user_staff -> this "Использует" {
                    tags "Relation: Uses"
                }
                rel_con_11 = user_staff2 -> this "Управляет локальными акциями" {
                    tags "Relation: Uses"
                }
                rel_con_12 = user_staff3 -> this "Управления национальными акциями" {
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
                rel_con_13 = this -> db_restaurantDb "CRUD операции" "JDBC" {
                    tags "Relation: Synchronous"
                }
                rel_depl_07 = this -> db_restaurantDb "Взаимодействует" "JDBC" {
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
                rel_con_14 = this -> db_menuDb "CRUD операции" "JDBC" {
                    tags "Relation: Synchronous"
                }
                rel_depl_08 = this -> db_menuDb "Взаимодействует" "JDBC" {
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
                rel_con_15 = this -> db_loyaltyDb "CRUD операции" "JDBC" {
                    tags "Relation: Synchronous"
                }
                rel_depl_09 = this -> db_loyaltyDb "Взаимодействует" "JDBC" {
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
                rel_con_16 = this -> db_ordersDb "CRUD операции" "JDBC" {
                    tags "Relation: Synchronous"
                }
                rel_depl_10 = this -> db_ordersDb "Взаимодействует" "JDBC" {
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
                rel_con_17 = this -> db_paymentsDb "CRUD операции" "JDBC" {
                    tags "Relation: Synchronous"
                }
                rel_con_18 = this -> sys_paymentGateway "Инициализация оплаты/получение платежной ссылки" "HTTP REST" {
                    tags "Relation: Synchronous"
                }
                rel_con_19 = this -> sys_paymentGateway "Запрос статуса оплаты" "HTTP REST" {
                    tags "Relation: Synchronous"
                }
                rel_con_20 = sys_paymentGateway -> this "Статус оплаты" "Webhook" {
                    tags "Relation: Asynchronous"
                }
                rel_con_21 = this -> sys_posSystem "Инициализация оплаты на кассе/терминале" "HTTP REST" {
                    tags "Relation: Synchronous"
                }
                rel_con_22 = sys_posSystem -> this "Подтверждение оплаты при получении" "Webhook" {
                    tags "Relation: Asynchronous"
                }
                rel_depl_11 = this -> db_paymentsDb "Взаимодействует" "JDBC" {
                    tags "Relation: Synchronous"
                }
                rel_depl_12 = this -> sys_paymentGateway "Взаимодействует" "HTTP REST" {
                    tags "Relation: Synchronous"
                }
                rel_depl_13 = sys_paymentGateway -> this "Взаимодействует" "Webhook" {
                    tags "Relation: Asynchronous"
                }
                rel_depl_14 = this -> sys_posSystem "Взаимодействует" "HTTP REST" {
                    tags "Relation: Synchronous"
                }
                rel_depl_15 = sys_posSystem -> this "Взаимодействует" "Webhook" {
                    tags "Relation: Asynchronous"
                }
            }
            db_deliveryDb = container "delivery-db" {
                description "Данные доставки"
                technology "PostgreSQL"
                tags "Container: Database"
            }
            db_deliveryRedis = container "delivery-Redis" {
                description "Координаты курьера"
                technology "Redis"
                tags "Container: Database"
            }
            cont_deliveryApi = container "delivery-service" {
                description "Интеграция доставки"
                technology "Java, Spring Boot"
                tags "Container: Backend Service"
                rel_con_23 = this -> db_deliveryDb "CRUD операции" "JDBC" {
                    tags "Relation: Synchronous"
                }
                rel_con_24 = this -> db_deliveryRedis "Запись координат курьера" "RESP" {
                    tags "Relation: Synchronous"
                }
                rel_con_25 = this -> sys_deliverySystem "Поиск курьера" "HTTP REST" {
                    tags "Relation: Synchronous"
                }
                rel_con_26 = this -> sys_deliverySystem "Получить координаты курьера (пулинг)" "HTTP REST" {
                    tags "Relation: Synchronous"
                }
                rel_con_27 = sys_deliverySystem -> this "Статус доставки" "Webhook" {
                    tags "Relation: Asynchronous"
                }
                rel_con_28 = this -> sys_deliverySystem "Передать линк на оплату" "HTTP REST" {
                    tags "Relation: Synchronous"
                }
                rel_con_29 = this -> sys_deliverySystem "Запросить статус" "HTTP REST" {
                    tags "Relation: Synchronous"
                }
                rel_depl_16 = this -> db_deliveryDb "Взаимодействует" "JDBC" {
                    tags "Relation: Synchronous"
                }
                rel_depl_17 = this -> db_deliveryRedis "Взаимодействует" "RESP" {
                    tags "Relation: Synchronous"
                }
                rel_depl_18 = this -> sys_deliverySystem "Взаимодействует" "HTTP REST" {
                    tags "Relation: Synchronous"
                }
                rel_depl_19 = sys_deliverySystem -> this "Взаимодействует" "Webhook" {
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
                rel_con_30 = this -> db_authDb "CRUD операции" "JDBC" {
                    tags "Relation: Synchronous"
                }
                rel_depl_20 = this -> db_authDb "Взаимодействует" "JDBC" {
                    tags "Relation: Synchronous"
                }
            }
            db_notificationDb = container "notification-db" {
                description "Данные уведомлений"
                technology "PostgreSQL"
                tags "Container: Database"
            }
            cont_notificationApi = container "notification-service" {
                description "Сервис уведомлений"
                technology "Java, Spring Boot"
                tags "Container: Backend Service"
                rel_con_31 = this -> db_notificationDb "CRUD операции" "JDBC" {
                    tags "Relation: Synchronous"
                }
                rel_con_32 = this -> sys_apple "Отправить уведомления на apple" "HTTP" {
                    tags "Relation: Synchronous"
                }
                rel_con_33 = this -> sys_FCM "Отправить уведомления на android" "HTTP" {
                    tags "Relation: Synchronous"
                }
                rel_con_34 = this -> sys_huawei "Отправить уведомления на android-huawei" "HTTP" {
                    tags "Relation: Synchronous"
                }
                rel_depl_21 = this -> db_notificationDb "Взаимодействует" "JDBC" {
                    tags "Relation: Synchronous"
                }
                rel_depl_22 = this -> sys_apple "Взаимодействует" "HTTP" {
                    tags "Relation: Synchronous"
                }
                rel_depl_23 = this -> sys_FCM "Взаимодействует" "HTTP" {
                    tags "Relation: Synchronous"
                }
                rel_depl_24 = this -> sys_huawei "Взаимодействует" "HTTP" {
                    tags "Relation: Synchronous"
                }
            }
            cont_apiGateway = container "api-gateway" {
                description "Единая точка входа"
                technology "API Gateway"
                tags "Container: Backend Service"
                rel_con_35 = this -> cont_restaurantApi "Получение ресторанов" "HTTP REST" {
                    tags "Relation: Synchronous"
                }
                rel_con_36 = this -> cont_menuApi "Получение меню" "HTTP REST" {
                    tags "Relation: Synchronous"
                }
                rel_con_37 = this -> cont_loyaltyApi "Получение/управление акциями" "HTTP REST" {
                    tags "Relation: Synchronous"
                }
                rel_con_38 = this -> cont_ordersApi "Создание заказа" "HTTP REST" {
                    tags "Relation: Synchronous"
                }
                rel_con_39 = this -> cont_paymentsApi "Оплата заказа" "HTTP REST" {
                    tags "Relation: Synchronous"
                }
                rel_con_40 = this -> cont_authApi "Авторизация" "HTTP REST" {
                    tags "Relation: Synchronous"
                }
                rel_con_41 = this -> cont_notificationApi "Получить разрешения и push-токен" "HTTP REST" {
                    tags "Relation: Synchronous"
                }
                rel_con_42 = this -> cont_deliveryApi "Получение информации о доставке/курьере" "HTTP REST" {
                    tags "Relation: Synchronous"
                }
                rel_con_43 = this -> cont_deliveryApi "Получить координаты курьера (пулинг)" "HTTP REST" {
                    tags "Relation: Synchronous"
                }
                rel_con_44 = this -> cont_ordersApi "Поиск заказа и отметка выдачи (персонал)" "HTTP REST" {
                    tags "Relation: Synchronous"
                }
                rel_con_45 = cont_mobileAppleApp -> this "Выполнить запрос пользователя" "HTTPS REST" {
                    tags "Relation: Synchronous"
                }
                rel_con_46 = cont_mobileAndroidApp -> this "Выполнить запрос пользователя" "HTTPS REST" {
                    tags "Relation: Synchronous"
                }
                rel_con_47 = cont_webApp -> this "Выполнить запрос пользователя" "HTTPS REST" {
                    tags "Relation: Synchronous"
                }
                rel_con_48 = cont_webAppStaff -> this "Выполнить запрос персонала" "HTTPS REST" {
                    tags "Relation: Synchronous"
                }
                rel_depl_25 = this -> cont_restaurantApi "Взаимодействует" "HTTP REST" {
                    tags "Relation: Synchronous"
                }
                rel_depl_26 = this -> cont_menuApi "Взаимодействует" "HTTP REST" {
                    tags "Relation: Synchronous"
                }
                rel_depl_27 = this -> cont_loyaltyApi "Взаимодействует" "HTTP REST" {
                    tags "Relation: Synchronous"
                }
                rel_depl_28 = this -> cont_ordersApi "Взаимодействует" "HTTP REST" {
                    tags "Relation: Synchronous"
                }
                rel_depl_29 = this -> cont_paymentsApi "Взаимодействует" "HTTP REST" {
                    tags "Relation: Synchronous"
                }
                rel_depl_30 = this -> cont_authApi "Взаимодействует" "HTTP REST" {
                    tags "Relation: Synchronous"
                }
                rel_depl_31 = this -> cont_notificationApi "Взаимодействует" "HTTP REST" {
                    tags "Relation: Synchronous"
                }
                rel_depl_32 = this -> cont_deliveryApi "Взаимодействует" "HTTP REST" {
                    tags "Relation: Synchronous"
                }
                rel_depl_33 = cont_mobileAppleApp -> this "Взаимодействует" "HTTPS REST" {
                    tags "Relation: Synchronous"
                }
                rel_depl_34 = cont_mobileAndroidApp -> this "Взаимодействует" "HTTPS REST" {
                    tags "Relation: Synchronous"
                }
                rel_depl_35 = cont_webApp -> this "Взаимодействует" "HTTPS REST" {
                    tags "Relation: Synchronous"
                }
                rel_depl_36 = cont_webAppStaff -> this "Взаимодействует" "HTTPS REST" {
                    tags "Relation: Synchronous"
                }
            }
            cont_broker = container "kafka" {
                description "Message Broker"
                tags "Container_vertically: Message Broker"
                rel_con_49 = cont_ordersApi -> this "produser.orders.state: Передача заказа" "Kafka" {
                    tags "Relation: Asynchronous"
                }
                rel_con_50 = this -> cont_paymentsApi "consumer.orders.state: Получение заказа" "Kafka" {
                    tags "Relation: Asynchronous"
                }
                rel_con_51 = cont_paymentsApi -> this "produser.orders.payments.link: Передача платежной ссылки" "Kafka" {
                    tags "Relation: Asynchronous"
                }
                rel_con_52 = cont_paymentsApi -> this "produser.orders.payments.status: Передать статус оплаты" "Kafka" {
                    tags "Relation: Asynchronous"
                }
                rel_con_53 = cont_loyaltyApi -> this "produser.promotions.discount: Передача промо и акций" "Kafka" {
                    tags "Relation: Asynchronous"
                }
                rel_con_54 = this -> cont_ordersApi "consumer.promotions.discount: Получение промо и акций" "Kafka" {
                    tags "Relation: Asynchronous"
                }
                rel_con_55 = this -> sys_orderProductionSystem "consumer.orders.state: Получение заказа на приготовление" "Kafka" {
                    tags "Relation: Asynchronous"
                }
                rel_con_56 = sys_orderProductionSystem -> this "produser.orders.dish.status: Передача статусов блюд" "Kafka" {
                    tags "Relation: Asynchronous"
                }
                rel_con_57 = this -> cont_ordersApi "consumer.orders.dish.status: Получение статусов блюд" "Kafka" {
                    tags "Relation: Asynchronous"
                }
                rel_con_58 = this -> cont_ordersApi "consumer.orders.payments.status: Получение статусов оплаты" "Kafka" {
                    tags "Relation: Asynchronous"
                }
                rel_con_59 = this -> cont_deliveryApi "consumer.orders.payments.link: Получение платежной ссылки" "Kafka" {
                    tags "Relation: Asynchronous"
                }
                rel_con_60 = this -> cont_deliveryApi "consumer.orders.state: Получение заказа для доставки" "Kafka" {
                    tags "Relation: Asynchronous"
                }
                rel_con_61 = cont_deliveryApi -> this "produser.orders.delivery.status: Передача статуса доставки" "Kafka" {
                    tags "Relation: Asynchronous"
                }
                rel_con_62 = this -> cont_ordersApi "consumer.orders.delivery.status: Получение статусов доставки" "Kafka" {
                    tags "Relation: Asynchronous"
                }
                rel_con_63 = cont_ordersApi -> this "produser.orders.status: Передача статуса заказа" "Kafka" {
                    tags "Relation: Asynchronous"
                }
                rel_con_64 = this -> cont_notificationApi "consumer.orders.status: Получение статуса заказа" "Kafka" {
                    tags "Relation: Asynchronous"
                }
                rel_con_65 = sys_orderProductionSystem -> this "produser.production.lead.time: Время загрузки производства блюд" "Kafka" {
                    tags "Relation: Asynchronous"
                }
                rel_con_66 = this -> cont_ordersApi "consumer.production.lead.time: Время загрузки производства блюд" "Kafka" {
                    tags "Relation: Asynchronous"
                }
                rel_con_67 = this -> cont_paymentsApi "consumer.orders.status: Получение статуса заказа" "Kafka" {
                    tags "Relation: Asynchronous"
                }
                rel_depl_37 = cont_ordersApi -> this "Взаимодействует in/out" "Kafka" {
                    tags "Relation: Asynchronous"
                }
                rel_depl_38 = cont_paymentsApi -> this "Взаимодействует in/out" "Kafka" {
                    tags "Relation: Asynchronous"
                }
                rel_depl_39 = cont_loyaltyApi -> this "Взаимодействует" "Kafka" {
                    tags "Relation: Asynchronous"
                }
                rel_depl_40 = sys_orderProductionSystem -> this "Взаимодействует in/out" "Kafka" {
                    tags "Relation: Asynchronous"
                }
                rel_depl_41 = cont_deliveryApi -> this "Взаимодействует in/out" "Kafka" {
                    tags "Relation: Asynchronous"
                }
                rel_depl_42 = cont_notificationApi -> this "Взаимодействует" "Kafka" {
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
            exclude rel_depl_01 rel_depl_02 rel_depl_03 rel_depl_04
            exclude rel_depl_05 rel_depl_06 rel_depl_07 rel_depl_08
            exclude rel_depl_09 rel_depl_10 rel_depl_11 rel_depl_12
            exclude rel_depl_13 rel_depl_14 rel_depl_15 rel_depl_16
            exclude rel_depl_17 rel_depl_18 rel_depl_19 rel_depl_20
            exclude rel_depl_21 rel_depl_22 rel_depl_23 rel_depl_24
            exclude rel_depl_25 rel_depl_26 rel_depl_27 rel_depl_28
            exclude rel_depl_29 rel_depl_30 rel_depl_31 rel_depl_32
            exclude rel_depl_33 rel_depl_34 rel_depl_35 rel_depl_36
            exclude rel_depl_37 rel_depl_38 rel_depl_39 rel_depl_40
            exclude rel_depl_41 rel_depl_42
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
                width 3500
                height 200
                description true
            }
            element "Container_vertically: Message Broker" {
                background #87cefa
                color #000000
                shape Cylinder
                width 200
                height 2000
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
            element "Deployment: Active DC" {
                background #2e7d32
                color #ffffff
                stroke #1b5e20
                strokeWidth 3
            }
            element "Deployment: Passive DC" {
                background #616161
                color #ffffff
                stroke #424242
                strokeWidth 3
                border dashed
            }
            element "Deployment: Kubernetes" {
                background #326ce5
                color #ffffff
                stroke #1e4fa3
            }
            element "Deployment: Workload" {
                background #90caf9
                color #000000
                shape Box
            }
            element "Deployment: Database VM" {
                background #80cbc4
                color #000000
                shape Box
            }
            element "Deployment: Kafka Cluster" {
                background #ffb74d
                color #000000
                shape Box
            }
            element "Deployment: Kafka Broker" {
                background #ffe0b2
                color #000000
                shape Box
            }
            element "Deployment: MirrorMaker" {
                background #ce93d8
                color #000000
                shape Box
            }
            element "Deployment: Edge" {
                background #455a64
                color #ffffff
            }
            element "Deployment: Edge Component" {
                background #78909c
                color #ffffff
                shape Box
            }
            element "Deployment: External" {
                background #9e9e9e
                color #000000
                border dashed
            }
            element "Deployment: External System" {
                background #e0e0e0
                color #000000
                shape Box
            }
            relationship "Deployment: Traffic" {
                color #1976d2
                style Solid
                routing Direct
            }
            relationship "Deployment: Failover" {
                color #d32f2f
                style Dashed
                routing Direct
                thickness 3
            }
            relationship "Deployment: Replication" {
                color #7b1fa2
                style Dashed
                routing Direct
                thickness 3
            }
            relationship "Deployment: External Integration" {
                color #455a64
                style Solid
                routing Direct
            }
        }
    }
}
