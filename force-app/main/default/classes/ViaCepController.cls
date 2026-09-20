/**
 * Consulta de endereço na API pública ViaCEP (https://viacep.com.br).
 *
 * Usada pelo LWC appointmentCepLookup para preencher automaticamente
 * Street, Neighborhood, City e State do Appointment a partir do CEP digitado.
 *
 * Requisitos:
 *  - Remote Site Setting "ViaCEP" ativo (https://viacep.com.br)
 *  - Acesso à classe para o perfil / permission set do usuário
 */
public with sharing class ViaCepController {

    private static final String VIACEP_BASE_URL = 'https://viacep.com.br/ws/';
    private static final Integer TIMEOUT_MS = 10000;
    private static final Integer ZIP_CODE_LENGTH = 8;

    /**
     * Estrutura devolvida ao LWC.
     */
    public class AddressDTO {
        @AuraEnabled public String zipCode;
        @AuraEnabled public String street;
        @AuraEnabled public String neighborhood;
        @AuraEnabled public String city;
        @AuraEnabled public String state;
    }

    /**
     * Busca o endereço correspondente ao CEP informado.
     *
     * @param zipCode CEP com ou sem máscara (ex.: 01001-000 ou 01001000)
     * @return AddressDTO com zipCode, street, neighborhood, city e state
     * @throws AuraHandledException quando o CEP é inválido, não existe ou o serviço falha
     */
    @AuraEnabled
    public static AddressDTO findAddress(String zipCode) {
        String cleanZipCode = sanitizeZipCode(zipCode);

        if (String.isBlank(cleanZipCode) || cleanZipCode.length() != ZIP_CODE_LENGTH) {
            throw buildError('Invalid ZIP code. Enter the 8 digits of the ZIP code.');
        }

        HttpResponse response = executeCallout(cleanZipCode);

        if (response.getStatusCode() == 400) {
            throw buildError('ZIP code has an invalid format. Check the digits you entered.');
        }
        if (response.getStatusCode() != 200) {
            throw buildError(
                'ZIP code lookup service is unavailable right now (HTTP ' +
                response.getStatusCode() + '). Fill in the address manually or try again.'
            );
        }

        // Atenção: a variável NÃO pode se chamar "json", senão esconde a classe JSON.
        Map<String, Object> payload;
        try {
            payload = (Map<String, Object>) JSON.deserializeUntyped(response.getBody());
        } catch (Exception e) {
            throw buildError('Unexpected response from the ZIP code service. Try again.');
        }

        // O ViaCEP responde 200 com {"erro": true} (ou "true") quando o CEP não existe.
        if ('true'.equalsIgnoreCase(String.valueOf(payload.get('erro')))) {
            throw buildError('ZIP code not found. Check the number or fill in the address manually.');
        }

        // As chaves entre aspas (cep, logradouro, bairro, localidade, uf) são as do JSON do ViaCEP.
        AddressDTO address = new AddressDTO();
        address.zipCode = readText(payload, 'cep');
        address.street = readText(payload, 'logradouro');
        address.neighborhood = readText(payload, 'bairro');
        address.city = readText(payload, 'localidade');
        address.state = readText(payload, 'uf');
        return address;
    }

    // ------------------------------------------------------------------
    // Auxiliares
    // ------------------------------------------------------------------

    private static HttpResponse executeCallout(String cleanZipCode) {
        try {
            HttpRequest request = new HttpRequest();
            request.setEndpoint(VIACEP_BASE_URL + cleanZipCode + '/json/');
            request.setMethod('GET');
            request.setHeader('Accept', 'application/json');
            request.setTimeout(TIMEOUT_MS);
            return new Http().send(request);
        } catch (Exception e) {
            throw buildError(
                'Could not look up the ZIP code right now. Try again in a moment. (' +
                e.getMessage() + ')'
            );
        }
    }

    private static String sanitizeZipCode(String zipCode) {
        if (zipCode == null) {
            return null;
        }
        return zipCode.replaceAll('[^0-9]', '');
    }

    private static String readText(Map<String, Object> payload, String key) {
        Object rawValue = payload.get(key);
        return rawValue == null ? null : String.valueOf(rawValue);
    }

    /**
     * AuraHandledException só expõe a mensagem ao LWC/testes se setMessage for chamado.
     */
    private static AuraHandledException buildError(String message) {
        AuraHandledException error = new AuraHandledException(message);
        error.setMessage(message);
        return error;
    }
}
