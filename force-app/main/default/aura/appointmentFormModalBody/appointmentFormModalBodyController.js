({
    handleClose: function (component, event, helper) {
        var closeEvt = $A.get("e.c:appointmentModalCloseEvent");
        closeEvt.fire();
    }
});