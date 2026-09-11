@isTest
private class AppointmentTriggerHandlerTest {

    /**
     * Cria um registro de Vet para ser usado em todos os métodos de teste.
     */
    private static Vet__c createVet() {
        Vet__c vet = new Vet__c(Name = 'Dra. Cris');
        insert vet;
        return vet;
    }

    /**
       Cria um registro de Pet_Owner. O campo CPF precisa passar por uma
       validation rule do org.
     */
    private static Pet_Owner__c createPetOwner() {
        Pet_Owner__c owner = new Pet_Owner__c(
            Name = 'Joao Silva',
            CPF__c = '11122233345'
        );
        insert owner;
        return owner;
    }

    /**
     * Cria um registro de Pet vinculado a um Pet_Owner, já que
       PetOwners é obrigatório em Pet (cada pet precisa ter um dono).
     */
    private static Pet__c createPet(Id ownerId) {
        Pet__c pet = new Pet__c(Name = 'Rex', PetOwners__c = ownerId);
        insert pet;
        return pet;
    }

    //Testa o caminho feliz (Happy Path), garante que a validação não bloqueia agendamentos legítimos.
    @isTest
    static void testCreateAppointmentWithoutConflict_ShouldSucceed() {
        Vet__c vet = createVet();
        Pet_Owner__c owner = createPetOwner();
        Pet__c pet = createPet(owner.Id);

        Appointment__c appt = new Appointment__c(
            Vet__c = vet.Id,
            Pet__c = pet.Id,
            PetOwners__c = owner.Id,
            Date__c = Date.today().addDays(1),
            Time__c = Time.newInstance(9, 0, 0, 0)
        );

        Test.startTest();
        insert appt;
        Test.stopTest();

        Appointment__c inserted = [SELECT Id FROM Appointment__c WHERE Id = :appt.Id];
        System.assertNotEquals(null, inserted.Id, 'Agendamento realizado com sucesso.');
    }

    //Testa o bloqueio de conflito noinsert. Garante que um segundo agendamento conflitante seja bloqueado.
    @isTest
    static void testCreateAppointmentWithConflict_ShouldFail() {
        Vet__c vet = createVet();
        Pet_Owner__c owner = createPetOwner();
        Pet__c pet1 = createPet(owner.Id);
        Pet__c pet2 = createPet(owner.Id);
        Date apptDate = Date.today().addDays(1);
        Time apptTime = Time.newInstance(10, 0, 0, 0);

        Appointment__c firstAppt = new Appointment__c(
            Vet__c = vet.Id,
            Pet__c = pet1.Id,
            PetOwners__c = owner.Id,
            Date__c = apptDate,
            Time__c = apptTime
        );
        insert firstAppt;

        Appointment__c conflictingAppt = new Appointment__c(
            Vet__c = vet.Id,
            Pet__c = pet2.Id,
            PetOwners__c = owner.Id,
            Date__c = apptDate,
            Time__c = apptTime
        );

        Test.startTest();
        Database.SaveResult result = Database.insert(conflictingAppt, false);
        Test.stopTest();

        //Mensagem de erro esperada do assert, que aparece no log de teste.
        System.assertEquals(false, result.isSuccess(), 'Conflicting appointment should not be saved.');

        System.assert(
            result.getErrors()[0].getMessage().contains('já possui um agendamento'),
            'A mensagem de erro deveria indicar conflito de agendamento com o mesmo veterinário.'
        );
    }

    /*Testa o bloqueio de conflito no update. Garante que um agendamento existente
      não possa ser movido para um horario já ocupado por outro agendamento do mesmo vet.
    */
    @isTest
    static void testUpdateAppointmentGeneratesConflict_ShouldFail() {
        Vet__c vet = createVet();
        Pet_Owner__c owner = createPetOwner();
        Pet__c pet1 = createPet(owner.Id);
        Pet__c pet2 = createPet(owner.Id);
        Date apptDate = Date.today().addDays(2);

        Appointment__c apptA = new Appointment__c(
            Vet__c = vet.Id,
            Pet__c = pet1.Id,
            PetOwners__c = owner.Id,
            Date__c = apptDate,
            Time__c = Time.newInstance(9, 0, 0, 0)
        );
        Appointment__c apptB = new Appointment__c(
            Vet__c = vet.Id,
            Pet__c = pet2.Id,
            PetOwners__c = owner.Id,
            Date__c = apptDate,
            Time__c = Time.newInstance(11, 0, 0, 0)
        );
        insert new List<Appointment__c>{ apptA, apptB };

        // Tenta agendar o compromisso B para o mesmo horário do compromisso A.
        apptB.Time__c = Time.newInstance(9, 0, 0, 0);

        Test.startTest();
        Database.SaveResult result = Database.update(apptB, false);
        Test.stopTest();

        System.assertEquals(false, result.isSuccess(), 'Update that creates a conflict should be blocked.');

        System.assert(
            result.getErrors()[0].getMessage().contains('já possui um agendamento'),
            'O bloqueio deveria ocorrer pelo motivo correto: conflito de agenda.'
        );
    }

