import { LightningElement, api, wire }           from 'lwc';
import { CloseActionScreenEvent }                from 'lightning/actions';
import { CurrentPageReference, NavigationMixin } from 'lightning/navigation';
import ComponentNotifiers                        from 'c/componentNotifiers';
import firstPage                                 from './addOffer.html';
import secondPage                                from './confirmationPage.html';
import getOffers                                 from '@salesforce/apex/AddOpportunityOffer.getOffers';
import removeLineItems                           from '@salesforce/apex/AddOpportunityOffer.removeLineItems';
import createLineItems                           from '@salesforce/apex/AddOpportunityOffer.createLineItems';
import generatePaymentLink                       from '@salesforce/apex/AddOpportunityOffer.generatePaymentLink';
import GenericAdminError                         from '@salesforce/label/c.GenericAdminError';
import OpportunityHasProductsAndPaymentLink      from '@salesforce/label/c.OpportunityHasProductsAndPaymentLink';
import getOpportunityLineItems                   from '@salesforce/apex/AddOpportunityOffer.getOpportunityLineItems';

export default class addOffer extends NavigationMixin(LightningElement) {
    @api recordId;
    pageNumber        = 'page1';
    isLoading         = false;
    selectedOffer     = null;
    offersList        = [];
    initialRecords    = [];
    selectedOfferData = [];
    offerProductsData = [];
    searchValue;
    errorMessage;

    offerColumns = [
        { label: 'Ofertas Disponíveis', fieldName: 'title', sortable: true, type: 'text' },
        { label: 'Preço',               fieldName: 'price', sortable: true, type: 'currency', hideDefaultActions: true, cellAttributes: { alignment: 'left' } },
        { label: 'Tipo',                fieldName: 'type',  sortable: true, type: 'text', hideDefaultActions: true }
    ];
    selectedOfferColumns = [
        { label: 'Oferta Selecionada', fieldName: 'title', type: 'text' }
    ];
    productColumns = [
        { label: 'Produtos da Oferta', fieldName: 'description', type: 'text',   hideDefaultActions: true },
        { label: 'Preço',              fieldName: 'price',       type: 'currency', hideDefaultActions: true, cellAttributes: { alignment: 'left' } }
    ];
    label = {
        GenericAdminError, OpportunityHasProductsAndPaymentLink
    };

    @wire(CurrentPageReference)
    getStateParameters(currentPageReference) {
        if (currentPageReference)
            this.recordId = currentPageReference.state.recordId;
    }

    connectedCallback() {

        getOpportunityLineItems({ opportunityId: this.recordId })
        .then((result) => {
            if (result.length > 0)
                ComponentNotifiers.showLightningAlert("warning", this.label.OpportunityHasProductsAndPaymentLink, "Aviso");
        })  
        
        getOffers()
        .then(result => {
            this.offersList     = result;
            this.initialRecords = result;
        })
        .catch(error => {
            console.log('catch lwc getOffers error:');
            this.handleError(error);
        });
    }

    async changePage(){

        if(this.pageNumber === 'page1'){
            if (this.selectedOffer == null){
                ComponentNotifiers.showToast(this, "error", 'Selecione uma oferta para continuar!', undefined, 'dismissible', 1000);
            }
            else if (this.selectedOffer[0].products == null || this.selectedOffer[0].products.length == 0){
                ComponentNotifiers.showToast(this, "error", 'Oferta não possui produtos, contate o admnistrador do sistema!', undefined, 'dismissible', 1000);
            }
            else{
                this.isLoading = true;

                this.selectedOfferData.push(this.selectedOffer[0]);
                this.offerProductsData = this.selectedOffer[0].products;

                this.pageNumber = 'page2';
                this.isLoading  = false;
            }
        }
        else if(this.pageNumber === 'page2'){
            this.searchValue       = null;
            this.selectedOffer     = null;
            this.selectedOfferData = [];
            this.offerProductsData = [];
            this.pageNumber        = 'page1';
        }

    }

    searchOffer(event){
        this.searchValue = event.target.value.toLowerCase();

        if (this.searchValue != null) {
            this.offersList = this.initialRecords;
 
            if (this.offersList) {
                let searchRecords = [];
 
                for (let record of this.offersList) {
                    let strVal = record.description;
 
                    if (strVal != null && strVal.toLowerCase().normalize('NFD').replace(/[\u0300-\u036f]/g, "").includes(this.searchValue))
                        searchRecords.push(record);
                }
 
                this.offersList = searchRecords;
            }
        } 
        else if (this.searchValue == null || this.searchValue == '' || this.searchValue == ' ' || this.searchValue.isEmpty())
            this.offersList = this.initialRecords;
    }

    async save() {
        try {
            this.isLoading = true;

            await removeLineItems({ opportunityId: this.recordId });
    
            const resultSaveLineItems = await createLineItems({ opportunityId: this.recordId, offer: this.selectedOfferData[0] });
            if (resultSaveLineItems !== 'Success') {
                ComponentNotifiers.showToast(this, "error", resultSaveLineItems, undefined, 'dismissible', 1000);
                return;
            }

            const resultSaveGeneratePaymentLink = await generatePaymentLink({ opportunityId: this.recordId, offer: this.selectedOfferData[0]});
            if (resultSaveGeneratePaymentLink !== 'Success') {
                ComponentNotifiers.showToast(this, "error", resultSaveGeneratePaymentLink, undefined, 'dismissible', 1000);
                return;
            }

            ComponentNotifiers.showToast(this, "success", "Produtos inseridos com sucesso!", undefined, 'dismissible', 2000);
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

    render(){ //this method runs everytime the page is rendered
        if(this.pageNumber === 'page1'){
            return firstPage;
        }
        else if(this.pageNumber === 'page2'){
            return secondPage;
        }
    }

    handleRowSelection(event){
        const selectedRow  = event.detail.selectedRows;
        this.selectedOffer = selectedRow;
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