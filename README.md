# Clínica Belle VetCare CRM

**Solução CRM Customizada em Salesforce para Clínica Veterinária**

---

# Visão Geral

O Belle VetCare é um projeto de CRM desenvolvido em Salesforce que estrutura e automatiza a operação completa de uma clínica veterinária.

A solução centraliza o cadastro de tutores, pets, veterinários e consultas em uma única plataforma, implementando automações operacionais, segurança de dados e experiência de atendimento digital.

Este projeto demonstra domínio prático em **Salesforce Administration**, **Salesforce Development**, modelagem de dados customizados, automação com Flow, segurança e implementação de bot (Agentforce) de atendimento.

---

# Contexto do Projeto

## Desafio de Negócio

A operação de uma clínica veterinária enfrenta desafios operacionais significativos:

- Desorganização de informações dispersas entre tutor, pet e consulta
- Falta de padronização no processo de agendamento
- Dependência de ações manuais para comunicação com veterinários
- Ausência de indicadores para acompanhamento da rotina clínica
- Necessidade de triagem automatizada para reduzir erros no atendimento

## Solução Proposta

Uma plataforma CRM centralizada que:

- Organiza cadastro de tutores e pets de forma estruturada
- Automatiza o processo de agendamento com validações
- Notifica veterinários automaticamente sobre consultas
- Fornece visibilidade operacional através de relatórios e dashboards
- Oferece atendimento inicial automatizado com bot inteligente

---

# Arquitetura da Solução

## Estrutura de Objetos Customizados

A solução foi construída sobre quatro objetos principais que representam a jornada operacional da clínica:

```text
PetOwner__c ←→ Pet__c
  ↓           ↓
Appointment__c ←→ Vet__c
```

### 1. Pet_Owner__c (Responsável pelo Pet)

| Campo | Tipo | Descrição |
|-------|------|-----------|
| Name | Text | Nome do responsável |
| CPF | Text | CPF com fórmula/validação |
| Email | Email | Email de contato |
| Phone | Phone | Telefone para comunicação |
| Address | Text | Endereço residencial |
| CEP | Text | CEP com fórmula/validação |
| Quantity Pet | Number | Total de animais do tutor |

### 2. Pet__c (Paciente)

| Campo | Tipo | Descrição |
|-------|------|-----------|
| PetName | Text | Nome do animal |
| Species | Picklist | Tipo de animal (cão, gato, etc) |
| Breed | Text | Raça do animal |
| Age | Number | Idade em anos |
| Sex | Text | Sexo do animal |
| Weight | Number | Peso em kg |
| Pet Owner | Lookup | Referência ao Pet_Owner__c |
| Vet | Lookup | Veterinário responsável |

### 3. Vet__c (Veterinário)

| Campo | Tipo | Descrição |
|-------|------|-----------|
| VetName | Text | Nome do veterinário |
| CRMV | Number | Registro profissional |
| Email | Email | Email corporativo |
| Phone | Phone | Telefone para contato |
| Specialty | Picklist | Campo de especialização |
| Available Days | Picklist | Dias de atendimento |
| Status | Picklist | Agendado, confirmado, cancelado, finalizado |

### 4. Appointment__c (Agendamento)

| Campo | Tipo | Descrição |
|-------|------|-----------|
| Date | Date | Data da consulta |
| Time | Picklist | Horário do atendimento padronizado |
| PetOwner | Lookup | Responsável pelo pet |
| Pet | Lookup | Animal a ser atendido |
| Service Type | Picklist | Consulta, vacinação, cirurgia, exames, internação, emergência |

---

# Fluxo Operacional Completo

## 1. Primeiro Contato

Cliente entra em contato através do bot ou recepção:

```text
Cliente → Bot/Atendente → Validação CPF → Cadastro ou Recuperação
```

## 2. Cadastro

Se novo cliente:

```text
Criar Tutor__c → Criar Pet__c → Validar dados → Ativar perfil
```

## 3. Agendamento

Cliente marca consulta:

```text
Selecionar Pet → Escolher Data/Hora → Tipo Atendimento → Confirmar
                                              ↓
                                    Appointment__c criado
                                              ↓
                                    Record-Triggered Flow dispara
                                              ↓
                                    E-mail enviado ao Vet
```

