# EcoGrid Público: Smart Grid para Escolas e UBS

Monitoramento Inteligente de Consumo, Otimização de Cargas em Prédios Públicos e Proteção de Insumos Críticos de Saúde documentado com C4 Model (Structurizr).

## 1. Definição do Produto e Escopo
<!-- [ESPAÇO RESERVADO - DUPLA B]
Inserir aqui:
- Descrição do produto EcoGrid Público (foco em Escolas Públicas e UBS)
- Catálogo de Atores e Sistemas Externos
- Funcionalidades documentadas (RF01 a RF05)
- Resumo do Fluxo Principal
-->

## 2. Estilos Arquiteturais Selecionados

Para atender aos requisitos do **Tema 14 (Sistema de Gerenciamento de Energia / Smart Grid)** com baixo acoplamento, tolerância a picos de leitura e isolamento das regras críticas de negócio, o projeto combina dois estilos arquiteturais complementares:

### 2.1. Arquitetura Baseada em Eventos (Event-Driven Architecture — Estilo Macro)
* **Aplicação no Sistema:** Toda a ingestão de leituras dos medidores inteligentes (Smart Meters) instalados nas escolas e UBS ocorre de forma assíncrona por meio de um Message Broker (**RabbitMQ** via protocolo `AMQP`).
* **Justificativa Arquitetural:** Dispositivos IoT geram fluxos contínuos de telemetria na fila `telemetry.readings`. O modelo orientado a eventos garante **desacoplamento temporal e espacial** entre os sensores de borda e o processamento central. Quando o motor de análise detecta uma sobrecarga elétrica ou risco térmico na linha de uma câmara de vacinas, ele publica eventos de domínio (`optimization.commands` e `alerts.critical`) que são consumidos de forma independente pelo controlador de atuadores (para *Load Shedding* automático de circuitos secundários) e pelo serviço de notificações.

### 2.2. Clean Architecture (Estilo Interno do Serviço Central)
* **Aplicação no Sistema:** O microsserviço principal (**Serviço Core de Monitoramento e Otimização**, em Java com Spring Boot) é estruturado internamente em camadas concêntricas:
  * **Entities:** Regras de negócio puras e modelos de domínio (`CircuitEntity`, classificação de criticidade em *Vital*, *Essencial* e *Secundário/Ocioso*).
  * **Use Cases:** Orquestração dos fluxos da aplicação (`ProcessTelemetryReadingUseCase`, políticas de corte de carga em `LoadSheddingPolicyService`).
  * **Interface Adapters:** Adaptadores de entrada e saída (`TelemetryConsumerController`, `UnitRepositoryPort`, `EventPublisherAdapter`).
  * **Frameworks & Drivers:** Integrações externas com Spring Boot, **PostgreSQL** (`JDBC`/JPA) e **RabbitMQ** (`AMQP`).
* **Justificativa Arquitetural:** Garante que as regras críticas de negócio — como a matriz de prioridade elétrica das UBS, os limiares de sobrecarga e o cálculo de desperdício em salas de aula ociosas — fiquem **100% isoladas** do banco de dados e da tecnologia de mensageria utilizada, facilitando a testabilidade e a evolução da infraestrutura.

## 3. Documentação Arquitetural (Modelo C4 - Structurizr)

O código-fonte da modelagem arquitetural encontra-se em [`/docs/c4/workspace.dsl`](./docs/c4/). As Decisões Arquiteturais (ADRs) estão documentadas em [`/docs/adr/`](./docs/adr/).

### 3.1. C4 Nível 1: Diagrama de Contexto
<!-- [ESPAÇO RESERVADO - DUPLA C]
Inserir imagem exportada de /docs/c4 e parágrafo explicativo dos fluxos e protocolos.
-->

### 3.2. C4 Nível 2: Diagrama de Container
<!-- [ESPAÇO RESERVADO - DUPLA C]
Inserir imagem exportada de /docs/c4 e parágrafo explicativo detalhando os containers e os protocolos (AMQP, JDBC e HTTPS).
-->

## 4. Guia Passo a Passo de Execução do Projeto

> *Nota: Os comandos abaixo descrevem o procedimento completo de execução da implementação parcial do fluxo principal (prevista para a Entrega da Etapa 3 em 01/12).*

