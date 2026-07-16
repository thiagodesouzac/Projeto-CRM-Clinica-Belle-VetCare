# Flow – Register PetOwner Pet

## Propósito

O **Flow Cadastrar Tutor e Pet** é responsável por automatizar o cadastro de um tutor e do seu respectivo pet em uma única execução. O processo garante que o tutor seja criado primeiro, permitindo o vínculo correto entre os registros e retornando informações sobre o sucesso ou falha da operação.

---

## Tipo de Flow

- **Tipo:** Autolaunched Flow
- **Execução:** Automática, sem interação com telas.

---

## Estrutura do Flow

O fluxo segue a seguinte sequência:

```text
Start
   │
   ▼
Criar Tutor
   │
   ├── Falha → Retorna erro e encerra
   │
   ▼
Registrar sucesso do Tutor
   │
   ▼
Criar Pet
   │
   ├── Falha → Retorna erro e encerra
   │
   ▼
Registrar sucesso do Pet
   │
   ▼
End
```

Cada etapa possui tratamento de erro (Fault), garantindo maior confiabilidade durante a execução. 

---

## Variáveis de Entrada

O Flow recebe as seguintes informações:

| Variável | Descrição |
|----------|-----------|
| `inAddress` | Endereço do Tutor |
| `inCEP` | CEP do Tutor |
| `inCPF` | CPF do Tutor |
| `inEmail` | E-mail do Tutor |
| `inPhone` | Telefone do Tutor |
| `inBreed` | Raça do Pet |
| `inPetName` | Nome do Pet |
| `inSpecies` | Espécie do Pet |
| `inPetSex` | Sexo do Pet |

---

## Variáveis de Saída

| Variável | Descrição |
|----------|-----------|
| `outTutorCriado` | Indica se o Tutor foi criado com sucesso |
| `outTutorId` | ID do Tutor criado |
| `outPetCriado` | Indica se o Pet foi criado com sucesso |
| `outPetID` | ID do Pet criado |
| `outMensagemErro` | Mensagem de erro em caso de falha |

---

## Lógica de Negócio

O Flow cria inicialmente o registro do Tutor (PetOwner). Após a criação bem-sucedida, utiliza o ID gerado para criar o registro do Pet, estabelecendo o relacionamento entre ambos.

Caso ocorra erro na criação do Tutor, o processo é encerrado imediatamente, impedindo a criação de um Pet sem vínculo. Caso a criação do Tutor seja concluída, mas a criação do Pet apresente falha, o Flow informa a ocorrência por meio das variáveis de saída, permitindo que o sistema trate a situação adequadamente.

---

## Casos de Uso

Este Flow pode ser utilizado em diferentes cenários, como:

- Cadastro realizado pelo Enhanced Bot.
- Cadastro através de formulários externos integrados ao Salesforce.
- Processos internos de onboarding de clientes.
- Importação e migração de dados de tutores e pets.
- Subflow reutilizável em outros processos automatizados.

---

## Resumo

O **Flow Cadastrar Tutor e Pet** centraliza o processo de criação de tutores e seus respectivos pets, garantindo a ordem correta das operações, o relacionamento entre os registros e o tratamento de falhas em cada etapa. 

Sua implementação permite reutilização em diferentes processos da plataforma Salesforce, promovendo padronização, integridade dos dados e maior confiabilidade na automação dos cadastros.