## 4. Acompanhamento

Gestão operacional:

```text
Dashboard mostra volume do dia
Relatório identifica gargalos
Vet recebe alertas automáticos
Sistema registra histórico completo
```

---

# Funcionalidades Principais

## 1. Automação de Notificações

### Vet Appointment Alert (Record-Triggered Flow)

**Tipo:** Record-Triggered Flow

Executado automaticamente após a criação de um registro de consulta (`Appointment`).

### Vet Cancellation Alert (Record-Triggered Flow)

- Valida a existência de um veterinário vinculado ao agendamento.
- Envia uma notificação por e-mail ao veterinário responsável.
- Inclui no e-mail as informações da consulta:
  - Pet;
  - Tutor;
  - Data;
  - Horário;
  - Tipo de atendimento.

---

## 2. Validação de Dados

O projeto implementa validações robustas para garantir integridade cadastral:

- **Validação de CPF**: Fórmula de validação automática do documento.

---

## 3. Bot de Atendimento (Enhanced Bot)

Bot implementado como porta de entrada do atendimento digital.

### Bot Flows: Autolaunched Flow

- **Bot Register PetOwner Pet**: Cadastro de pet e tutor responsável
- **Bot Schedule Appointment**: Agendamento com validação
- **Bot Validate PetOwner CPF**: Verificação de cadastro existente

### Flow Omni Channel

- **Bot Route to Belle Chat**: Transferência para atendente humano

---

## 4. Lightning App Customizado

Interface de navegação organizada para operação da clínica com tabs:

- **Pets**: Gerenciamento de pacientes
- **Tutors**: Cadastro de responsáveis
- **Vets**: Quadro de veterinários
- **Appointment**: Agendamentos e consultas
- **Reports**: Relatórios operacionais
- **Dashboards**: Indicadores gerenciais

---

# Jornada do Cliente

```text
Menu Principal
├── Cadastrar Tutor e Pet
│   ├── Coletam dados pessoais
│   ├── Validam CPF
│   └── Criam registros no sistema
│
├── Agendar Atendimento
│   ├── Solicita CPF para validação
│   ├── Se existe cadastro → segue agendamento
│   └── Se não existe → direciona para cadastro
│
└── Falar com Atendente
    └── Transfere para atendimento humano
```

---

# Camada de Segurança e Governança

## Modelo de Controle de Acesso

### Perfil: Ana Recepção

A arquitetura foi projetada para proteger dados sensíveis, controlar o acesso aos registros e proporcionar uma experiência adequada para cada tipo de usuário, sem comprometer a produtividade da equipe.

### Permissões Concedidas

---

### Restrições Aplicadas

A camada de segurança foi construída utilizando múltiplos recursos nativos do Salesforce, formando uma arquitetura de acesso em diferentes níveis.

### Field-Level Security

Essa combinação garante que o acesso aos dados seja controlado desde o nível do objeto até a visualização individual dos campos, seguindo uma estratégia de segurança em camadas (*Layered Security*).

---

## Modelo de Controle de Acesso

### Perfil Padrão

Foi utilizado apenas um perfil padrão (**Standard Platform User**) como configuração inicial de acesso.

Essa abordagem reduz a quantidade de perfis na organização e segue uma das recomendações da arquitetura moderna do Salesforce, onde o perfil concede apenas permissões básicas e os acessos específicos são distribuídos através de **Permission Sets**.

### Permission Set — Recepcionista

Foi criado um **Permission Set** específico para os usuários responsáveis pelo atendimento da recepção.

#### Permissões concedidas

- Criar Tutores;
- Editar Tutores;
- Criar Pets;
- Editar Pets;
- Criar Agendamentos;
- Editar Agendamentos;
- Visualizar informações básicas dos veterinários.

#### Restrições

- Sem permissão para excluir registros;
- Sem permissão para criar veterinários;
- Sem permissão para editar veterinários;
- Sem permissão para acessar informações administrativas;
- Sem permissões **View All** ou **Modify All**.

Essa estratégia torna a administração de permissões mais flexível, reutilizável e escalável, evitando a criação de múltiplos perfis para diferentes funções.

---

## Organização da Segurança

