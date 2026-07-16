# PetOwner Object

## Label

PetOwner

## API Name

Pet_Owner__c

## Finalidade

Representa o cadastro do tutor.

---

## Campos Principais

| Campo | API | Tipo |
|--------|-----|------|
| Address | Address__c | Text Area |
| CEP | CEP__c | Text |
| CPF | CPF__c | Text |
| Email | Email__c | Email |
| Phone | Phone__c | Phone |
| Pet   | Pet__c | Lookup(Pet)
| Quantity Pet | Quantity__c | Number(16,2) |
| PetOwner Name | Name | Text |

---

## Utilização

Utilizado pelos Flows e Einstein Bot para criação automática do cadastro do tutor.