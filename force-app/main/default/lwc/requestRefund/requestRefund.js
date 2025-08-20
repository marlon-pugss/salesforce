import { LightningElement, api, wire }           from 'lwc';
import { CloseActionScreenEvent }                from 'lightning/actions';
import { CurrentPageReference, NavigationMixin } from 'lightning/navigation';
import ComponentNotifiers                        from 'c/componentNotifiers';
//import getRefundReasons                        from '@salesforce/apex/RequestRefundTransaction.getRefundReasons';
import save                                      from '@salesforce/apex/RequestRefundTransaction.save';
import GenericAdminError                         from '@salesforce/label/c.GenericAdminError';

export default class requestRefund extends NavigationMixin(LightningElement) {
    @api recordId;
    isLoading       = false;
    refundReason    = '';
    refundSubReason = '';
    errorMessage;

    label = { GenericAdminError };

    @wire(CurrentPageReference)
    getStateParameters(currentPageReference) {
        if (currentPageReference)
            this.recordId = currentPageReference.state.recordId;
    }

    connectedCallback() {}

    get refundReasonOptions() {
        return [
            { label: 'FRAUDE',            value: 'FRAUD' },
            { label: 'PEDIDO DO CLIENTE', value: 'CUSTOMER REQUEST' },
            { label: 'RETORNO',           value: 'RETURN' },
            { label: 'DUPLICATA',         value: 'DUPLICATE' },
            { label: 'OUTRO',             value: 'OTHER' },
        ];

        /*getRefundReasons()
        .then(result => {
            console.log('result: ', result);
            console.log('_____________________');

            for (let record of result)
                this.refundReasonOptionss.push( { label: record.label, value: record.value } )
        })

        console.log('refundReasonOptionss: ', this.refundReasonOptionss);
        return this.refundReasonOptionss;*/
    }

    get refundSubReasonOptions() {
        return [
            { label: 'DESACORDCO COMERCIAL', value: 'COMMERCIAL DISAGREEMENT' },
            { label: 'COMPROU CURSO ERRADO', value: 'BOUGHT WRONG COURSE' },
        ];
    }

    refundReasonChange(event) {
        this.refundReason = event.detail.value;
    }

    refundSubReasonChange(event) {
        this.refundSubReason = event.detail.value;
    }

    async save() {
        try {
            this.isLoading = true;

            if (this.refundReason == '' || this.refundReason == null || this.refundSubReason == '' || this.refundSubReason == null ){
                ComponentNotifiers.showToast(this, "warning", "Favor preencher motivo e submotivo de reembolso", undefined, 'dismissible', 1000);
                return;
            }
                
            const resultRefund = await save({ transactionId: this.recordId, refundReason: this.refundReason, refundSubReason: this.refundSubReason });
            if (resultRefund !== 'Success') {
                ComponentNotifiers.showToast(this, "error", resultRefund, undefined, 'dismissible', 1000);
                return;
            }

            ComponentNotifiers.showToast(this, "success", "Reembolso solicitado com sucesso!", undefined, 'dismissible', 2000);
        }
        catch (error) {
            console.error('Erro no método save:', error);
            this.handleError(error);
        } 
        finally {
            this.isLoading = false;
            this.dispatchEvent(new CustomEvent('close'));
            this.dispatchEvent(new CloseActionScreenEvent());
            eval("$A.get('e.force:refreshView').fire();");
        }
    }

    /*render(){ //this method runs everytime the page is rendered
        return firstPage;
    }*/

    handleError(error) {
        this.isLoading = false;

        this.errorMessage = error.body.message.includes('Attempt to') ? this.label.GenericAdminError : error.body.message;

        console.log('error message: ', error.body.message);
        console.log('error stackTrace: ', error.body.stackTrace);
        ComponentNotifiers.showToast(this, "error", this.errorMessage, undefined, 'dismissible', 1000);
        this.handleClose();
    }

    handleClose() {
        this.dispatchEvent(new CustomEvent('close'));
        this.dispatchEvent(new CloseActionScreenEvent());
    }
    
}