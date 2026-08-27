# Clínica Belle VetCare CRM

**CRM customizado em Salesforce para gestão de clínica veterinária, combinando Salesforce Administration, automação declarativa, Apex, SOQL, Lightning Web Components (LWC), segurança, analytics e atendimento digital.**

---

## Visão Geral

O **Belle VetCare CRM** é um projeto de portfólio desenvolvido em Salesforce para estruturar e automatizar a operação de uma clínica veterinária.

A solução centraliza o cadastro de **tutores, pets, veterinários e consultas** em uma única plataforma, implementando automações operacionais, validações, segurança de dados, relatórios, dashboards e atendimento digital.

O projeto evoluiu de uma arquitetura predominantemente declarativa para uma solução que também utiliza **Apex e LWC** para resolver regras de negócio que exigem lógica programática.

> **Objetivo técnico:** demonstrar, em um único case, competências práticas de Salesforce Administration e Salesforce Development, desde modelagem e segurança até implementação de regras de negócio, testes automatizados e componentes Lightning.

---

## Problema de Negócio

Uma clínica veterinária pode enfrentar problemas como:

- Informações dispersas entre tutor, pet e consulta;
- Falta de padronização no processo de agendamento;
- Dependência de ações manuais para comunicação com veterinários;
- Ausência de indicadores operacionais;
- Necessidade de triagem e cadastro automatizados;
- **Overbooking**, quando dois compromissos são criados para o mesmo veterinário, data e horário.

### Problema técnico crítico

O modelo declarativo não impedia que dois compromissos fossem registrados para o mesmo veterinário no mesmo horário.

Para resolver esse cenário, foi criada uma **regra de negócio em Apex** que valida conflitos antes da inserção ou atualização de `Appointment__c`.

---

# Arquitetura da Solução

## Modelo de Dados

A solução utiliza quatro objetos principais:

```text
PetOwner__c ←→ Pet__c
     ↓           ↓
Appointment__c ←→ Vet__c
```

### PetOwner__c — Responsável pelo Pet

| Campo | Tipo | Descrição |
|---|---|---|
| Name | Text | Nome do responsável |
| CPF | Text | CPF com fórmula/validação |
| Email | Email | E-mail de contato |
| Phone | Phone | Telefone |
| Address | Text | Endereço residencial |
| CEP | Text | CEP com fórmula/validação |
| Quantity Pet | Number | Total de animais do tutor |

### Pet__c — Paciente

| Campo | Tipo | Descrição |
|---|---|---|
| PetName | Text | Nome do animal |
| Species | Picklist | Tipo de animal |
| Breed | Text | Raça |
| Age | Number | Idade em anos |
| Sex | Text | Sexo |
| Weight | Number | Peso em kg |
| Pet Owner | Lookup | Referência ao tutor |
| Vet | Lookup | Veterinário responsável |

### Vet__c — Veterinário

| Campo | Tipo | Descrição |
|---|---|---|
| VetName | Text | Nome do veterinário |
| CRMV | Number | Registro profissional |
| Email | Email | E-mail corporativo |
| Phone | Phone | Telefone |
| Specialty | Picklist | Especialidade |
| Available Days | Picklist | Dias de atendimento |
| Status | Picklist | Status operacional |

### Appointment__c — Agendamento

| Campo | Tipo | Descrição |
|---|---|---|
| Date | Date | Data da consulta |
| Time | Picklist | Horário padronizado |
| PetOwner | Lookup | Responsável pelo pet |
| Pet | Lookup | Animal atendido |
| Service Type | Picklist | Tipo de atendimento |

---

# Camadas da Solução

## 1. Salesforce Administration

A base do projeto foi construída utilizando recursos declarativos do Salesforce:

- Objetos e campos customizados;
- Relacionamentos Lookup;
- Fórmulas e validações;
- Lightning App;
- Lightning Record Pages;
- Dynamic Forms;
- Profiles;
- Permission Sets;
- Organization-Wide Defaults;
- Role Hierarchy;
- Sharing Rules;
- Field-Level Security;
- Reports;
- Dashboards;
- Flows.

---

## 2. Automação com Salesforce Flow

### Record-Triggered Flows

#### Vet Appointment Alert

Executado após a criação de um `Appointment__c`, acionando a comunicação automática com o veterinário responsável.

#### Vet Cancellation Alert

Realiza as validações necessárias e envia uma notificação por e-mail ao veterinário, contendo informações como:

- Pet;
- Tutor;
- Data;
- Horário;
- Tipo de atendimento.

### Autolaunched Flows

Utilizados no atendimento digital:

- `Flow Bot Register PetOwner Pet`
- `Flow Bot Schedule Appointment`
- `Flow Bot Validate PetOwner CPF`

---

# Camada de Desenvolvimento — Apex

## AppointmentTrigger

Foi implementado um trigger sobre `Appointment__c` para impedir conflitos de agenda.

```text
AppointmentTrigger
        ↓
AppointmentTriggerHandler
        ↓
Consulta SOQL
        ↓
Identificação de conflito
        ↓
addError()
```

### AppointmentTriggerHandler

A lógica de negócio foi isolada em uma **Handler Class**, mantendo o trigger responsável apenas pelo acionamento.

A validação ocorre antes de:

- `insert`;
- `update`.

O sistema verifica se já existe um compromisso para o mesmo:

- Veterinário;
- Data;
- Horário.

Quando encontra um conflito, o registro é bloqueado utilizando `addError()`.

### Bulkification

A implementação foi estruturada para processamento em lote:

- Consulta SOQL fora de loops;
- Processamento de múltiplos registros;
- Suporte seguro para até 200 registros por transação;
- Respeito aos governor limits do Salesforce.

Essa abordagem demonstra aplicação prática de **Bulkification**, conceito fundamental no desenvolvimento Apex.

---

# Testes Automatizados

## AppointmentTriggerHandlerTest

A classe de teste cobre diferentes cenários da regra de negócio:

| Cenário | Resultado esperado |
|---|---|
| Criar agendamento sem conflito | Sucesso |
| Criar agendamento com conflito | Falha |
| Atualizar agendamento criando conflito | Falha |
| Processar 200 registros | Sucesso |

A cobertura contempla cenários **positivos, negativos, de atualização e bulk**, demonstrando preocupação com qualidade e confiabilidade do código.

---

# Lightning Web Component

## vetDailyAppointment

O componente **`vetDailyAppointment`** apresenta a agenda diária do veterinário.

### Características

- Lightning Web Component;
- Filtro por data;
- Exibição dos agendamentos do dia;
- `lightning-datatable`;
- Consumo de controlador Apex;
- `@AuraEnabled(cacheable=true)`;
- `@wire` com parâmetro dinâmico;
- Controle de acesso utilizando `WITH SECURITY_ENFORCED`.

### Arquitetura

```text
LWC: vetDailyAppointment
          ↓
        @wire
          ↓
VetAppointmentController
          ↓
        SOQL
          ↓
   Appointment__c
```

O controlador Apex utiliza `WITH SECURITY_ENFORCED` para respeitar as permissões do usuário conectado durante a consulta.

---

# Jornada Operacional

```text
Cliente
   ↓
Bot / Recepção
   ↓
Validação de CPF
   ↓
Cadastro ou recuperação
   ↓
Seleção do Pet
   ↓
Data + Horário
   ↓
Tipo de Atendimento
   ↓
Appointment__c
   ↓
Validação Apex
   ↓
┌─────────────────────┐
│ Existe conflito?    │
└──────────┬──────────┘
           │
      Sim  │  Não
       ↓   │   ↓
   addError  Registro criado
               ↓
        Record-Triggered Flow
               ↓
        E-mail ao veterinário
```

---