    /*Testa um update em campo NÃO monitorado (fora de Vet/Date/Time)
      não dispara a validação de conflito nem é bloqueado indevidamente.
    */
    @isTest
    static void testUpdateUnrelatedFieldDoesNotTriggerValidation_ShouldSucceed() {
        Vet__c vet = createVet();
        Pet_Owner__c owner = createPetOwner();
        Pet__c pet = createPet(owner.Id);

        Appointment__c appt = new Appointment__c(
            Vet__c = vet.Id,
            Pet__c = pet.Id,
            PetOwners__c = owner.Id,
            Date__c = Date.today().addDays(1),
            Time__c = Time.newInstance(9, 0, 0, 0)
        );
        insert appt;

        // Ajuste 'Notes' para um campo real do seu objeto que não seja
        // Vet, Date ou Time.
        appt.Notes__c = 'Trazer exames anteriores';

        Test.startTest();
        Database.SaveResult result = Database.update(appt, false);
        Test.stopTest();

        System.assertEquals(
            true,
            result.isSuccess(),
            'Update em campo não relevante (fora de Vet/Date/Time) não deve ser bloqueado.'
        );
    }

    /*Testa registros com campos nulos (Vet, Date ou Time) são
      ignorados pela validação, sem lançar exceção nem bloquear indevidamente.
    */
    @isTest
    static void testAppointmentWithNullRelevantFields_ShouldNotBeValidated() {
        Vet__c vet = createVet();
        Pet_Owner__c owner = createPetOwner();
        Pet__c pet = createPet(owner.Id);

        /* Ajusta os campos abaixo caso Vet, Date ou Time sejam
           obrigatórios (required) no seu objeto; nesse caso, testa apenas
           os campos que podem ficar nulos.
        */
        Appointment__c apptWithoutTime = new Appointment__c(
            Vet__c = vet.Id,
            Pet__c = pet.Id,
            PetOwners__c = owner.Id,
            Date__c = Date.today().addDays(1),
            Time__c = null
        );

        Test.startTest();
        Database.SaveResult result = Database.insert(apptWithoutTime, false);
        Test.stopTest();

        System.assertEquals(
            true,
            result.isSuccess(),
            'Registro com campo relevante nulo deve ser ignorado pela validação de conflito, não bloqueado por ela.'
        );
    }

    /*Testa bulkification/governor limits, não a regra de conflito em si.
      Garante que a trigger não estoura limites de SOQL/DML quando processa
      um batch no tamanho máximo permitido por operação DML (200 registros).
    */
    @isTest
    static void testBulkInsertTwoHundredAppointments_ShouldSucceed() {
        Vet__c vet = createVet();
        Pet_Owner__c owner = createPetOwner();
        List<Appointment__c> bulkAppointments = new List<Appointment__c>();
        List<Pet__c> pets = new List<Pet__c>();

        for (Integer i = 0; i < 200; i++) {
            pets.add(new Pet__c(Name = 'Pet ' + i, PetOwners__c = owner.Id));
        }
        insert pets;

        for (Integer i = 0; i < 200; i++) {
            bulkAppointments.add(new Appointment__c(
                Vet__c = vet.Id,
                Pet__c = pets[i].Id,
                PetOwners__c = owner.Id,
                Date__c = Date.today().addDays(i + 1), // Uma data diferente por vez -> sem conflitos
                Time__c = Time.newInstance(9, 0, 0, 0)
            ));
        }

        Test.startTest();
        insert bulkAppointments;
        Test.stopTest();

        List<Appointment__c> inserted = [SELECT Id FROM Appointment__c WHERE Vet__c = :vet.Id];
        System.assertEquals(200, inserted.size(), 'All 200 non-conflicting appointments should be inserted.');
    }

    /*Testa o conflito entre dois registros novos, dentro do mesmo batch,
      garante que a validação também funciona dentro do mesmo batch de insert.
    */
    @isTest
    static void testInsertTwoConflictingRecordsInSameBatch_ShouldFailForSecond() {
        Vet__c vet = createVet();
        Pet_Owner__c owner = createPetOwner();
        Pet__c pet1 = createPet(owner.Id);
        Pet__c pet2 = createPet(owner.Id);
        Date apptDate = Date.today().addDays(3);
        Time apptTime = Time.newInstance(14, 0, 0, 0);

        Appointment__c apptA = new Appointment__c(
            Vet__c = vet.Id,
            Pet__c = pet1.Id,
            PetOwners__c = owner.Id,
            Date__c = apptDate,
            Time__c = apptTime
        );
        Appointment__c apptB = new Appointment__c(
            Vet__c = vet.Id,
            Pet__c = pet2.Id,
            PetOwners__c = owner.Id,
            Date__c = apptDate,
            Time__c = apptTime
        );

        Test.startTest();
        List<Database.SaveResult> results = Database.insert(
            new List<Appointment__c>{ apptA, apptB },
            false
        );
        Test.stopTest();

        System.assertEquals(true, results[0].isSuccess(), 'O primeiro registro do batch deveria ser salvo normalmente.');
        System.assertEquals(false, results[1].isSuccess(), 'O segundo registro do batch deveria ser bloqueado por conflito com o primeiro.');

        System.assert(
            results[1].getErrors()[0].getMessage().contains('mesmo envio (batch)'),
            'A mensagem de erro deveria indicar conflito dentro do mesmo batch.'
        );

        List<Appointment__c> inserted = [
            SELECT Id FROM Appointment__c
            WHERE Vet__c = :vet.Id AND Date__c = :apptDate AND Time__c = :apptTime
        ];
        System.assertEquals(1, inserted.size(), 'Apenas um dos dois registros conflitantes deveria ter sido persistido.');
    }
}
