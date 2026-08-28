import { LightningElement, wire, track } from 'lwc';
import { refreshApex } from '@salesforce/apex';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';

// Referências de Schema (Garante integridade física dos campos)
import APPOINTMENT_OBJECT from '@salesforce/schema/Appointment__c';
import DATE_FIELD from '@salesforce/schema/Appointment__c.Date__c';
import TIME_FIELD from '@salesforce/schema/Appointment__c.Time__c';
import SERVICE_FIELD from '@salesforce/schema/Appointment__c.Service_Type__c';
import STATUS_FIELD from '@salesforce/schema/Appointment__c.Status__c';
import VET_FIELD from '@salesforce/schema/Appointment__c.Vet__c';
import OWNER_FIELD from '@salesforce/schema/Appointment__c.Pet_Owner__c';
import PET_FIELD from '@salesforce/schema/Appointment__c.Pet__c';
import SPECIES_FIELD from '@salesforce/schema/Appointment__c.Species__c';

import getDailyAppointments from '@salesforce/apex/VetAppointmentController.getDailyAppointments';

const COLUMNS = [
    { label: 'Hora', fieldName: 'Time__c', type: 'text', initialWidth: 100 },
    { label: 'Pet', fieldName: 'PetName', type: 'text' },
    { label: 'Espécie', fieldName: 'Species__c', type: 'text' },
    { label: 'Tutor', fieldName: 'OwnerName', type: 'text' },
    { label: 'Veterinária(o)', fieldName: 'VetName', type: 'text' },
    { label: 'Tipo', fieldName: 'Service_Type__c', type: 'text' },
    { label: 'Status', fieldName: 'Status__c', type: 'text' }
];

export default class VetDailyAppointments extends LightningElement {
    columns = COLUMNS;
    @track appointments = [];
    @track isModalOpen = false;
    wiredAppointmentsResult;

    // Propriedades expostas para o Form nativo
    objectApiName = APPOINTMENT_OBJECT;
    fields = [DATE_FIELD, TIME_FIELD, PET_FIELD, SPECIES_FIELD, OWNER_FIELD, VET_FIELD, SERVICE_FIELD, STATUS_FIELD];

    @wire(getDailyAppointments)
    wiredAppointments(result) {
        this.wiredAppointmentsResult = result;
        if (result.data) {
            // Flattening: Transforma caminhos relacionais (Ex: Vet__r.Name) em propriedades diretas para o datatable
            this.appointments = result.data.map(record => {
                return {
                    ...record,
                    VetName: record.Vet__r ? record.Vet__r.Name : '',
                    OwnerName: record.Pet_Owner__r ? record.Pet_Owner__r.Name : '',
                    PetName: record.Pet__r ? record.Pet__r.Name : ''
                };
            });
        } else if (result.error) {
            this.showToast('Erro', 'Não foi possível atualizar a lista.', 'error');
        }
    }

    openModal() {
        this.isModalOpen = true;
    }

    closeModal() {
        this.isModalOpen = false;
    }

    handleSuccess() {
        this.showToast('Sucesso', 'Consulta agendada com sucesso!', 'success');
        this.closeModal();
        return refreshApex(this.wiredAppointmentsResult);
    }

    showToast(title, message, variant) {
        this.dispatchEvent(new ShowToastEvent({ title, message, variant }));
    }
}
