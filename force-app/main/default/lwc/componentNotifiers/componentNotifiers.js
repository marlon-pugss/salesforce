import { LightningElement } from "lwc";
import { ShowToastEvent } from "lightning/platformShowToastEvent";
import LightningAlert from "lightning/alert";
import { CloseActionScreenEvent } from "lightning/actions";
export default class ComponentNotifiers extends LightningElement {
    static showToast(context, severity, title, message, mode, duration) {
        // Severity = info, warning, success, error
        const evt = new ShowToastEvent({
            variant: severity,
            title: title,
            message: message,
            mode: mode,
            duration: duration
        });
        context.dispatchEvent(evt);
    }

    static async showLightningAlert(severity, message, label) {
        try {
            await LightningAlert.open({
                message: message, // Exemplo: "Oportunidade já possui produtos vinculados..."
                theme: severity,  // Exemplo: "error"
                label: label,     // Exemplo: "Aviso"
            });
        } catch (error) {
            console.error("Erro ao exibir alerta:", error);
        }
    }
}