### Pré-requisitos
* **Docker** e **Docker Compose**
* **Java JDK 17+** e **Maven**
* **Python 3.10+** (para execução do Simulador IoT)

### 4.1. Subir a Infraestrutura (RabbitMQ e PostgreSQL)
Na raiz do repositório, inicie os containers do Message Broker e do Banco de Dados via Docker Compose:
```bash
docker compose up -d

````

- **RabbitMQ (AMQP):** `localhost:5672` | **Painel Web:** `http://localhost:15672`
- **PostgreSQL:** `localhost:5432`

### 4.2. Executar o Serviço Core (Spring Boot)

Acesse o diretório do serviço principal em `/src` e inicie a aplicação:

Bash
```
cd src
./mvnw spring-boot:run

```

### 4.3. Executar o Simulador IoT (Python)

Em outro terminal, instale a biblioteca de conexão AMQP e execute o script simulador para publicar payloads JSON de sobrecarga elétrica na fila `telemetry.readings` do RabbitMQ:

Bash
```
cd src/simulator
pip install pika
python simulator.py

```

## 5. Cronograma e Divisão de Atividades da Equipe

**Integrantes (Equipe 10):** Felipe Maia, João Vitor, Maria José, Cauan, Clidenor e Pablo.

| **Etapa**   | **Prazo Oficial** | **Dupla Responsável**               | **Entregável Principal**        | **Foco Técnico da Frente**                                                                                                                                                                       |
| ----------- | ----------------- | ----------------------------------- | ------------------------------- | ------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------ |
| **Etapa 1** | 16/11             | **Dupla A:** Felipe Maia e Clidenor | Repositório GitHub e Estilos    | Criar repo, adicionar equipe, estruturar pastas (`/docs/c4`, `/docs/adr`, `/src`), justificar Event-Driven + Clean Arch no `README.md`, guia de execução e importar dependências do Spring Boot. |
| **Etapa 1** | 16/11             | **Dupla B:** *Pablo e Maria*          | Escopo EcoGrid e Requisitos     | Documentar o problema em Escolas/UBS, atores, funcionalidades (RF01-RF05) e fluxo principal no `README.md`.                                                                                      |
| **Etapa 1** | 16/11             | **Dupla C:** *Cauan Ricardo e João Vitor*          | Diagramas C4 Níveis 1 e 2       | Configurar Structurizr DSL (`workspace.dsl`) e gerar os diagramas de Contexto e Container alinhados ao `README.md`.                                                                              |
| **Etapa 2** | 23/11             | **Dupla A:** *Felipe Maia e Clidenor*          | C4 Nível 3 (Ingestão/Eventos)   | Modelar os componentes internos do Container de Ingestão IoT, filas do Broker e Notificações.                                                                                                    |
| **Etapa 2** | 23/11             | **Dupla B:** *Pablo e Maria*          | C4 Nível 3 (Core Clean Arch)    | Modelar os componentes internos do Serviço Core (Controllers, Use Cases, Entities, Gateways).                                                                                                    |
| **Etapa 2** | 23/11             | **Dupla C:** *Cauan Ricardo e João Vitor*          | C4 Nível 4 (Código) e ADRs      | Modelar o diagrama de classes do fluxo de sobrecarga e redigir as Decisões Arquiteturais (ADRs 01, 02 e 03) em `/docs/adr`.                                                                      |
| **Etapa 3** | 01/12             | **Dupla A:** *Felipe Maia e Clidenor*          | Infra Docker e Simulador IoT    | Subir Docker Compose (RabbitMQ + PostgreSQL) e criar script Python simulador enviando leituras de Escola e UBS.                                                                                  |
| **Etapa 3** | 01/12             | **Dupla B:** *Pablo e Maria*          | Serviço Core (Clean Arch)       | Implementar o fluxo principal (detecção de anomalia + disparo de evento de corte de carga) em conformidade com os níveis 3 e 4.                                                                  |
| **Etapa 3** | 01/12             | **Dupla C:** *Cauan Ricardo e João Vitor*          | Receptor, Conformidade e Slides | Implementar consumidor de alertas/atuador, auditar conformidade código x Structurizr e preparar apresentação.                                                                                    |
