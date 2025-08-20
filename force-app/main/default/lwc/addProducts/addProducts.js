import { LightningElement, api, wire } from 'lwc';
import { CloseActionScreenEvent } from 'lightning/actions';
import { CurrentPageReference, NavigationMixin } from 'lightning/navigation';
import ComponentNotifiers from 'c/componentNotifiers';
import firstPage from './selectBundle.html';
import secondPage from './confirmationPage.html';
import getBundles from '@salesforce/apex/AddOpportunityProducts.getBundles';
import getBundleProducts from '@salesforce/apex/AddOpportunityProducts.getBundleProducts';
import removeOpportunityLineItems from '@salesforce/apex/AddOpportunityProducts.removeOpportunityLineItems';
import createLineItems from '@salesforce/apex/AddOpportunityProducts.createLineItems';
import GenericAdminError from '@salesforce/label/c.GenericAdminError';
import OpportunityHasProducts from '@salesforce/label/c.OpportunityHasProducts';
import getOpportunityLineItems from '@salesforce/apex/AddOpportunityProducts.getOpportunityLineItems';

export default class addProducts extends NavigationMixin(LightningElement) {
    @api recordId;
    pageNumber         = 'page1';
    isLoading          = false;
    selectedBundle     = null;
    bundlesList        = [];
    initialRecords     = [];
    selectedBundleData = [];
    bundleProductsData = [];
    bundleProducts;
    chosenBundle;
    productNames = '';
    searchValue;
    errorMessage;
    returnSave;

    bundleColumns = [
        { label: 'Bundles Disponíveis', fieldName: 'Name', type: 'text', hideDefaultActions: true }
    ];
    selectedBundleColumns = [
        { label: 'Bundle Selecionado', fieldName: 'description', type: 'text', hideDefaultActions: true }
    ];
    productColumns = [
        { label: 'Produtos do Bundle', fieldName: 'name', type: 'text', hideDefaultActions: true },
        { label: 'Duração (meses)', fieldName: 'duration', type: 'number', hideDefaultActions: true, cellAttributes: { alignment: 'left' } }
        //{ label: 'Duração (meses)', fieldName: 'duration', type: 'number', hideDefaultActions: true, editable: true, cellAttributes: { alignment: 'left' } }
    ];
    label = {
        GenericAdminError, OpportunityHasProducts
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
                ComponentNotifiers.showLightningAlert("error", this.label.OpportunityHasProducts, "Aviso");
        })  
        
        getBundles({opportunityId: this.recordId})
        .then(result => {
            this.bundlesList    = result;
            this.initialRecords = result;
        })
        .catch(error => {
            console.log('catch lwc getBundles error:');
            this.handleError(error);
        });
    }

    async changePage(){

        if(this.pageNumber === 'page1'){
            if (this.selectedBundle == null){
                ComponentNotifiers.showToast(this, "error", 'Selecione um bundle para continuar!', undefined, 'dismissible', 1000);
            }
            else{
                this.isLoading = true;
                this.pageNumber = 'page2';

                await getBundleProducts({bundleCode: this.selectedBundle[0].ProductCode})
                .then(result => {
                    if (result == null) 
                        ComponentNotifiers.showToast(this, "error", this.label.GenericAdminError, undefined, 'dismissible', 1000);
                    else if (result.products == null || result.products.length == 0)
                        ComponentNotifiers.showToast(this, "error", 'Bundle não possui produtos, contate o admnistrador do sistema!', undefined, 'dismissible', 1000);
                    
                    this.chosenBundle       = result;
                    this.selectedBundleData = [ { description: result.description } ];
                    this.bundleProducts     = result.products;
                    this.bundleProductsData = result.products.map(value=>{
                        return{...value,duration:value.parameters.duration} 
                    });

                })
                .catch(error => {
                    console.log('catch lwc getBundleProducts error: ', error);
                    this.handleError(error);
                });

                this.isLoading = false;
            }
        }
        else if(this.pageNumber === 'page2'){
            this.selectedBundle     = null;
            this.chosenBundle       = null;
            this.selectedBundleData = [];
            this.bundleProductsData = [];
            this.pageNumber         = 'page1';
        }

    }

    searchBundle(event){
        this.searchValue = event.target.value.toLowerCase();

        if (this.searchValue != null) {
            this.bundlesList = this.initialRecords;
 
            if (this.bundlesList) {
                let searchRecords = [];
 
                for (let record of this.bundlesList) {
                    let strVal = record.Name;
 
                    if (strVal != null && strVal.toLowerCase().normalize('NFD').replace(/[\u0300-\u036f]/g, "").includes(this.searchValue)) {
                        searchRecords.push(record);
                    }
                }
 
                this.bundlesList = searchRecords;
            }
        } 
        else if (this.searchValue == null || this.searchValue == '' || this.searchValue == ' ' || this.searchValue.isEmpty()){
            this.bundlesList = this.initialRecords;
        }
    }

    async save() {
        try {
            this.isLoading = true;

            await removeOpportunityLineItems({
                opportunityId: this.recordId
            });
    
            const resultSave = await createLineItems({ opportunityId: this.recordId, bundle: this.chosenBundle, productsFromLWC: this.bundleProducts });
    
            if (resultSave !== 'Success') {
                ComponentNotifiers.showToast(this, "error", resultSave, undefined, 'dismissible', 1000);
                return;
            }
    
            ComponentNotifiers.showToast(this, "success", "Produtos inseridos com sucesso!", undefined, 'dismissible', 2000);
        } catch (error) {
            console.error('Erro no método save:', error);
            this.handleError(error);
        } finally {
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
        const selectedRow   = event.detail.selectedRows;
        this.selectedBundle = selectedRow;
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