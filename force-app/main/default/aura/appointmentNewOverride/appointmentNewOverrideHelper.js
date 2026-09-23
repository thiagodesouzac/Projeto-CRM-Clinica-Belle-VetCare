({
    goToList: function () {
        var navEvt = $A.get('e.force:navigateToObjectHome');
        navEvt.setParams({ scope: 'Appointment__c' });
        navEvt.fire();
    }
});