# Flow Bot Validate PetOwner CPF

Flow de automação construído no **Salesforce Flow Builder** responsável por validar se um **Tutor (PetOwner)** já está cadastrado no sistema, utilizando o **CPF** como chave de busca.

---

## Propósito

O objetivo deste flow é centralizar e padronizar a **validação de tutores de pets** a partir do CPF informado, evitando cadastros duplicados e garantindo que processos subsequentes (ex.: agendamento de consultas, cadastro de pets, atendimentos de bot/chatbot) só avancem com a confirmação de que o tutor existe (ou não) na base.

Ele funciona como um **serviço reutilizável**: recebe um CPF como entrada, consulta a base de PetOwners e retorna informações padronizadas sobre o resultado da busca, que podem ser consumidas por outros flows, bots ou processos automatizados.

---

## Tipo de Flow

| Propriedade         | Valor             |
|---------------------|-------------------|
| Tipo                | Autolaunched Flow |


Ele não possui tela de interação com o usuário — é pensado para ser **chamado como subflow** dentro de outros processos (por exemplo, um bot de atendimento que precisa confirmar a identidade do tutor antes de continuar a conversa).

---

## Estrutura do Flow

O fluxo segue uma lógica simples de **busca → decisão → atribuição de variáveis de saída**:

```
Start
  │
  ▼
Get PetOwner (Get Records)
  │
  ▼
Registered PetOwner? (Decision)
  ├── Registered   → Found (Assignment)      → End
  └── Unregistered → Not Found (Assignment)   → End
```

### 1. **Start**
Ponto de entrada do flow. É acionado programaticamente (via subflow, Apex, bot, etc.), recebendo como entrada a variável **`inCPF`**.

### 2. **Get PetOwner (Get Records)**
Elemento responsável por consultar o objeto de Tutores (**PetOwner**) na base de dados.

**Configuração da consulta:**

| Campo | Operador | Valor |
|-------|----------|-------|
| CPF   | Equals   | `inCPF` (variável de entrada) |

**Opções adicionais:**

- **How Many Records to Store:** *Only the first record* (armazena apenas o primeiro registro encontrado)
- **How to Store Record Data:** *Automatically store all fields* (armazena automaticamente todos os campos do registro em uma variável de registro)

### 3. **Registered PetOwner? (Decision)**
Elemento de decisão que avalia se a consulta anterior (`Get PetOwner`) retornou algum registro, direcionando o fluxo para um dos dois caminhos:

- **Registered** → um PetOwner foi encontrado com o CPF informado.
- **Unregistered** → nenhum PetOwner foi encontrado com o CPF informado.

### 4. **Found (Assignment)** — caminho *Registered*
Atribui os valores de saída confirmando que o tutor foi localizado:

| Variável | Operador | Valor |
|-----------|-----------|-------|
| `outPetOwnerFound` | Equals | `True` |
| `outPetOwnerID` | Equals | `Get PetOwner > Record ID` |
| `outPetOwnerName` | Equals | `Get PetOwner > Pet Owner Name` |

### 5. **Not Found (Assignment)** — caminho *Unregistered*
Atribui os valores de saída confirmando que o tutor **não** foi localizado:

| Variável | Operador | Valor |
|-----------|-----------|-------|
| `outPetOwnerFound` | Equals | `False` |
| `outPetOwnerID` | Equals | *Blank Value (Empty String)* |
| `outPetOwnerName` | Equals | *Blank Value (Empty String)* |

### 6. **End**
Encerramento do flow em ambos os caminhos, retornando as variáveis de saída para quem o invocou.

---

## Variáveis de Entrada

| Variável | Tipo | Descrição |
|-----------|------|-----------|
| `inCPF` | Text | CPF do tutor a ser validado na base de PetOwners |

## Variáveis de Saída

| Variável | Tipo | Descrição |
|-----------|------|-----------|
| `outPetOwnerFound` | Boolean | Indica se o tutor foi encontrado (`True`) ou não (`False`) |
| `outPetOwnerID` | Text | ID do registro do PetOwner encontrado (vazio se não encontrado) |
| `outPetOwnerName` | Text | Nome do tutor encontrado (vazio se não encontrado) |

---

## Lógica de Negócio

1. O flow recebe um CPF (`inCPF`) de um processo externo (bot, subflow, integração).
2. Realiza uma busca no objeto **PetOwner**, filtrando pelo campo **CPF**.
3. Caso um registro seja encontrado:
   - Marca `outPetOwnerFound` como `True`.
   - Retorna o **ID** e o **Nome** do tutor encontrado, permitindo que o processo chamador continue o atendimento já identificando o tutor.
4. Caso nenhum registro seja encontrado:
   - Marca `outPetOwnerFound` como `False`.
   - Retorna `outPetOwnerID` e `outPetOwnerName` vazios, sinalizando ao processo chamador que é necessário iniciar um **novo cadastro** de tutor.

Essa lógica evita duplicidade de cadastros e permite que bots/processos decidam automaticamente o próximo passo (seguir com o tutor já existente ou iniciar um cadastro novo) sem intervenção manual.

---

## Casos de Uso

- **Chatbot de atendimento veterinário/pet shop**: antes de agendar uma consulta ou registrar um pet, o bot chama este flow para confirmar se o tutor já está cadastrado.

- **Formulários de autoatendimento**: validação de CPF em tempo real antes de permitir o preenchimento de um novo cadastro.

- **Integrações externas (App/Site)**: qualquer sistema externo que precise validar a existência de um tutor antes de criar registros vinculados (pets, consultas, pedidos).

---

## Resumo

O **Bot Validate PetOwner CPF** é um flow autolançado, leve e reutilizável, que atua como uma camada de validação de identidade de tutores via CPF, retornando de forma padronizada se o tutor existe na base e seus principais dados (ID e Nome), servindo de base para decisões automatizadas em processos de atendimento e cadastro.
