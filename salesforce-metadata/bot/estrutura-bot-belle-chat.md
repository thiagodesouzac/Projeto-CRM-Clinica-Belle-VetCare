# Fluxo Completo da Jornada do ChatBot – Belle VetCare CRM

## Visão Geral
O Bot é o ponto de entrada do atendimento digital da Clínica Belle VetCare. 
Seu objetivo é automatizar o cadastro, agendamento, cancelamento e transferência para atendimento humano, utilizando Flows do Salesforce para executar regras de negócio.

## Menu Principal
1. Cadastrar
2. Agendar Consulta
3. Falar com Atendente
4. Encerrar

## Jornada Completa

### Saudação
O bot recebe o usuário e apresenta o menu principal.

### 1. Cadastro
O bot coleta os dados do tutor e do pet em uma sequência lógica.

- Coleta dados do tutor.
- Coleta dados do pet.
- Executa validações.
- Cria registros no Salesforce.
- Exibe confirmação.
- Direciona para agendamento.

1. Nome do tutor
2. CPF
3. Telefone
4. Email
5. CEP
6. Endereço
7. Nome do pet
8. Espécie
9. Raça
10. Sexo

Ao final, apresenta um resumo do cadastro e direciona o usuário para:
- Agendar consulta
- Falar com atendente
- Encerrar

### 2. Agendamento
Antes de criar uma consulta, o bot identifica o tutor através do CPF.

- Solicita CPF.
- Localiza cadastro.
- Solicita data e horário.
- Exibe resumo.
- Confirma criação da consulta.

Se confirmado:

- cria o agendamento
- apresenta a confirmação

Se não confirmado:

- retorna ao fluxo de agendamento.

### 3. Falar com Atendente
Caso o usuário deseje atendimento humano, o bot transfere a conversa para o Omni-Channel.

Benefícios

- evita abandono do atendimento
- mantém continuidade da conversa

# Limitações do Preview de Conversa:

- O preview de teste tem limitações.
- Não consegue transferir para um agente real. 
- Conectar ao Omni-Channel.
- Verificar agentes online.
- Verificar Presence Status.
- Verificar filas.
- Criar uma sessão real de Messaging.
- Simular aceitação do agente.

### 4. Encerramento
Finaliza a sessão de forma amigável e informa que uma nova mensagem inicia outro atendimento.

## Lógica do Bot

O fluxo foi dividido em blocos independentes para reduzir complexidade e facilitar manutenção.

Cada decisão valida informações antes de prosseguir:
- CPF identifica o tutor.
- Cadastro cria Tutor e Pet.
- Agendamento depende da existência do cadastro.
- Transferência encerra a automação.

# Fluxo de Interação

```text
Cliente
   │
   ▼
Menu Principal
   │
   ├── Cadastro
   │      ▼
   │  Flow Cadastro Tutor + Pet
   │
   ├── Agendamento
   │      ▼
   │  Validação CPF
   │      ▼
   │  Flow Agendar Consulta
   │      ▼
   │  Realiza o agendamento   │
   │
   ├── Falar com Atendente
   |       ▼
   |   Omni-Channel 
   |
   └── Encerrar 
```

## Pontos Fortes

- Conversação guiada.
- Fluxo modular.
- Integração com Salesforce Flows.
- Validação antes das operações.
- Reutilização de dados.
- Escalabilidade.
- Fácil manutenção.
- Boa experiência do usuário.

## Arquitetura Resumida

Usuário → Bot → Dialog → Decision → Salesforce Flow → Objetos (Tutor, Pet, Agendamento) → Resposta ao usuário.
