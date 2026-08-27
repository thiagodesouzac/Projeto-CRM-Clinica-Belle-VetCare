@isTest
private class AppointmentTriggerHandlerTest {

    /**
     * Cria um registro de Vet__c para ser usado em todos os métodos de teste.
     */
    private static Vet__c createVet() {
        Vet__c vet = new Vet__c(Name = 'Dr. Cris');
        insert vet;
        return vet;
    }

    //Testa o caminho feliz (Happy Path), garante que a validação não bloqueia agendamentos legítimos.
    @isTest
    static void testCreateAppointmentWithoutConflict_ShouldSucceed() {
        Vet__c vet = createVet();

        Appointment__c appt = new Appointment__c(
            Vet__c = vet.Id,
            Date__c = Date.today().addDays(1),
            Time__c = Time.newInstance(9, 0, 0, 0)
        );

        Test.startTest();
        insert appt;
        Test.stopTest();

        Appointment__c inserted = [SELECT Id FROM Appointment__c WHERE Id = :appt.Id];
        System.assertNotEquals(null, inserted.Id, 'Agendamento realizado com sucesso.');
    }

    //Testa o bloqueio de conflito no insert. Garante que um segundo agendamento conflitante seja bloqueado.
    @isTest
    static void testCreateAppointmentWithConflict_ShouldFail() {
        Vet__c vet = createVet();
        Date apptDate = Date.today().addDays(1);
        Time apptTime = Time.newInstance(10, 0, 0, 0);

        Appointment__c firstAppt = new Appointment__c(
            Vet__c = vet.Id,
            Date__c = apptDate,
            Time__c = apptTime
        );
        insert firstAppt;

        Appointment__c conflictingAppt = new Appointment__c(
            Vet__c = vet.Id,
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
        Date apptDate = Date.today().addDays(2);

        Appointment__c apptA = new Appointment__c(
            Vet__c = vet.Id,
            Date__c = apptDate,
            Time__c = Time.newInstance(9, 0, 0, 0)
        );
        Appointment__c apptB = new Appointment__c(
            Vet__c = vet.Id,
            Date__c = apptDate,
            Time__c = Time.newInstance(11, 0, 0, 0)
        );
        insert new List<Appointment__c>{ apptA, apptB };

        // Try to move apptB into the same slot as apptA.
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

    /*Testa que um update em campo NÃO monitorado (fora de Vet__c/Date__c/Time__c)
      não dispara a validação de conflito nem é bloqueado indevidamente.      
    */
    @isTest
    static void testUpdateUnrelatedFieldDoesNotTriggerValidation_ShouldSucceed() {
        Vet__c vet = createVet();

        Appointment__c appt = new Appointment__c(
            Vet__c = vet.Id,
            Date__c = Date.today().addDays(1),
            Time__c = Time.newInstance(9, 0, 0, 0)
        );
        insert appt;

        // Ajuste 'Notes__c' para um campo real do seu objeto que não seja
        // Vet__c, Date__c ou Time__c.
        appt.Notes__c = 'Trazer exames anteriores';

        Test.startTest();
        Database.SaveResult result = Database.update(appt, false);
        Test.stopTest();

        System.assertEquals(
            true,
            result.isSuccess(),
            'Update em campo não relevante (fora de Vet__c/Date__c/Time__c) não deve ser bloqueado.'
        );
    }

    /*Testa que registros com campos nulos (Vet__c, Date__c ou Time__c) são
      ignorados pela validação, sem lançar exceção nem bloquear indevidamente.
    */
    @isTest
    static void testAppointmentWithNullRelevantFields_ShouldNotBeValidated() {
        Vet__c vet = createVet();

        /* Ajuste os campos abaixo caso Vet__c, Date__c ou Time__c sejam
           obrigatórios (required) no seu objeto; nesse caso, testa apenas
           os campos que podem ficar nulos.
        */
        Appointment__c apptWithoutTime = new Appointment__c(
            Vet__c = vet.Id,
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
      um lote no tamanho máximo permitido por operação DML (200 registros).
    */
    @isTest
    static void testBulkInsertTwoHundredAppointments_ShouldSucceed() {
        Vet__c vet = createVet();
        List<Appointment__c> bulkAppointments = new List<Appointment__c>();

        for (Integer i = 0; i < 200; i++) {
            bulkAppointments.add(new Appointment__c(
                Vet__c = vet.Id,
                Date__c = Date.today().addDays(i + 1), // data diferente a cada vez -> sem conflitos
                Time__c = Time.newInstance(9, 0, 0, 0)
            ));
        }

        Test.startTest();
        insert bulkAppointments;
        Test.stopTest();

        List<Appointment__c> inserted = [SELECT Id FROM Appointment__c WHERE Vet__c = :vet.Id];
        System.assertEquals(200, inserted.size(), 'All 200 non-conflicting appointments should be inserted.');
    }

    /*Testa o conflito entre dois registros novos, dentro do mesmo lote,
      garante que a validação também funciona dentro do mesmo lote de insert.
    */
    @isTest
    static void testInsertTwoConflictingRecordsInSameBatch_ShouldFailForSecond() {
        Vet__c vet = createVet();
        Date apptDate = Date.today().addDays(3);
        Time apptTime = Time.newInstance(14, 0, 0, 0);

        Appointment__c apptA = new Appointment__c(
            Vet__c = vet.Id,
            Date__c = apptDate,
            Time__c = apptTime
        );
        Appointment__c apptB = new Appointment__c(
            Vet__c = vet.Id,
            Date__c = apptDate,
            Time__c = apptTime
        );

        Test.startTest();
        List<Database.SaveResult> results = Database.insert(
            new List<Appointment__c>{ apptA, apptB },
            false
        );
        Test.stopTest();

        System.assertEquals(true, results[0].isSuccess(), 'O primeiro registro do lote deveria ser salvo normalmente.');
        System.assertEquals(false, results[1].isSuccess(), 'O segundo registro do lote deveria ser bloqueado por conflito com o primeiro.');

        System.assert(
            results[1].getErrors()[0].getMessage().contains('mesmo envio (lote)'),
            'A mensagem de erro deveria indicar conflito dentro do mesmo lote.'
        );

        List<Appointment__c> inserted = [
            SELECT Id FROM Appointment__c
            WHERE Vet__c = :vet.Id AND Date__c = :apptDate AND Time__c = :apptTime
        ];
        System.assertEquals(1, inserted.size(), 'Apenas um dos dois registros conflitantes deveria ter sido persistido.');
    }
}