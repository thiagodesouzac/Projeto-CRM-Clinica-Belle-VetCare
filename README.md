# Clínica Belle VetCare CRM

### Salesforce CRM para gestão de clínica veterinária

Projeto de portfólio desenvolvido em **Salesforce** para demonstrar conhecimentos em **Salesforce Development, Apex, LWC, SOQL, Flow, integrações REST, testes automatizados e segurança**.

A solução centraliza o gerenciamento de tutores, pets, veterinários e agendamentos, utilizando recursos declarativos e desenvolvimento customizado para resolver problemas reais de uma clínica veterinária.

> Projeto criado em homenagem à Belle, minha parceirinha de quatro patas.

---

## Sobre o Projeto

O Belle VetCare CRM foi desenvolvido com o objetivo de simular uma aplicação Salesforce completa para uma clínica veterinária.

A solução permite:

* Gerenciar tutores e seus pets
* Cadastrar veterinários
* Criar e administrar agendamentos
* Visualizar a agenda diária dos veterinários
* Automatizar processos utilizando Flow
* Validar conflitos de agendamento com Apex
* Buscar endereços automaticamente através de integração externa
* Disponibilizar dashboards e relatórios
* Aplicar controles de segurança e acesso
* Estruturar uma base para atendimento digital com Agent Service/Agentforce

O projeto também demonstra a integração entre **recursos declarativos da plataforma e desenvolvimento programático**.

---

## Problema de Negócio

Uma clínica veterinária pode enfrentar problemas como:

* Informações de tutores e pets distribuídas
* Controle manual de agendamentos
* Conflitos de horários entre veterinários
* Digitação repetitiva de endereços
* Falta de indicadores operacionais
* Dificuldade para centralizar o atendimento

O projeto utiliza Salesforce para centralizar essas informações e automatizar etapas importantes do processo.

---

## Principais Funcionalidades

| Funcionalidade                    | Implementação                           |
| --------------------------------- | --------------------------------------- |
| Gestão de tutores e pets          | Salesforce Data Model                   |
| Gestão de veterinários            | Custom Objects                          |
| Agendamentos                      | Custom Object + Automations             |
| Prevenção de conflito de horários | Apex Trigger + Handler                  |
| Agenda diária                     | Lightning Web Component                 |
| Busca automática de endereço      | Apex + REST Callout + ViaCEP            |
| Automação de processos            | Salesforce Flow                         |
| Relatórios e indicadores          | Reports & Dashboards                    |
| Controle de acesso                | Profiles, Permission Sets, FLS, Sharing |
| Atendimento digital               | Agent Service / Agentforce              |

---

# Destaques do Desenvolvimento

## Apex

O projeto utiliza Apex para implementar regras de negócio que exigem maior controle programático.

Principais conceitos aplicados:

* Apex Trigger
* Trigger Handler Pattern
* SOQL
* Bulkification
* Governor Limits
* `addError()`
* Classes de serviço
* Exception Handling
* `@AuraEnabled`
* Test Classes
* `HttpCalloutMock`

### Validação de conflitos

Um dos principais desafios técnicos foi impedir que um veterinário recebesse dois agendamentos para o mesmo horário.

A solução utiliza:

```text
AppointmentTrigger
        ↓
AppointmentTriggerHandler
        ↓
SOQL
        ↓
Validação de conflito
        ↓
addError()
```

A lógica foi estruturada para funcionar também em operações bulk, evitando consultas SOQL dentro de loops.

---

# Lightning Web Components

O projeto possui componentes desenvolvidos com **LWC** para melhorar a experiência do usuário.

### Vet Daily Appointments

Componente responsável pela visualização da agenda diária dos veterinários.

Recursos:

* Filtro por data
* Consulta de dados via Apex
* `lightning-datatable`
* Ordenação por horário
* Exibição de veterinário, serviço e espécie
* Tratamento de ausência de resultados
* Abertura de formulário para novo agendamento

Tecnologias utilizadas:

* LWC
* JavaScript
* Apex
* SOQL
* Lightning Data Service
* SLDS

---

# Integração REST — ViaCEP

O cadastro de um agendamento possui CEP obrigatório.

Para reduzir a digitação manual, o projeto realiza uma integração com uma API externa de consulta de CEP.

### Fluxo

```text
Usuário informa o CEP
        ↓
LWC
        ↓
Apex
        ↓
HTTP Callout
        ↓
ViaCEP
        ↓
JSON Response
        ↓
Preenchimento automático do endereço
```

Os campos preenchidos automaticamente incluem:

* Logradouro
* Bairro
* Cidade
* Estado