# Atendimento Digital

O projeto utiliza um agente de atendimento como porta de entrada para operações iniciais da clínica.

O fluxo permite:

1. Validar o CPF;
2. Identificar ou cadastrar o tutor;
3. Cadastrar o pet;
4. Realizar o agendamento;
5. Acionar as automações correspondentes.

Essa camada demonstra integração entre **Agent Service, Flow e modelo de dados Salesforce**.

---

# Lightning App

Foi criada uma aplicação Lightning para organizar a operação da clínica.

### Navegação

- **Pets** — gerenciamento de pacientes;
- **Tutors** — cadastro de responsáveis;
- **Vets** — quadro de veterinários;
- **Appointment** — consultas e agendamentos;
- **Reports** — relatórios;
- **Dashboards** — indicadores gerenciais.

---

# Segurança e Governança

A arquitetura utiliza múltiplas camadas de segurança seguindo o princípio de **Least Privilege**.

## Modelo de acesso

```text
Profile
   ↓
Permission Sets
   ↓
OWD
   ↓
Role Hierarchy
   ↓
Sharing Rules
   ↓
Field-Level Security
   ↓
Dynamic Forms
```

### Profile

Foi utilizado o perfil padrão **Standard Platform User** como configuração inicial, mantendo permissões básicas e delegando acessos específicos aos Permission Sets.

### Permission Set — Recepcionista

Permissões concedidas:

- Criar e editar tutores;
- Criar e editar pets;
- Criar e editar agendamentos;
- Visualizar informações básicas dos veterinários.

Restrições:

- Sem exclusão de registros;
- Sem criação ou edição de veterinários;
- Sem acesso administrativo;
- Sem `View All`;
- Sem `Modify All`.

### Organization-Wide Defaults

O objeto `Vet__c` utiliza **OWD = Private**.

Isso restringe o acesso aos registros por padrão e exige mecanismos adicionais de compartilhamento.

### Role Hierarchy

```text
CEO
│
├── Veterinarian
│
└── Receptionist
```

### Sharing Rules

Foi criada uma regra para compartilhar registros de `Vet__c` com o grupo **Receptionists** em modo:

- **Read Only**

### Field-Level Security

Para a recepção, ficam disponíveis apenas informações necessárias ao processo operacional:

**Visíveis:**
- Vet Name;
- Email.

**Ocultos:**
- CRMV;
- Phone;
- Specialty;
- Available Days;
- Status;
- Campos administrativos.

### Dynamic Forms

Dynamic Forms foram utilizados em conjunto com FLS para adaptar a interface conforme o tipo de usuário.

A página de registro possui seções como:

- **Basic Information**;
- **Administrative Information**.

Para a recepção, a interface é simplificada, exibindo somente os campos necessários.

---

# Relatórios e Dashboards

## Custom Report Type

Foi criado um **Custom Report Type** baseado em `Appointment__c` para suportar a análise operacional.

## Relatórios

### Consultas por Dia
Apresenta o volume diário de consultas.

### Consultas por Mês
Permite acompanhar tendências mensais.

### Consultas por Veterinário
Permite analisar a distribuição de carga de trabalho.

### Tipos de Atendimento por Mês
Permite visualizar a demanda por:

- Consulta;
- Vacinação;
- Cirurgia;
- Outros serviços cadastrados.

## Dashboard Operacional

| Componente | Métrica |
|---|---|
| Metric Chart | Consultas por dia |
| Horizontal Bar Chart | Total de consultas no mês |
| Horizontal Bar Chart | Veterinário com mais consultas |
| Donut Chart | Distribuição por tipo de atendimento |

---

# Stack Tecnológico

