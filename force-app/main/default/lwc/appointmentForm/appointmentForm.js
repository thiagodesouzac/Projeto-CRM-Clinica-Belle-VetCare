import { LightningElement, api, wire } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { getRecord } from 'lightning/uiRecordApi';
import getAddressByZipCode from '@salesforce/apex/AppointmentCEPService.getAddressByZipCode';

import STREET_FIELD from '@salesforce/schema/Appointment__c.Street__c';
import NEIGHBORHOOD_FIELD from '@salesforce/schema/Appointment__c.Neighborhood__c';
import CITY_FIELD from '@salesforce/schema/Appointment__c.City__c';
import STATE_FIELD from '@salesforce/schema/Appointment__c.State__c';

const ADDRESS_FIELDS = [
    STREET_FIELD,
    NEIGHBORHOOD_FIELD,
    CITY_FIELD,
    STATE_FIELD
];

/**
 * appointmentForm
 * ----------------
 * Formulário "Novo Agendamento" (Modal/ScreenAction) e também
 * usado na Record Page do Appointment__c para visualizar/editar um registro existente.
 * 
 * FUNCIONAMENTO:
 * - Sem recordId (ex: aberto via modal "Novo Agendamento"): cria um novo registro.
 * - Com recordId (ex: colocado na Record Page do Appointment__c): carrega o registro
 *   existente, incluindo os campos de endereço, para edição.
 * - Ao digitar o CEP, busca o endereço automaticamente via AppointmentCEPService (ViaCEP API).
 * - Os campos de endereço usam <lightning-input> simples para permitir preenchimento
 *   programático (tanto pelo ViaCEP quanto pelo registro existente).
 */
export default class AppointmentForm extends LightningElement {
    _recordId;

    @api
    get recordId() {
        return this._recordId;
    }

    set recordId(value) {
        this._recordId = value;

        // Sempre que recordId muda (inclusive para vazio, ao criar um novo agendamento),
        // limpa os campos de endereço para não arrastar dados do registro anterior.
        if (!this.safeRecordId) {
            this.resetAddressFields();
        }
    }

    street = '';
    neighborhood = '';
    city = '';
    state = '';

    isLookingUpAddress = false;
    zipCodeError = '';

    // Carrega os valores de endereço já salvos quando existe um recordId (modo edição/visualização)
    @wire(getRecord, { recordId: '$safeRecordId', fields: ADDRESS_FIELDS })
    wiredAppointment({ data, error }) {
        if (data) {
            this.street = data.fields.Street__c.value || '';
            this.neighborhood = data.fields.Neighborhood__c.value || '';
            this.city = data.fields.City__c.value || '';
            this.state = data.fields.State__c.value || '';
        } else if (error) {
            // eslint-disable-next-line no-console
            console.error('Erro ao carregar endereço do agendamento', error);
        }
    }

    // Normaliza o recordId: alguns contextos (como o ScreenAction "New" disparado
    // pela lista de Appointments) injetam uma string vazia em vez de undefined/null.
    // Sem esse tratamento, o form entra em modo de edição de um registro inexistente
    // e os campos preenchidos não são persistidos corretamente.
    get safeRecordId() {
        return this._recordId ? this._recordId : undefined;
    }

    get isEditMode() {
        return this.safeRecordId !== undefined;
    }

    resetAddressFields() {
        this.street = '';
        this.neighborhood = '';
        this.city = '';
        this.state = '';
        this.zipCodeError = '';
    }

    handleZipCodeChange(event) {
        const zipCode = event.detail.value;
        const digitsOnly = (zipCode || '').replace(/\D/g, '');
        this.zipCodeError = '';

        // Only trigger the lookup once the ZIP code is complete (8 digits)
        if (digitsOnly.length !== 8) {
            return;
        }

        this.isLookingUpAddress = true;

        getAddressByZipCode({ zipCode })
            .then((result) => {
                this.street = result.logradouro || '';
                this.neighborhood = result.bairro || '';
                this.city = result.localidade || '';
                this.state = result.uf || '';
            })
            .catch((error) => {
                this.zipCodeError =
                    (error && error.body && error.body.message) ||
                    'Error looking up the ZIP code entered.';
            })
            .finally(() => {
                this.isLookingUpAddress = false;
            });
    }

    handleStreetChange(event) {
        this.street = event.target.value;
    }

    handleNeighborhoodChange(event) {
        this.neighborhood = event.target.value;
    }

    handleCityChange(event) {
        this.city = event.target.value;
    }

    handleStateChange(event) {
        this.state = event.target.value;
    }

    handleSubmit(event) {
        event.preventDefault();

        const fields = {
            ...event.detail.fields,
            Street__c: this.street,
            Neighborhood__c: this.neighborhood,
            City__c: this.city,
            State__c: this.state
        };

        this.template.querySelector('lightning-record-edit-form').submit(fields);
    }

    handleSuccess() {
        this.dispatchEvent(
            new ShowToastEvent({
                title: 'Appointment saved',
                message: 'The appointment was saved successfully.',
                variant: 'success'
            })
        );

        // Só limpa e fecha o modal quando é criação (sem recordId).
        // Em modo edição na Record Page, mantém o formulário mostrando os dados salvos.
        if (!this.isEditMode) {
            this.resetAddressFields();
            this.dispatchEvent(new CustomEvent('close'));
        }
    }

    handleCancel() {
        this.dispatchEvent(new CustomEvent('close'));
    }

    handleError(event) {
        this.dispatchEvent(
            new ShowToastEvent({
                title: 'Error saving appointment',
                message:
                    event?.detail?.message ||
                    'Please check the highlighted fields and try again.',
                variant: 'error'
            })
        );
    }
}
