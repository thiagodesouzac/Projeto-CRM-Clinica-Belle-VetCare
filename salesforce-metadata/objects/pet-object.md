# Pet Object

## Label

Pet

## API Name

Pet__c

## Finalidade

Representa o cadastro do Pet.

---

## Campos Principais

| Campo | API | Tipo |
|--------|-----|------|
| Age | Age__c | Number(16, 2) |
| Breed | Breed__c | Text |
| Pet Name | Name | Text |
| Pet Species | Pet_Species__c | Picklist |
| Sex | Sex__c | Picklist |
| PetOwner | Pet_Owner__c | Lookup(PetOwner) |
| Vet | Vet__c | Lookup(Vet) |
| Weight | Weight__c | Number(16, 2) |

---

## Relacionamentos

Pet → PetOwner

Pet → Vet

## Utilização

Utilizado pelos Flows e Einstein Bot para criação automática do cadastro do Pet.