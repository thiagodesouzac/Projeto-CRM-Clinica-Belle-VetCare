## Fluxo de cadastro do tutor e pet

## Flow Register Owner and Pet

## 1. Propósito

Automatizar o cadastro de tutores e seus respectivos pets em uma única execução, garantindo que ambos sejam registrados corretamente e vinculados entre si.

O processo realiza primeiro o cadastro do tutor e, após sua criação, registra o pet utilizando o relacionamento com o tutor recém-criado. Ao final da execução, o Flow retorna o resultado da operação para o Agent.

---

## 2. Tipo de Flow

**Autolaunched Flow** (Flow autoiniciado), projetado para ser invocado por um Agent ou outro processo do Salesforce, recebendo parâmetros de entrada e retornando variáveis de saída.

---

## 3. Estrutura do Flow

O Flow executa o cadastro em duas etapas sequenciais.

1. **Start**
   - Início do Flow.

2. **Create Pet Owner (Create Records)**
   - Cria o cadastro do tutor utilizando as informações fornecidas.

   **Caso ocorra erro:**
   - Retorna a mensagem de erro.
   - Finaliza o Flow.

3. **Create Pet (Create Records)**
   - Cria o cadastro do pet utilizando o identificador do tutor criado anteriormente.

   **Caso ocorra erro:**
   - Retorna a mensagem de erro.
   - Finaliza o Flow.

4. **Success Return (Assignment)**

   Em caso de sucesso:

   - outSuccess = True
   - outMessage = Cadastro realizado com sucesso.
   - outOwnerId = Identificador do tutor criado.
   - outPetId = Identificador do pet criado.

5. **End**

   Encerramento do Flow.

---

## 4. Variáveis de Entrada

| Variável | Descrição |
|----------|-----------|
| `inOwnerName` | Nome completo do tutor |
| `inCPF` | CPF do tutor |
| `inEmail` | E-mail do tutor |
| `inPhone` | Telefone do tutor |
| `inCEP` | CEP do tutor |
| `inAddress` | Endereço do tutor |
| `inPetName` | Nome do pet |
| `inSpecies` | Espécie do pet |
| `inBreed` | Raça do pet |
| `inPetSex` | Sexo do pet |

---

## 5. Variáveis de Saída

| Variável | Descrição |
|----------|-----------|
| `outSuccess` | Indica se o cadastro foi realizado com sucesso |
| `outMessage` | Mensagem retornada pelo Flow |
| `outOwnerId` | Identificador do tutor criado |
| `outPetId` | Identificador do pet criado |

---

## 6. Lógica de Negócio

O Flow executa o cadastro de forma sequencial, garantindo a integridade do relacionamento entre tutor e pet.

### 1. Cadastro do Tutor

Inicialmente é criado o registro do tutor.

Após a criação, o Salesforce gera automaticamente o identificador do novo tutor.

Esse identificador será utilizado na etapa seguinte.

### 2. Cadastro do Pet

Após a criação do tutor, o Flow cria o registro do pet.

O pet é automaticamente vinculado ao tutor criado anteriormente, estabelecendo o relacionamento entre ambos.

### 3. Tratamento de Erros

Caso ocorra qualquer erro durante a criação do tutor, o processo é encerrado imediatamente e nenhum pet é criado.

Caso o tutor seja criado com sucesso, mas ocorra erro durante a criação do pet, o Flow interrompe o processo e retorna a mensagem correspondente ao erro.

Essa abordagem impede a criação de registros inconsistentes e garante maior confiabilidade ao processo de cadastro.

---

## 7. Casos de Uso

- Cadastro realizado pelo Agent da Clínica Belle VetCare.
- Cadastro de novos tutores e pets durante o atendimento virtual.
- Cadastro realizado por integrações externas.
- Processos internos de registro de clientes.
- Reutilização como componente em outros processos automatizados da plataforma Salesforce.

---

## 8. Resumo

O **Flow Register PetOwner and Pet** centraliza todo o processo de cadastro de tutores e pets em uma única automação.

Durante sua execução, o Flow cria inicialmente o tutor e, em seguida, registra o pet utilizando o relacionamento com o tutor recém-criado.

Essa arquitetura garante a integridade dos dados, evita a criação de pets sem tutor vinculado e concentra toda a lógica de cadastro em um único processo reutilizável.

O resultado da execução é retornado por meio das variáveis `outSuccess`, `outMessage`, `outOwnerId` e `outPetId`, permitindo que o Agent conduza o atendimento utilizando exclusivamente as informações retornadas pelo Flow.