A implementação também contempla tratamento de CEP inválido, endereço não encontrado e falhas de comunicação.

Os testes utilizam `HttpCalloutMock` para simular diferentes respostas da API sem depender do serviço externo durante a execução dos testes.

---

# Salesforce Flow

O projeto utiliza **Flow Builder** para automações declarativas.

Foram utilizados diferentes tipos de Flow de acordo com a necessidade do processo, incluindo:

* Record-Triggered Flow
* Screen Flow
* Autolaunched Flow

A utilização de Flow em conjunto com Apex demonstra uma abordagem híbrida entre **Low-Code e Pro-Code**.

---

# Segurança

A solução considera o modelo de segurança do Salesforce utilizando:

* Profiles
* Permission Sets
* Field-Level Security
* Organization-Wide Defaults
* Role Hierarchy
* Sharing Rules
* Controle de acesso aos objetos e campos

O objetivo é aplicar o princípio de **Least Privilege**, permitindo que cada perfil tenha somente os acessos necessários para suas atividades.

---

# Reports & Dashboards

Foram estruturados relatórios e indicadores para acompanhamento operacional da clínica.

Exemplos:

* Agendamentos por período
* Agendamentos por veterinário
* Serviços realizados
* Distribuição por espécie
* Indicadores da operação

---

# Arquitetura

A solução combina recursos declarativos e programáticos da plataforma:

```text
                 Salesforce
                     │
        ┌────────────┴────────────┐
        │                         │
   Declarative                 Programmatic
        │                         │
   Flow Builder                Apex
   Reports                     SOQL
   Security                    Triggers
   Data Model                  LWC
                               REST API
                                  │
                                  ↓
                               ViaCEP
```

---

# Stack Técnicas

| Categoria       | Tecnologias                                |
| --------------- | ------------------------------------------ |
| CRM             | Salesforce                                 |
| Backend         | Apex                                       |
| Frontend        | Lightning Web Components                   |
| Database        | SOQL / Salesforce Data Model               |
| Automation      | Flow Builder                               |
| Integration     | REST API / HTTP Callout                    |
| Testing         | Apex Test Classes / HttpCalloutMock        |
| UI              | Lightning Experience / SLDS                |
| Security        | Profiles / Permission Sets / FLS / Sharing |
| Analytics       | Reports / Dashboards                       |
| Version Control | Git / GitHub                               |

---

# Estrutura do Projeto

```text
force-app/
└── main/
    └── default/
        ├── classes/
        ├── triggers/
        ├── lwc/
        ├── flows/
        ├── objects/
        ├── permissionsets/
        ├── profiles/
        ├── reports/
        └── dashboards/
```

---

# Testes

O projeto possui testes automatizados para validar diferentes cenários de negócio e integração.

Entre os cenários contemplados:

* Criação de agendamento
* Atualização de agendamento
* Conflito de horário
* Operações bulk
* Respostas válidas da API
* CEP inexistente
* CEP inválido
* Erros de integração
* Exceções e tratamento de erros

Para a integração externa, `HttpCalloutMock` é utilizado para manter os testes independentes da API real.

---

# Competências Demonstradas

### Desenvolvimento Salesforce

* Apex
* Triggers
* Trigger Handler
* SOQL
* LWC
* REST Integration
* Test Classes
* Bulkification
* Governor Limits
* Exception Handling

### Salesforce Platform

* Flow Builder
* Data Modeling
* Profiles
* Permission Sets
* FLS
* Sharing Rules
* Reports
* Dashboards
* Lightning Experience

### Boas Práticas

* Separação de responsabilidades
* Código bulkificado
* Tratamento de exceções
* Testes automatizados
* Segurança baseada em permissões
* Integração desacoplada
* Combinação de Low-Code e Pro-Code

---

# Roadmap

Possíveis evoluções do projeto:

* Evolução do atendimento com Agentforce
* Novos componentes LWC
* Ampliação das automações
* Novas integrações externas
* Melhorias nos dashboards
* Expansão da cobertura de testes
* Novas funcionalidades de atendimento

---

# Objetivo do Portfólio

Este projeto foi desenvolvido como parte da minha evolução profissional no ecossistema Salesforce, buscando aplicar na prática conceitos de **desenvolvimento, arquitetura, automação, integração e segurança**.

A proposta não é apenas demonstrar conhecimento de ferramentas, mas mostrar como utilizar a plataforma Salesforce para transformar requisitos de negócio em uma solução funcional.

---

## Autor

**Thiago de Souza**

Salesforce Developer | Apex | LWC | SOQL | Flow | REST API

Projeto desenvolvido para estudos, prática e demonstração de conhecimentos em Salesforce Development.
