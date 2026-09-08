public with sharing class VetAppointmentController {

    public class DailyAppointmentItem {
        @AuraEnabled public Id Id;
        @AuraEnabled public String Name;
        @AuraEnabled public Date AppointmentDate;
        @AuraEnabled public String TimeFormatted;
        @AuraEnabled public String ServiceType;
        @AuraEnabled public String Status;
        @AuraEnabled public String Species;
        @AuraEnabled public String VetName;
        @AuraEnabled public String OwnerName;
        @AuraEnabled public String PetName;
    }

    @AuraEnabled(cacheable=true)
    public static List<DailyAppointmentItem> getDailyAppointments() {
        try {
            List<Appointment__c> appointments = [
                SELECT Id, Name, Date__c, Time__c, Service_Type__c, Status__c, Species__c,
                       Vet__r.Name, PetOwners__r.Name, Pet__r.Name
                FROM Appointment__c
                WHERE Date__c = TODAY
                WITH USER_MODE
                ORDER BY Time__c ASC
            ];

            List<DailyAppointmentItem> result = new List<DailyAppointmentItem>();
            for (Appointment__c appt : appointments) {
                DailyAppointmentItem item = new DailyAppointmentItem();
                item.Id = appt.Id;
                item.Name = appt.Name;
                item.AppointmentDate = appt.Date__c;
                item.TimeFormatted = formatTime(appt.Time__c);
                item.ServiceType = appt.Service_Type__c;
                item.Status = appt.Status__c;
                item.Species = appt.Species__c;
                item.VetName = appt.Vet__r != null ? appt.Vet__r.Name : '';
                item.OwnerName = appt.PetOwners__r != null ? appt.PetOwners__r.Name : '';
                item.PetName = appt.Pet__r != null ? appt.Pet__r.Name : '';
                result.add(item);
            }
            return result;
        } catch (Exception e) {
            throw new AuraHandledException('Erro ao carregar a agenda veterinaria: ' + e.getMessage());
        }
    }

    private static String formatTime(Time t) {
        if (t == null) {
            return '';
        }
        String hh = String.valueOf(t.hour()).leftPad(2, '0');
        String mm = String.valueOf(t.minute()).leftPad(2, '0');
        return hh + ':' + mm;
    }
}