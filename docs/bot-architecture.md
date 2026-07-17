# Arquitetura do Bot — Belle VetCare CRM

## Visão Geral

O Belle VetCare CRM inclui um **Enhanced Bot** projetado para automatizar parte da jornada de atendimento da clínica veterinária.

O objetivo do bot é oferecer um canal digital inicial para o cliente, permitindo que ele:

- realize o cadastro do tutor e do pet;
- solicite agendamento de atendimento;
- fale com um atendente quando necessário.

A arquitetura do bot foi desenhada para integrar experiência do usuário, validação de cadastro e automações em Salesforce.

---

# 1. Objetivo do Einstein Bot

Ao entrar em contato com a clínica, o usuário visualiza um menu principal com quatro opções:

1. **Cadastrar**
2. **Agendar Consulta**
3. **Falar com Atendente**
4. **Encerrar**

Essa estrutura foi criada para guiar o usuário de forma simples e objetiva, respeitando a lógica operacional da clínica.

---

# 2. Regras de Funcionamento

A jornada do bot foi estruturada com uma regra principal:

## Regra central de negócio
O usuário precisa realizar o cadastro do tutor e do pet antes de solicitar um agendamento.

Com base nisso, o fluxo do bot funciona da seguinte forma:

- ao selecionar **Agendar consulta**, o bot solicita o CPF do tutor;
- o CPF é validado para verificar se o tutor já possui cadastro;
- se o CPF for reconhecido, o usuário pode prosseguir com o agendamento;
- se o CPF não estiver cadastrado, o usuário é direcionado para a etapa de cadastro;
- ao selecionar **Falar com atendente**, o bot transfere o atendimento para a clínica.

---

# 3. Jornada do Cliente no Einstein Bot

A jornada principal foi desenhada para conduzir o cliente do primeiro contato até a solicitação do atendimento.

## Fluxo principal

1. O usuário entra no menu do bot;
2. Escolhe entre **cadastrar** ou **agendar**;
3. Se escolher agendar, o bot solicita o CPF;
4. O CPF é validado;
5. Se o CPF existir, o usuário segue para seleção do pet e agendamento;
6. Se o CPF não existir, o usuário é direcionado para o cadastro;
7. Após o cadastro, o sistema cria o tutor e o pet;
8. O usuário retorna ao fluxo de atendimento/agendamento.

---

# 4. Componentes da Arquitetura do Bot

A solução do bot foi estruturada com apoio de flows autolaunched, responsáveis por executar as ações de cadastro, validação e agendamento.

## 4.1 Bot Register PetOwner Pet

### Objetivo
Criar o cadastro do tutor e pet diretamente pela jornada do bot.

### Campos utilizados
- Nome
- CPF
- Email
- Telefone
- Endereço
- CEP
- Nome do pet
- Espécie do pet
- Raça

### Papel na arquitetura
Esse flow representa a primeira etapa da base cadastral do cliente no CRM e garante que o pet exista na base antes do agendamento.

---

## 4.2 Bot Validate PetOwner CPF

### Objetivo
Busca e valida se o tutor informado já está cadastrado na clínica.

### Campo utilizado
- CPF

### Regra aplicada
O flow verifica se já existe um registro de tutor com o CPF informado.

### Papel na arquitetura
Esse flow sustenta a regra central da jornada, impedindo que o agendamento seja feito sem um cadastro prévio.

---

## 4.3 Bot Schedule Appointment

### Objetivo
Realizar o agendamento do atendimento pelo bot.

### Estrutura do flow
- captura do CPF;
- busca do tutor por CPF;
- captura do nome do pet;
- captura da espécie;
- captura do tipo de atendimento;
- captura da data do atendimento;
- captura da hora do atendimento.

### Papel na arquitetura
Esse flow materializa a etapa de agendamento dentro da jornada digital e conecta o bot ao objeto `Appointment__c`.

---

## 4.4 Bot Route to Belle Chat

### Objetivo
Transferir o atendimento para um atendente humano via Omni-Channel e Agentforce.

### Papel na arquitetura
Esse fluxo oferece uma saída humana para o atendimento quando o usuário deseja falar com um atendente da clínica.

---

# 5. Arquitetura Lógica da Jornada

A jornada do bot pode ser resumida em três blocos principais:

## Bloco 1 — Entrada no atendimento
O usuário acessa o bot e escolhe uma opção do menu principal.

## Bloco 2 — Validação da jornada
Se o usuário quiser agendar, o sistema verifica se o tutor já está cadastrado por CPF.
Ou se quiser cancelar uma consulta, o sistema verifica se o tutor já tem alguma consulta marcadapelo CPF, nome do pet, data e hora.

## Bloco 3 — Execução do processo
Dependendo da validação:
- o usuário segue para cadastro;
- ou segue diretamente para o agendamento;
- ou segue diretamente para o cancelamento;
- ou é transferido para atendimento humano.

---

# 6. Papel do Bot no Projeto

O bot foi incluído no Belle VetCare CRM para demonstrar a capacidade de construir uma experiência digital integrada ao Salesforce, combinando:

- coleta de dados do cliente;
- criação de registros no CRM;
- validação de CPF;
- decisão de fluxo;
- agendamento automatizado;
- transferência para atendimento humano.

---

# 7. Resultado da Arquitetura do Einstein Bot

A camada de bot do Belle VetCare CRM amplia a solução além da operação interna da clínica e mostra como o Salesforce pode ser utilizado para criar uma jornada digital de atendimento.

O resultado é uma experiência que conecta:

- **cadastro**
- **validação**
- **agendamento**
- **atendimento humano**
- **encerrar**

em um único fluxo operacional, apoiado por automações dentro da plataforma.