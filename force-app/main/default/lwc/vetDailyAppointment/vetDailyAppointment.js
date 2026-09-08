import { LightningElement, wire, track } from 'lwc';
import { refreshApex } from '@salesforce/apex';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';

import APPOINTMENT_OBJECT from '@salesforce/schema/Appointment__c';
import DATE_FIELD from '@salesforce/schema/Appointment__c.Date__c';
import TIME_FIELD from '@salesforce/schema/Appointment__c.Time__c';
import SERVICE_FIELD from '@salesforce/schema/Appointment__c.Service_Type__c';
import STATUS_FIELD from '@salesforce/schema/Appointment__c.Status__c';
import VET_FIELD from '@salesforce/schema/Appointment__c.Vet__c';
import OWNER_FIELD from '@salesforce/schema/Appointment__c.PetOwners__c';
import PET_FIELD from '@salesforce/schema/Appointment__c.Pet__c';
import SPECIES_FIELD from '@salesforce/schema/Appointment__c.Species__c';

import getDailyAppointments from '@salesforce/apex/VetAppointmentController.getDailyAppointments';

const COLUMNS = [
    { label: 'Hora', fieldName: 'TimeFormatted', type: 'text', initialWidth: 100 },
    { label: 'Pet', fieldName: 'PetName', type: 'text' },
    { label: 'Espécie', fieldName: 'Species', type: 'text' }, 
    { label: 'Tutor', fieldName: 'OwnerName', type: 'text' },
    { label: 'Veterinária(o)', fieldName: 'VetName', type: 'text' },
    { label: 'Tipo', fieldName: 'ServiceType', type: 'text' },     
    { label: 'Status', fieldName: 'Status', type: 'text' }      
];

export default class VetDailyAppointment extends LightningElement {
    columns = COLUMNS;
    @track appointments = [];
    @track isModalOpen = false;
    wiredAppointmentsResult;

    objectApiName = APPOINTMENT_OBJECT;
    fields = [DATE_FIELD, TIME_FIELD, PET_FIELD, SPECIES_FIELD, OWNER_FIELD, VET_FIELD, SERVICE_FIELD, STATUS_FIELD];

    @wire(getDailyAppointments)
    wiredAppointments(result) {
        this.wiredAppointmentsResult = result;
        if (result.data) {
            // Já vem "achatado" e com TimeFormatted como string — nada de objeto Time cru
            this.appointments = result.data;
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