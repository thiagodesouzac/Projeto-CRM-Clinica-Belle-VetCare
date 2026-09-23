({
    doInit: function (component, event, helper) {
        $A.createComponent(
            'c:appointmentFormModalBody',
            {},
            function (modalBody, status) {
                if (status === 'SUCCESS') {
                    component.find('overlayLib').showCustomModal({
                        header: 'New Appointment',
                        body: modalBody,
                        showCloseButton: true,
                        cssClass: 'slds-modal_medium',
                        closeCallback: function () {
                            helper.goToList();
                        }
                    }).then(function (overlay) {
                        component.set('v.overlayRef', overlay);
                    });
                } else if (status === 'ERROR') {
                    // eslint-disable-next-line no-console
                    console.error('Error creating component: ' + JSON.stringify(status));
                }
            }
        );
    },

    handleModalClose: function (component, event, helper) {
        var overlayRef = component.get('v.overlayRef');
        if (overlayRef) {
            overlayRef.close();
        }
        helper.goToList();
    }
});