| Camada | Tecnologia |
|---|---|
| Plataforma | Salesforce |
| Data Model | Custom Objects & Fields |
| Automação | Flow |
| Backend | Apex |
| Query Language | SOQL |
| Trigger | Apex Trigger |
| Architecture Pattern | Trigger Handler |
| Testing | Apex Test Classes |
| Frontend | Lightning Web Components |
| UI | Lightning App / Lightning Record Pages |
| Segurança | Profiles, Permission Sets, OWD, Sharing Rules, FLS |
| Interface dinâmica | Dynamic Forms |
| Analytics | Reports & Dashboards |
| Atendimento | Salesforce Enhanced Bot / Agent Service |
| E-mail | Salesforce Automation |

---

# Competências Demonstradas

## Salesforce Administration

- Modelagem de dados;
- Objetos e campos customizados;
- Relacionamentos Lookup;
- Lightning App Builder;
- Profiles;
- Permission Sets;
- OWD;
- Role Hierarchy;
- Sharing Rules;
- Field-Level Security;
- Dynamic Forms;
- Reports;
- Dashboards.

## Salesforce Development

- Apex Triggers;
- Trigger Handler Pattern;
- Apex Classes;
- SOQL;
- `WITH SECURITY_ENFORCED`;
- `addError()`;
- Bulkification;
- Governor Limits;
- Apex Test Classes;
- Cenários positivos e negativos;
- Testes de atualização;
- Testes bulk;
- `@AuraEnabled`;
- `@AuraEnabled(cacheable=true)`;
- Lightning Web Components;
- `@wire`;
- `lightning-datatable`.

## Automation

- Record-Triggered Flow;
- Autolaunched Flow;
- Automação de e-mails;
- Validação de dados;
- Automação de agendamento;
- Integração entre Flow e atendimento digital.

## Business Analysis

- Tradução de processos de negócio em solução CRM;
- Modelagem da jornada do cliente;
- Controle de agenda;
- Prevenção de overbooking;
- Automação de comunicação;
- Indicadores operacionais;
- Aplicação de segurança baseada em função.

---

# Resultados Entregues

O Belle VetCare CRM consolidou:

- Cadastro estruturado de tutores e pets;
- Gerenciamento de veterinários;
- Controle centralizado de consultas;
- Prevenção de conflito de agenda;
- Validação de regras de negócio com Apex;
- Testes automatizados;
- Agenda diária em LWC;
- Automação de notificações por e-mail;
- Segurança granular;
- Atendimento digital automatizado;
- Relatórios operacionais;
- Dashboard para tomada de decisão.

---

# Diferenciais Técnicos do Projeto

O projeto demonstra uma evolução arquitetural em camadas:

```text
┌───────────────────────────────────────┐
│          Atendimento Digital          │
│        Agent Service / Bot            │
├───────────────────────────────────────┤
│             Lightning UI              │
│       App + Pages + LWC               │
├───────────────────────────────────────┤
│          Business Automation          │
│              Flow                    │
├───────────────────────────────────────┤
│           Programmatic Logic          │
│        Apex + Trigger Handler         │
├───────────────────────────────────────┤
│              Data Layer               │
│       Objects + Fields + SOQL         │
├───────────────────────────────────────┤
│       Security & Governance            │
│ Profile + Permission Set + OWD + FLS │
└───────────────────────────────────────┘
```

Essa arquitetura permite demonstrar que a solução não depende exclusivamente de configuração declarativa: **Flow é utilizado para automação, enquanto Apex é aplicado quando uma regra de negócio exige processamento programático**, como a prevenção de conflitos de agenda.

---

# Status do Projeto

**Status:** Completo e funcional  
**Tipo:** Projeto de Portfólio / Case Study  
**Plataforma:** Salesforce Developer Org  
**Escopo:** CRM Customizado  
**Área de Negócio:** Saúde Animal / Clínica Veterinária

---

# Autor

**Thiago de Souza**

Projeto desenvolvido como demonstração prática de competências em **Salesforce Administration e Salesforce Development**, com foco em:

**Apex · LWC · SOQL · Flow · Test Classes · Segurança · Automação · Reports & Dashboards**

