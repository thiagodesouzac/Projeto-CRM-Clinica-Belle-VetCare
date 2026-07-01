# Clínica Belle VetCare CRM

**Solução CRM Customizada em Salesforce para Clínica Veterinária**

---

## Visão Geral

O Belle VetCare é um projeto de CRM desenvolvido em Salesforce que estrutura e automatiza a operação completa de uma clínica veterinária. A solução centraliza o cadastro de tutores, pets, veterinários e consultas em uma única plataforma, implementando automações operacionais, segurança de dados e experiência de atendimento digital.

Este projeto demonstra domínio prático em **Salesforce Administration**, **Salesforce Development**, modelagem de dados customizados, automação com Flow, segurança e implementação de bot de atendimento.

---

## Contexto do Projeto

### Desafio de Negócio

A operação de uma clínica veterinária enfrenta desafios operacionais significativos:

- Desorganização de informações dispersas entre tutor, pet e consulta
- Falta de padronização no processo de agendamento
- Dependência de ações manuais para comunicação com veterinários
- Ausência de indicadores para acompanhamento da rotina clínica
- Necessidade de triagem automatizada para reduzir fricção no atendimento

### Solução Proposta

Uma plataforma CRM centralizada que:

- Organiza cadastro de tutores e pets de forma estruturada
- Automatiza o processo de agendamento com validações
- Notifica veterinários automaticamente sobre consultas
- Fornece visibilidade operacional através de relatórios e dashboards
- Oferece atendimento inicial automatizado com bot inteligente

---

## Arquitetura da Solução

### Estrutura de Objetos Customizados

A solução foi construída sobre quatro objetos principais que representam a jornada operacional da clínica:

```
Tutor__c ←→ Pet__c
  ↓           ↓
Appointment__c ←→ Vet__c
```

#### 1. Tutor__c (Responsável pelo Pet)

| Campo | Tipo | Descrição |
|-------|------|-----------|
| Nome | Text | Nome do responsável |
| CPF | Text | CPF com validation rules |
| Email | Email | Email de contato |
| Telefone | Number | Telefone para comunicação |
| Endereço | Text | Endereço residencial |
| CEP | Text | CEP com validation rules |
| Quantidade de Pets | Number | Total de animais do tutor |

#### 2. Pet__c (Paciente)

| Campo | Tipo | Descrição |
|-------|------|-----------|
| Nome | Text | Nome do animal |
| Espécie | Text | Tipo de animal (cão, gato, etc) |
| Raça | Text | Raça do animal |
| Idade | Number | Idade em anos |
| Sexo | Text | Sexo do animal |
| Peso | Number | Peso em kg |
| Tutor | Lookup | Referência ao Tutor__c |
| Vet | Lookup | Veterinário responsável |

#### 3. Vet__c (Veterinário)

| Campo | Tipo | Descrição |
|-------|------|-----------|
| Nome | Text | Nome do veterinário |
| CRMV | Text | Registro profissional |
| Email | Email | Email corporativo |
| Telefone | Number | Telefone para contato |
| Especialidade | Picklist | Campo de especialização |
| Dias Disponíveis | Picklist | Dias de atendimento |
| Status | Picklist | Ativo ou Inativo |

#### 4. Appointment__c (Agendamento)

| Campo | Tipo | Descrição |
|-------|------|-----------|
| Data | Date | Data da consulta |
| Hora | Picklist | Horário do atendimento padronizado |
| Tutor | Lookup | Responsável pelo pet |
| Pet | Lookup | Animal a ser atendido |
| Tipo de Atendimento | Picklist | Consulta, vacinação, cirurgia, exames, internação, emergência |

---

## Funcionalidades Principais

### 1. Automação de Notificações

#### Vet Appointment Alert (Record-Triggered Flow)

Dispara automaticamente quando um agendamento é criado:

- Valida se existe veterinário vinculado
- Envia e-mail ao veterinário responsável
- Inclui dados da consulta, pet, tutor, tipo e horário

#### Vet Cancellation Alert (Record-Triggered Flow)

Notifica o veterinário quando uma consulta é cancelada:

- Valida relacionamento com veterinário
- Envia aviso de cancelamento
- Mantém registro auditável da comunicação

### 2. Validação de Dados

O projeto implementa validações robustas para garantir integridade cadastral:

- **Validação de CPF**: Fórmula de validação automática do documento
- **Validação de CEP**: Validação de formato postal
- **Regras de Relacionamento**: Garante que agendamento tenha tutor e pet válidos

### 3. Lightning App Customizado

Interface de navegação organizada para operação da clínica com tabs:

- **Pets**: Gerenciamento de pacientes
- **Tutors**: Cadastro de responsáveis
- **Vets**: Quadro de veterinários
- **Appointment**: Agendamentos e consultas
- **Reports**: Relatórios operacionais
- **Dashboards**: Indicadores gerenciais

---

