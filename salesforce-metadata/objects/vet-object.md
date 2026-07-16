# Vet Object

## Label

Vet

## API Name

Vet__c

## Finalidade

Representa o cadastro da veterinária

---

## Campos Principais

| Campo | API | Tipo |
|--------|-----|------|
| Available_Days | Available_Days__c | Picklist (Multi-Select) |
| CRMV | CRMV__c | Text |
| Email | Email__c | Email |
| Phone | Phone__c | Phone |
| Pet   | Pet__c | Lookup(Pet)
| Specialty | Specialty__c | Picklist |
| Status | Status__c | Picklist |
| Species | Species__c | Picklist |
| Status | Status__c | Picklist |
| Vet Name | Name | Text |

---

## Relacionamentos

Pet

---

## Utilização

Utilizado pelos Flows e Einstein Bot para criação automática do cadastro da veterinária.