## Fluxo para validar o CPF do usuário

# Flow Validate PetOwner

## 1. Propósito

Automatizar a validação de tutores da Clínica Belle VetCare utilizando o CPF informado pelo usuário.

O objetivo deste Flow é verificar se já existe um tutor cadastrado no sistema antes que outros processos, como cadastro ou agendamento de consultas, sejam iniciados.

Ao final da execução, o Flow retorna ao Agent se o tutor foi localizado e disponibiliza as informações necessárias para continuidade do atendimento.

---

## 2. Tipo de Flow

**Autolaunched Flow** (Flow autoiniciado), projetado para ser invocado por um Agent ou outro processo do Salesforce, recebendo parâmetros de entrada e retornando variáveis de saída.

---

## 3. Estrutura do Flow

O Flow executa uma única validação para identificar se existe um tutor cadastrado com o CPF informado.

1. **Start**
   - Início do Flow.

2. **Find Pet Owner (Get Records)**
   - Localiza o tutor utilizando o CPF informado.

3. **Pet Owner Found? (Decision)**

   Verifica se um tutor foi localizado.

   **Caso encontrado:**

   - Define o retorno de sucesso.
   - Disponibiliza as informações do tutor.
   - Finaliza o Flow.

   **Caso não encontrado:**

   - Define o retorno informando que o tutor não possui cadastro.
   - Finaliza o Flow.

4. **End**

   Encerramento do Flow.

---

## 4. Variáveis de Entrada

| Variável | Descrição |
|----------|-----------|
| `inCPF` | CPF informado pelo tutor para validação do cadastro |

---

## 5. Variáveis de Saída

| Variável | Descrição |
|----------|-----------|
| `outSuccess` | Indica se o tutor foi localizado |
| `outMessage` | Mensagem retornada pelo Flow |
| `outErrorCode` | Código do resultado da validação |
| `outOwnerId` | Identificador do tutor localizado |
| `outOwnerName` | Nome do tutor localizado |

---

## 6. Lógica de Negócio

O Flow executa uma única validação para identificar a existência do tutor.

### 1. Localização do Tutor

O Flow realiza uma consulta utilizando o CPF informado.

Caso exista um cadastro correspondente, o tutor é considerado válido para continuidade do atendimento.

### 2. Tutor Encontrado

Quando o tutor é localizado, o Flow retorna:

- confirmação da localização do cadastro;
- identificador do tutor;
- nome do tutor.

Essas informações podem ser utilizadas pelos processos seguintes, como agendamento de consultas.

### 3. Tutor Não Encontrado

Quando nenhum cadastro é localizado para o CPF informado, o Flow retorna que o tutor não foi encontrado.

Essa resposta permite que o Agent direcione o usuário para o processo de cadastro.

Toda a decisão sobre o próximo passo permanece sob responsabilidade do Agent.

---

## 7. Casos de Uso

- Validação de tutor antes do cadastro.
- Validação de tutor antes do agendamento de consultas.
- Identificação de clientes durante atendimentos automatizados.
- Reutilização por outros Flows e processos automatizados da plataforma Salesforce.
- Integração com canais digitais de atendimento.

---

## 8. Resumo

O **Flow Validate PetOwner** centraliza todo o processo de validação de tutores da Clínica Belle VetCare.

Durante sua execução, o Flow consulta a base de dados utilizando o CPF informado, verifica se existe um tutor cadastrado e retorna o resultado da validação juntamente com as informações necessárias para continuidade do atendimento.

Essa arquitetura elimina a duplicidade de validações em diferentes processos, concentra a lógica de identificação em um único Flow e permite sua reutilização por qualquer serviço da plataforma.

O resultado da execução é retornado por meio das variáveis `outSuccess`, `outMessage`, `outErrorCode`, `outOwnerId` e `outOwnerName`, permitindo que o Agent tome a decisão adequada para cada cenário de atendimento.