## Camada de Segurança e Governança

### Modelo de Controle de Acesso

#### Perfil: Ana Recepção

Específico para operação de recepção da clínica.

#### Permissões Concedidas

- Criar e editar tutores
- Criar e editar pets
- Criar e editar veterinários
- Criar e editar agendamentos

#### Restrições Aplicadas

- Sem permissão de deletar para nenhum objeto
- Sem acesso visual ao campo CRMV dos veterinários
- Acesso limitado apenas aos registros operacionais necessários

#### Field-Level Security

O campo CRMV (Conselho Regional de Medicina Veterinária) é restrito:

- Visível apenas para administradores
- Não aparece nos registros da recepção
- Protegido por configuração de permissão de campo

### Implementação

- **Profile**: Configuração base de permissões
- **Permission Sets**: Gerenciamento adicional de acesso
- **Regras de Validação**: Garantem consistência de dados

---

## Análise e Relatórios

### Custom Report Type

Baseado no objeto Appointment__c para estruturar dados analíticos.

### Relatórios Implementados

#### Consultas por Dia
- Exibe volume diário de consultas
- Útil para acompanhamento operacional

#### Consultas por Mês
- Agrega dados mensais
- Identifica tendências de atendimento

#### Consultas por Veterinário
- Distribuição de carga de trabalho
- Identifica especialista mais demandado

#### Tipos de Atendimento por Mês
- Categoriza atendimentos (consulta, vacinação, cirurgia, exames, emergência)
- Oferece visão de demanda por tipo de serviço

### Dashboard Operacional

Componentes gráficos para gestão em tempo real:

| Componente | Tipo | Métrica |
|-----------|------|--------|
| Line Chart | Gráfico de linha | Quantidade de consultas por dia |
| Metric Chart | Card | Total de consultas no mês |
| Bar Chart | Gráfico de barras | Veterinário com mais consultas |
| Donut Chart | Gráfico de pizza | Distribuição de tipos de atendimento |

---

## Stack Tecnológico

| Componente | Tecnologia |
|-----------|-----------|
| Plataforma | Salesforce |
| Automação | Flow (Record-Triggered e Autolaunched) |
| Interface | Lightning (App, Pages, Components, Layout) |
| Relatórios | Salesforce Reports & Dashboards |
| Bot | Salesforce Enhanced Bot |
| Banco de Dados | Salesforce Objects e Fields |

---

## Fluxo Operacional Completo

### 1. Primeiro Contato

Cliente entra em contato através do bot ou recepção:

```
Cliente → Bot/Atendente → Validação CPF → Cadastro ou Recuperação
```

### 2. Cadastro

Se novo cliente:

```
Criar Tutor__c → Criar Pet__c → Validar dados → Ativar perfil
```

### 3. Agendamento

Cliente marca consulta:

```
Selecionar Pet → Escolher Data/Hora → Tipo Atendimento → Confirmar
                                              ↓
                                    Appointment__c criado
                                              ↓
                                    Record-Triggered Flow dispara
                                              ↓
                                    E-mail enviado ao Vet
```

### 4. Acompanhamento

Gestão operacional:

```
Dashboard mostra volume do dia
Relatório identifica gargalos
Vet recebe alertas automáticos
Sistema registra histórico completo
```

---

## Competências Demonstradas

### Salesforce Administration

- Modelagem de objetos customizados
- Criação e configuração de campos
- Definição de relacionamentos (Lookup)
- Organização de Lightning App
- Configuração de perfil e permission sets
- Implementação de field-level security
- Criação de custom report types
- Design de relatórios e dashboards

### Salesforce Automation & Development

- Construção de lógica de negócio com Flow
- Record-Triggered Flows para notificações
- Autolaunched Flows para bot
- Integração de e-mail automático
- Validação de dados com CPF
- Desenho de fluxo de agendamento
- Implementação de atendimento digital com bot

### Visão de Negócio

- Tradução de operação clínica em arquitetura CRM
- Organização de jornada de atendimento
- Separação entre cadastro, agendamento e indicadores
- Aplicação de segurança conforme perfil operacional

---

## Resultados Entregues

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

## Conclusão

O Belle VetCare CRM representa um case completo de desenvolvimento Salesforce que integra modelagem de dados, segurança, automação, analytics e atendimento digital. O projeto posiciona para vagas com foco em **Salesforce Administrator** ou **Salesforce Developer/Automation**, demonstrando domínio prático da plataforma em diferentes camadas da solução.

---

## Informações do Projeto

- **Tipo**: Projeto de Portfolio / Case Estudo
- **Plataforma**: Salesforce
- **Escopo**: CRM Customizado
- **Área de Negócio**: Saúde Animal / Clínica Veterinária
- **Status**: Completo e Funcional

---

**Desenvolvido como demonstração prática de competências em Salesforce Administration e Development**

Elaborado por Thiago de Souza - Salesforce Developer & Administrator
