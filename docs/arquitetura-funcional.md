# Arquitetura Funcional — Belle VetCare CRM

## Visão Geral da Solução

O **Belle VetCare CRM** foi desenvolvido em Salesforce com o objetivo de centralizar e organizar a operação de uma clínica veterinária em um único ambiente. A solução foi estruturada para suportar o cadastro de tutores, pets e veterinários, o agendamento de consultas, a automação de notificações operacionais e a disponibilização de um atendimento digital via bot.

A proposta do projeto foi criar um CRM funcional que demonstrasse, de forma prática, competências de **Salesforce Administrator** e **Salesforce Developer**, cobrindo modelagem de dados, automação com Flow, segurança, analytics e experiência do usuário.

---

## Objetivo do CRM

O CRM da Belle VetCare foi desenhado para apoiar o processo de atendimento da clínica desde o primeiro contato do cliente até o agendamento da consulta.

Os principais objetivos da solução foram:

- centralizar os dados da clínica em um único ambiente Salesforce;
- registrar e relacionar tutores, pets, veterinários e consultas;
- padronizar o processo de agendamento;
- automatizar notificações operacionais para reduzir trabalho manual;
- controlar acessos e visibilidade de dados sensíveis;
- oferecer atendimento digital via bot, com cadastro, validação e agendamento;
- gerar indicadores operacionais por meio de relatórios e dashboards.

---

## Escopo Funcional da Solução

A solução foi estruturada para atender os principais processos operacionais da clínica:

- **Cadastro de tutores**: registro dos responsáveis pelos pets;
- **Cadastro de pets**: armazenamento de informações clínicas e vínculo com tutor e veterinário;
- **Cadastro de veterinários**: controle de dados cadastrais, especialidade, disponibilidade e status;
- **Agendamento de consultas**: criação e acompanhamento de atendimentos;
- **Automação operacional**: envio de alertas por e-mail relacionados a consultas;
- **Atendimento digital**: jornada automatizada via bot para cadastro, validação de CPF, agendamento e transferência para atendimento humano;
- **Análise operacional**: relatórios e dashboard com indicadores de consultas e atendimentos.

---

## Arquitetura da Solução

A arquitetura do CRM foi construída com base em quatro objetos principais:

- `Tutor__c`
- `Pet__c`
- `Vet__c`
- `Appointment__c`

Essa estrutura foi definida para representar a operação da clínica de forma organizada e escalável, separando responsabilidades por domínio de negócio:

### Tutor__c
Representa o responsável pelo pet e concentra os dados cadastrais do cliente da clínica.

### Pet__c
Representa o animal atendido pela clínica, armazenando suas informações clínicas e mantendo vínculo com tutor e veterinário.

### Vet__c
Representa os profissionais veterinários, permitindo o controle de informações cadastrais, especialidade, disponibilidade e status.

### Appointment__c
Representa os agendamentos e conecta tutor, pet, tipo de atendimento, data e hora da consulta.

---

## Jornada Operacional da Clínica no CRM

A modelagem e as automações foram pensadas para sustentar a jornada principal da clínica dentro do Salesforce.

### Fluxo operacional principal

1. A clínica registra o **tutor** no CRM;
2. O **pet** é cadastrado e vinculado ao tutor;
3. O **veterinário** é cadastrado com suas informações profissionais;
4. A recepção agenda uma **consulta** no objeto `Appointment__c`;
5. O sistema executa automações relacionadas ao atendimento;
6. O veterinário recebe notificações por e-mail quando necessário;
7. Os relatórios e o dashboard refletem a operação da clínica.

---

## Arquitetura Funcional do Atendimento Digital

Além da camada operacional do CRM, o projeto inclui um **Enhanced Bot** para automatizar parte da jornada do cliente.

O bot foi desenhado com cinco opções principais de atendimento:

- **Cadastrar Tutor e Pet**
- **Agendar atendimento**
- **Cancelar Consulta**
- **Falar com atendente**
- **Encerrar**

A lógica de atendimento foi estruturada da seguinte forma:

- o tutor precisa estar cadastrado antes de solicitar um agendamento;
- ao escolher agendar, o bot solicita o CPF do tutor;
- se o CPF existir, o atendimento segue para agendamento;
- se o CPF não existir, o usuário é direcionado para o fluxo de cadastro;
- se o usuário quiser falar com atendente, o bot transfere o atendimento.

---

## Componentes da Solução

O projeto reúne componentes de diferentes frentes da plataforma Salesforce:

### Camada de Dados
- objetos customizados;
- campos customizados;
- relacionamentos lookup;
- validações de dados.

### Camada de Segurança
- profile;
- permission set;
- field-level security;
- restrições de acesso por perfil operacional.

### Camada de Automação
- record-triggered flows;
- autolaunched flows;
- envio automático de e-mails.

### Camada de Analytics
- custom report type;
- relatórios operacionais;
- dashboard com indicadores da clínica.

### Camada de Atendimento Digital
- Enhanced Bot;
- validação de CPF;
- cadastro de tutor e pet;
- agendamento automatizado;
- transferência para atendimento humano.

---

## Resultado da Arquitetura

A arquitetura do Belle VetCare CRM foi construída para demonstrar uma solução de CRM completa em Salesforce, conectando:

- dados de clientes, pets e profissionais;
- operação de agendamento;
- segurança de acesso;
- automação operacional;
- indicadores de negócio;
- atendimento digital via bot.

Essa estrutura evidencia a capacidade de desenhar uma solução funcional de ponta a ponta dentro do ecossistema Salesforce.