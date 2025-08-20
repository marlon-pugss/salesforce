import { LightningElement, track, api, wire } from 'lwc';
import { CloseActionScreenEvent } from 'lightning/actions';
import { CurrentPageReference, NavigationMixin } from 'lightning/navigation';
import ComponentNotifiers from 'c/componentNotifiers';
import firstPage from './recycleLeadOpp.html';
import secondPage from './selectedRecords.html';
import getValuesFromMetadata from '@salesforce/apex/RecycleLeadOpps.getValuesFromMetadata';
import getLeadSources from '@salesforce/apex/RecycleLeadOpps.getLeadSources';
import getLeads from '@salesforce/apex/RecycleLeadOpps.getLeads';
import getOpportunities from '@salesforce/apex/RecycleLeadOpps.getOpportunities';
import getMaximumRecordsToRecycle from '@salesforce/apex/RecycleLeadOpps.getMaximumRecordsToRecycle';
import sendLeadsToRecycle from '@salesforce/apex/RecycleLeadOpps.sendLeadsToRecycle';
import sendOpportunitiesToRecycle from '@salesforce/apex/RecycleLeadOpps.sendOpportunitiesToRecycle';
import GenericAdminError from '@salesforce/label/c.GenericAdminError';

export default class RecycleLeadOpp extends NavigationMixin(LightningElement) {

    @api totalNumberOfRows;
    @track brandOptionsLoaded      = false;
    @track verticalOptionsLoaded   = false;
    @track leadSourceOptionsLoaded = false;
    brandOptions      = [];
    verticalOptions   = [];
    leadSourceOptions = [];
    @track objectValue          = null;
    @track startDateValue       = null;
    @track endDateValue         = null;
    @track brandValue           = null;
    @track verticalValue        = null;
    @track leadSourceValue      = null;
    @track recycleQuantityValue = null;
    maximumRecordsToRecycle;
    isLoading     = false;
    recycled      = false;
    pageNumber = 'page1';
    selectedRecords;
    loadMoreStatus;
    recordsLength;
    errorMessage;

    selectedRecordsColumns = [
        { label: 'Nome Completo', fieldName: 'Name', type: 'text', hideDefaultActions: true },
        { label: 'Lead Source', fieldName: 'LeadSource', type: 'text', hideDefaultActions: true },
        { label: 'Brand', fieldName: 'Brand__c', type: 'text', hideDefaultActions: true },
        { label: 'Vertical', fieldName: 'Vertical__c', type: 'text', hideDefaultActions: true },
        { label: 'Quantidade de Reciclagens', fieldName: 'RecycleQuantity__c', type: 'number', hideDefaultActions: true },
        { label: 'Data de Criação', fieldName: 'CreatedDate', type: 'date', hideDefaultActions: true }
    ];

    label = { GenericAdminError };

    connectedCallback() {
        getValuesFromMetadata({field: 'Brand'})
        .then(result => {
            for (var i = 0; i < result.length; i++)
                this.brandOptions.push( { label: result[i], value: result[i] } );
            
            this.brandOptionsLoaded = true;
            this.brandValue         = 'Fluency';
        })
        .catch(error => {
            console.log('catch lwc getValuesFromMetadata(Brand) error:', error);
            this.handleError(error);
        });

        getValuesFromMetadata({field: 'Vertical'})
        .then(result => {
            for (var i = 0; i < result.length; i++) 
                this.verticalOptions.push( { label: result[i], value: result[i] } );
            
            this.verticalOptionsLoaded = true;
        })
        .catch(error => {
            console.log('catch lwc getValuesFromMetadata(Vertical) error:');
            this.handleError(error);
        });

        getLeadSources()
        .then(result => {
            for (var i = 0; i < result.length; i++) 
                this.leadSourceOptions.push( { label: result[i], value: result[i] } );
            
            this.leadSourceOptionsLoaded = true;
        })
        .catch(error => {
            console.log('catch lwc getLeadSources error:');
            this.handleError(error);
        });

        getMaximumRecordsToRecycle()
        .then(result => {
            this.maximumRecordsToRecycle = result;
        })
        .catch(error => {
            console.log('catch lwc getMaximumRecordsToRecycle error:');
            this.handleError(error);
        });
    }

    get objectOptions(){
        return [
            { label: 'Lead', value: 'Lead' },
            { label: 'Opportunity', value: 'Opportunity' }
        ];
    }