### Organization-Wide Defaults (OWD)

O **Organization-Wide Defaults (OWD)** foi configurado como **Private** para o objeto **Vet**, estabelecendo o nível mais restritivo de acesso aos registros.

Com essa configuração:

- Nenhum usuário visualiza registros automaticamente;
- Todo acesso depende de regras adicionais de compartilhamento;
- A exposição indevida de informações é reduzida;
- A segurança da aplicação passa a ser controlada por camadas superiores.

Essa configuração representa a base da política de governança adotada no projeto.

---

### Role Hierarchy

A **Role Hierarchy** foi implementada para representar a estrutura organizacional da clínica veterinária.

```text
CEO
│
├── Veterinarian
│
└── Receptionist
```

Essa organização permite que a hierarquia reflita as responsabilidades reais da empresa e facilita a administração das permissões conforme o crescimento da organização.

---

### Sharing Rules

O **OWD** foi definido como **Private**, e **Sharing Rules** para conceder acesso controlado aos registros do objeto **Vet**.

A regra criada:

- **Read Only**
- Grupo de destino: **Receptionists**

Dessa forma, a recepcionista consegue localizar veterinários durante o processo de agendamento sem receber permissões de edição ou administração.

Esse modelo mantém a segurança dos registros enquanto fornece o acesso mínimo necessário para execução das atividades operacionais.

---

## Segurança em Nível de Campo

### Field-Level Security (FLS)

Mesmo possuindo acesso ao registro do veterinário, a recepcionista não visualiza todos os campos.

Foi aplicada uma configuração de **Field-Level Security (FLS)** permitindo acesso apenas às informações indispensáveis para o atendimento.

#### Campos visíveis

- Nome do Veterinário;
- E-mail.

#### Campos ocultos

- CRMV;
- Telefone;
- Especialidade;
- Dias Disponíveis;
- Status;
- Campos administrativos.

Essa camada garante que informações sensíveis permaneçam protegidas independentemente do acesso concedido ao registro.

---

## Personalização da Interface

### Dynamic Forms

Os **Dynamic Forms** foram implementados para personalizar dinamicamente a interface do objeto **Vet**, exibindo apenas as informações relevantes de acordo com o perfil funcional e as permissões atribuídas ao usuário.

Essa abordagem permitiu segmentar a visualização dos campos sem a necessidade de múltiplos Page Layouts, proporcionando uma interface mais intuitiva, organizada e alinhada às responsabilidades de cada função dentro da aplicação.

> **Observação:** Os Dynamic Forms foram utilizados em conjunto com **Field-Level Security (FLS)**. Enquanto os Dynamic Forms controlam a experiência de visualização da interface, o FLS garante a proteção efetiva dos dados em nível de campo.

### Page Layout

O **Lightning Record Page** do objeto **Vet** foi configurado utilizando **Dynamic Forms**, criando seções específicas para diferentes tipos de usuários.

Campos (Field Section) criados:

    • Basic Information: Adicionados Vet Name e Email. Filtro criado apenas para visualização de Standart Platform User.
      
    • Administrative Information: Adicionados os demais campos que foram ocultados. Filtro criado apenas para visualização de System Administrator


Para o perfil de **Recepcionista**, a interface foi simplificada para exibir exclusivamente os campos necessários ao processo de agendamento de consultas:

- **Vet Name**
- **Email**

Os demais campos permanecem ocultos para esse perfil, reduzindo a exposição de informações administrativas e sensíveis, sem comprometer a funcionalidade do campo **Lookup** utilizado no objeto **Appointment**.

---

## Governança de Permissões

Toda a arquitetura foi construída utilizando uma estratégia em camadas:

1. **Profile** define permissões básicas;
2. **Permission Sets** concedem permissões adicionais específicas;
3. **Organization-Wide Defaults (OWD)** restringe o acesso aos registros;
4. **Role Hierarchy** organiza a estrutura corporativa;
5. **Sharing Rules** compartilham apenas os registros necessários;
6. **Field-Level Security (FLS)** protege informações sensíveis;
7. **Dynamic Forms** personalizam a interface para cada usuário.

---

## Princípio do Menor Privilégio (Least Privilege)

