import { LightningElement, api, wire } from 'lwc';
import { CloseActionScreenEvent } from 'lightning/actions';
import { CurrentPageReference } from 'lightning/navigation';
import { NavigationMixin } from 'lightning/navigation';
import ComponentNotifiers from 'c/componentNotifiers';
import getOpportunity from '@salesforce/apex/ConcludeSaleController.getOpportunity';
import concludeSale from '@salesforce/apex/ConcludeSaleController.concludeSale';

import GenericAdminError from '@salesforce/label/c.GenericAdminError';

export default class ConcludeSale extends NavigationMixin(LightningElement) {
    @api recordId;
    isLoading = false;
    errorMessage;
    contract;
    opportunity;
    opportunityLineItems;
    opportunityContactRoles;

    label = {
        GenericAdminError
    };

    @wire(CurrentPageReference)
    getStateParameters(currentPageReference) {
        if (currentPageReference)
            this.recordId = currentPageReference.state.recordId;
    }

    connectedCallback() {
        getOpportunity({opportunityId: this.recordId})
        .then(result => {
            this.opportunity = result;
            this.opportunityLineItems = result.OpportunityLineItems;
            this.opportunityContactRoles = result.OpportunityContactRoles;
        })
        .catch(error => {
            console.log('catch lwc getOpportunity error:');
            this.handleError(error);
        });
    }

    async handleConcludeSale(){
        this.isLoading = true;
        
        await concludeSale({opp: this.opportunity, lineItems: this.opportunityLineItems, oppContacts: this.opportunityContactRoles})
        .then(result => {
            this.contract = result;
        })
        .catch(error => {
            console.log('catch lwc concludeSale error:');
            this.handleError(error);
        });

        this.isLoading = false;
        this[NavigationMixin.Navigate]({
            type: 'standard__recordPage',
            attributes: {
                recordId: this.contract.Id,
                objectApiName: 'Contract',
                actionName: 'view'
            }
        });
    }
    
    handleError(error) {
        this.isLoading = false;

        this.errorMessage = error.body.message.includes('Attempt to') ? this.label.GenericAdminError : error.body.message;

        console.log('error message: ' + error.body.message);
        console.log('error stackTrace: ' + error.body.stackTrace);
        ComponentNotifiers.showToast(this, "error", this.errorMessage, undefined, 'dismissible', 1000);
        this.handleClose();
    }

    handleClose() {
        this.dispatchEvent(new CustomEvent('close'));
        this.dispatchEvent(new CloseActionScreenEvent());
    }
    
}