    async changePage(){
        if(this.pageNumber === 'page1'){
            if (this.objectValue == null || this.objectValue == '' || this.objectValue == ' '){
                ComponentNotifiers.showToast(this, "error", 'Selecione um objeto para continuar!', undefined, 'dismissible', 1000);
            }
            else if (this.startDateValue == null || this.startDateValue == '' || this.startDateValue == ' '){
                ComponentNotifiers.showToast(this, "error", 'Selecione uma data inicial para continuar!', undefined, 'dismissible', 1000);
            }
            else if (this.endDateValue == null || this.endDateValue == '' || this.endDateValue == ' '){
                ComponentNotifiers.showToast(this, "error", 'Selecione uma data final para continuar!', undefined, 'dismissible', 1000);
            }
            else if (this.brandValue == null || this.brandValue == '' || this.brandValue == ' '){
                ComponentNotifiers.showToast(this, "error", 'Selecione uma brand para continuar!', undefined, 'dismissible', 1000);
            }
            else{
                this.isLoading  = true;
                this.pageNumber = 'page2';

                const leadSourcesToCheck = [];
                if (this.leadSourceValue != null && this.leadSourceValue != ''){
                    leadSourcesToCheck.push(this.leadSourceValue);
                }
                else{
                    for (var i=0; i < this.leadSourceOptions.length; i++) 
                        leadSourcesToCheck.push(this.leadSourceOptions[i].value);
                }

                if (this.objectValue == 'Opportunity'){
                    await getOpportunities({startDate: this.startDateValue, endDate: this.endDateValue, brand: this.brandValue, vertical: this.verticalValue, leadSources: leadSourcesToCheck, recycleQtt: this.recycleQuantityValue})
                    .then(result => {
                        if (result == null) 
                            ComponentNotifiers.showToast(this, "error", this.label.GenericAdminError, undefined, 'dismissible', 1000);
                        else if (result.length == 0)
                            ComponentNotifiers.showToast(this, "error", 'Consulta não encontrou registros!', undefined, 'dismissible', 1000);
                        else if (result.length > this.maximumRecordsToRecycle)
                            ComponentNotifiers.showToast(this, "error", 'Consulta retornou mais registros que o limite estabelecido: '+ this.maximumRecordsToRecycle, undefined, 'dismissible', 1000);
                        else{
                            this.selectedRecords = result;
                        }
                        this.recordsLength = result.length;
                    })
                    .catch(error => {
                        console.log('catch lwc getOpportunities error: ', error);
                        this.handleError(error);
                    });
                }
                else if (this.objectValue == 'Lead'){
                    await getLeads({startDate: this.startDateValue, endDate: this.endDateValue, brand: this.brandValue, vertical: this.verticalValue, leadSources: leadSourcesToCheck, recycleQtt: this.recycleQuantityValue})
                    .then(result => {
                        if (result == null) 
                            ComponentNotifiers.showToast(this, "error", this.label.GenericAdminError, undefined, 'dismissible', 1000);
                        else if (result.length == 0)
                            ComponentNotifiers.showToast(this, "error", 'Consulta não encontrou registros!', undefined, 'dismissible', 1000);
                        else if (result.length > this.maximumRecordsToRecycle)
                            ComponentNotifiers.showToast(this, "error", 'Consulta retornou mais registros que o limite estabelecido: '+ this.maximumRecordsToRecycle, undefined, 'dismissible', 1000);
                        else{
                            this.selectedRecords = result;
                        }
                        this.recordsLength = result.length;
                    })
                    .catch(error => {
                        console.log('catch lwc getLeads error: ', error);
                        this.handleError(error);
                    });
                }
                this.isLoading = false;
            }
        }
        else if(this.pageNumber === 'page2'){
            this.pageNumber      = 'page1';
            this.recycled        = false;
            this.selectedRecords = null;
        }

    }

    async recycle(){
        this.isLoading = true;

        if (this.objectValue == 'Opportunity'){
            await sendOpportunitiesToRecycle({opportunitiesToRecycle: this.selectedRecords})
            .then(result => {
                if (result == false) 
                    ComponentNotifiers.showToast(this, "error", this.label.GenericAdminError, undefined, 'dismissible', 1000);
            })
            .catch(error => {
                console.log('catch lwc sendOpportunitiesToRecycle error: ', error);
                this.handleError(error);
            });
        }
        else if (this.objectValue == 'Lead'){
            await sendLeadsToRecycle({leadsToRecycle: this.selectedRecords})
            .then(result => {
                if (result == false) 
                    ComponentNotifiers.showToast(this, "error", this.label.GenericAdminError, undefined, 'dismissible', 1000);
            })
            .catch(error => {
                console.log('catch lwc sendLeadsToRecycle error: ', error);
                this.handleError(error);
            });
        }

        this.recycled             = true;
        this.isLoading            = false;
        this.objectValue          = null;
        this.startDateValue       = null;
        this.endDateValue         = null;
        this.brandValue           = 'Fluency';
        this.leadSourceValue      = null;
        this.verticalValue        = null;
        this.recycleQuantityValue = null;
    }

    setObject(event){
        this.objectValue = event.target.value;
    }

    setStartDate(event){
        this.startDateValue = event.target.value;
    }

    setEndDate(event){
        this.endDateValue = event.target.value;
    }

    setBrand(event){
        this.brandValue = event.target.value;
    }

    setLeadSource(event){
        this.leadSourceValue = event.target.value;
    }

    setVertical(event){
        this.verticalValue = event.target.value;
    }

    setRecycleQuantity(event){
        this.recycleQuantityValue = event.target.value;
    }

    render(){ //this method runs everytime the page is rendered
        if(this.pageNumber === 'page1'){
            return firstPage;
        }
        else if(this.pageNumber === 'page2'){
            return secondPage;
        }
    }

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