Toda a arquitetura de segurança foi desenvolvida com base no **Princípio do Menor Privilégio (Least Privilege)**.

Cada usuário recebe apenas as permissões estritamente necessárias para executar suas atividades, reduzindo riscos de acesso indevido e fortalecendo a governança da aplicação.

---

## Conclusão

A camada de segurança do **Belle VetCare CRM** foi projetada utilizando uma arquitetura baseada em múltiplos mecanismos nativos do Salesforce, combinando **Organization-Wide Defaults (OWD)**, **Role Hierarchy**, **Sharing Rules**, **Permission Sets**, **Field-Level Security (FLS)** e **Dynamic Forms** para garantir proteção em diferentes níveis.

---

# Análise e Relatórios

## Custom Report Type

Baseado no objeto Appointment__c para estruturar dados analíticos.

## Relatórios Implementados

### Consultas por Dia

- Exibe volume diário de consultas
- Útil para acompanhamento operacional

### Consultas por Mês

- Agrega dados mensais
- Identifica tendências de atendimento

### Consultas por Veterinário

- Distribuição de carga de trabalho
- Identifica especialista mais demandado

### Tipos de Atendimento por Mês

- Categoriza atendimentos (consulta, vacinação, cirurgia)
- Oferece visão de demanda por tipo de serviço

## Dashboard Operacional

Componentes gráficos para gestão em tempo real:

| Componente | Tipo | Métrica |
|-----------|------|--------|
| Metric Chart | Gráfico de linha | Quantidade de consultas por dia |
| Horizontal Bar Chart | Total de consultas no mês |
| Horizontal Bar Chart | Gráfico de barras | Veterinário com mais consultas |
| Donut Chart | Gráfico de pizza | Distribuição de tipos de atendimento |

---

# Stack Tecnológico

| Componente | Tecnologia |
|-----------|-----------|
| Plataforma | Salesforce |
| Automação | Flow (Record-Triggered e Autolaunched) |
| Interface | Lightning (App, Pages, Components, Layout) |
| Relatórios | Salesforce Reports & Dashboards |
| Bot | Salesforce Enhanced Bot |
| Banco de Dados | Salesforce Objects e Fields |

---

# Competências Demonstradas

## Salesforce Administration

- Modelagem de objetos customizados
- Criação e configuração de campos
- Definição de relacionamentos (Lookup)
- Organização de Lightning App Builder
- Configuração de perfil e permission sets
- Implementação de field-level security
- Criação de custom report types
- Design de relatórios e dashboards

## Salesforce Automation & Development

- Construção de lógica de negócio com Flow
- Record-Triggered Flows para notificações
- Autolaunched Flows para bot e atendente
- Integração de e-mail automático
- Validação de dados com CPF e CEP
- Desenho de fluxo de agendamento
- Implementação de atendimento digital com bot

## Visão de Negócio

- Tradução de operação clínica em arquitetura CRM
- Organização de jornada de atendimento
- Separação entre cadastro, agendamento, cancelamento e indicadores
- Aplicação de segurança conforme perfil operacional

---

# Resultados Entregues

O projeto Belle VetCare consolidou em uma única plataforma:

- Cadastro organizado de tutores e pets
- Gerenciamento de quadro veterinário
- Controle centralizado de agendamentos
- Automação de notificações por e-mail
- Segurança granular por perfil
- Visibilidade operacional via relatórios
- Atendimento digital automatizado com bot
- Dashboard para tomada de decisão

---

# Conclusão

O Belle VetCare CRM representa um case completo de desenvolvimento Salesforce que integra modelagem de dados, segurança, automação, analytics e atendimento digital. O projeto posiciona para vagas com foco em **Salesforce Administrator** ou **Salesforce Developer/Automation**, demonstrando domínio prático da plataforma em diferentes camadas da solução.

---

# Informações do Projeto

- **Tipo**: Projeto de Portfolio / Case Estudo
- **Plataforma**: Salesforce Developer Org
- **Escopo**: CRM Customizado
- **Área de Negócio**: Saúde Animal / Clínica Veterinária
- **Status**: Completo e Funcional

---

**Desenvolvido como demonstração prática de competências em Salesforce Administration e Development**

Elaborado por **Thiago de Souza** — Salesforce Developer & Administrator
