({
    doInit: function (component, event, helper) {
        var recordId = component.get("v.recordId");
        var action = component.get("c.getOpportunityId");
        action.setParams({ messagingSessionId: recordId });

        action.setCallback(this, function (response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                var opportunityId = response.getReturnValue();
                component.set("v.opportunityId", opportunityId);
            } else {
                console.error("Error fetching OpportunityId: " + response.getError());
            }
        });
        $A.enqueueAction(action);
    },
    
    handleSelect: function (component, event, helper) {
        var selectedStage = event.getParam("detail").value;
        component.set("v.selectedStage", selectedStage);

        // Verifica se a fase é "Fechado/Perdido"
        if (selectedStage === "Fechado/Perdido") {
            var closingReason = component.get("v.closingReason");

            if (!closingReason || closingReason.trim() === "") {
                var toastEvent = $A.get("e.force:showToast");
                toastEvent.setParams({
                    "title": "Erro",
                    "message": "Não é possível escolher fechar a oportunidade. Escolha um motivo de fechamento ao lado",
                    "type": "error",
                    "mode": "sticky"
                });
                toastEvent.fire();
                component.set("v.selectedStage", null); // Reverte a seleção
                return; 
            }
        } else {
            // Limpa o motivo se a fase não for "Fechado/Perdido"
            component.set("v.closingReason", "");
        }

        // Chama o método Apex para atualizar a fase da oportunidade
        var action = component.get("c.updateStage");
        action.setParams({
            stageName: selectedStage,
            recordId: component.get("v.opportunityId"),
            closingReason: component.get("v.closingReason")
        });

        action.setCallback(this, function (response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                var toastEvent = $A.get("e.force:showToast");
                toastEvent.setParams({
                    "title": "Sucesso!",
                    "message": "A fase foi atualizada com sucesso.",
                    "type": "success",
                    "mode": "dismissible"
                });
                toastEvent.fire();
                $A.get('e.force:refreshView').fire(); // Atualiza a visualização
            } else {
                var errors = response.getError();
                if (errors && errors[0] && errors[0].message) {
                    console.error(errors[0].message);
                }
            }
        });
        $A.enqueueAction(action);
    }
})