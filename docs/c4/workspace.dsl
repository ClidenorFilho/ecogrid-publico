workspace "MobiSocial" "Arquitetura do Sistema de Transporte e Mobilidade Urbana Inclusiva" {

    model {
        # ==========================================
        # 1. ATORES (PERSONS)
        # ==========================================
        passageiro = person "Passageiro" "Cidadão comum, Estudante ou Paciente de UBS que agenda corridas individuais ou compartilhadas e realiza pagamentos." "Person"
        motorista = person "Motorista Parceiro" "Condutor credenciado que cadastra veículos, cria rotas urbanas e realiza o transporte dos passageiros." "Person"

        # ==========================================
        # 2. SISTEMAS EXTERNOS (EXTERNAL SYSTEMS)
        # ==========================================
        gatewayPagamento = softwareSystem "Gateway Externo de Pagamentos" "Processa cobranças eletrônicas (PIX, cartão) e validação de vouchers de tarifa social/estudantil." "External"
        apiMapas = softwareSystem "Serviço Externo de Mapas e Geolocalização" "Fornece cálculo de distância, estimativa de tempo e validação de paradas da rota urbana." "External"
        servicoPush = softwareSystem "Serviço Externo de Mensageria / Push" "Entrega notificações por E-mail, SMS ou Push aos passageiros e motoristas." "External"

        # ==========================================
        # 3. SISTEMA CENTRAL E CONTAINERS (C4 NÍVEL 2)
        # ==========================================
        mobisocial = softwareSystem "MobiSocial" "Plataforma de transporte e mobilidade urbana para criação de rotas, agendamento de corridas compartilhadas e gestão de pagamentos com rateio e tarifa social." {

            rideService = container "Serviço de Rotas e Corridas" "Gerencia cadastro de usuários/veículos, criação de rotas e agendamento de corridas compartilhadas via API REST (POST /api/rides)." "Java 17 e Spring Boot (REST API)" "Service"

            messageBroker = container "Message Broker" "Intermedia de forma assíncrona os eventos de corrida agendada (payments.process) e disparo de avisos (notifications.dispatch)." "RabbitMQ" "Queue"

            paymentService = container "Serviço de Pagamentos e Rateio" "Consome eventos de corridas agendadas, calcula o rateio entre passageiros ou desconto de tarifa social e processa a cobrança." "Java 17 e Spring Boot (AMQP Worker)" "Service"

            notificationService = container "Serviço de Notificações" "Consome eventos de confirmação e dispara avisos de corrida agendada, motorista alocado e pagamento aprovado." "Java 17 e Spring Boot (AMQP Worker)" "Service"

            database = container "Banco de Dados Relacional" "Armazena usuários, veículos, rotas planejadas, agendamentos de corridas e transações de pagamento." "PostgreSQL" "Database"
        }

        # ==========================================
        # 4. RELACIONAMENTOS E PROTOCOLOS
        # ==========================================
        # Interações dos Atores com o Serviço de Rotas e Corridas (REST)
        passageiro -> rideService "Solicita agendamento de corrida compartilhada e consulta rotas (POST /api/rides)" "JSON/HTTPS"
        motorista -> rideService "Cadastra veículo, cria rotas planejadas e consulta lista de embarque" "JSON/HTTPS"

        # Integrações do Serviço de Rotas e Corridas
        rideService -> apiMapas "Consulta distância, estimativa de percurso e paradas da rota" "JSON/HTTPS"
        rideService -> database "Lê e persiste usuários, veículos, rotas e agendamentos de corridas" "JDBC / Spring Data JPA"
        rideService -> messageBroker "Publica evento de corrida agendada na fila payments.process" "AMQP"

        # Fluxo Assíncrono do Serviço de Pagamentos e Rateio
        messageBroker -> paymentService "Entrega evento da fila payments.process para cálculo de tarifa" "AMQP"
        paymentService -> gatewayPagamento "Processa cobrança com rateio ou valida voucher de tarifa social" "JSON/HTTPS"
        paymentService -> database "Persiste transação financeira e atualiza status do pagamento" "JDBC / Spring Data JPA"
        paymentService -> messageBroker "Publica evento de pagamento aprovado na fila notifications.dispatch" "AMQP"

        # Fluxo Assíncrono do Serviço de Notificações
        messageBroker -> notificationService "Entrega evento da fila notifications.dispatch" "AMQP"
        notificationService -> servicoPush "Solicita disparo de aviso de viagem confirmada e recibo" "JSON/HTTPS"
        servicoPush -> passageiro "Envia confirmação da corrida agendada e recibo tarifário" "Push / E-mail / SMS"
        servicoPush -> motorista "Envia alerta de novo passageiro alocado na rota compartilhada" "Push / E-mail / SMS"
    }

    views {
        # C4 Nível 1: Diagrama de Contexto do Sistema
        systemContext mobisocial "C4_Nivel1_Contexto" {
            include *
            autoLayout lr
            description "Diagrama de Contexto (C4 Nível 1) do sistema MobiSocial, destacando atores e integrações externas."
        }

        # C4 Nível 2: Diagrama de Containers (SOA + Event-Driven)
        container mobisocial "C4_Nivel2_Container" {
            include *
            autoLayout lr
            description "Diagrama de Containers (C4 Nível 2) do MobiSocial detalhando os serviços SOA em Spring Boot, o RabbitMQ e o PostgreSQL."
        }

        styles {
            element "Person" {
                shape Person
                background "#08427B"
                color "#FFFFFF"
            }
            element "Software System" {
                background "#1168BD"
                color "#FFFFFF"
            }
            element "External" {
                background "#6C757D"
                color "#FFFFFF"
            }
            element "Container" {
                background "#438DD5"
                color "#FFFFFF"
            }
            element "Service" {
                shape RoundedBox
                background "#2563EB"
                color "#FFFFFF"
            }
            element "Queue" {
                shape Pipe
                background "#D97706"
                color "#FFFFFF"
            }
            element "Database" {
                shape Cylinder
                background "#059669"
                color "#FFFFFF"
            }
            relationship "Relationship" {
                routing Orthogonal
                thickness 2
            }
        }
    }
}