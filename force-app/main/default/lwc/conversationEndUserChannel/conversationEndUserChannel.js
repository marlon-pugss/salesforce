import { LightningElement, wire } from 'lwc';
import updateMessaginSession from '@salesforce/apex/MessagingSessionController.updateMessaginSession';

import {
    subscribe,
    unsubscribe,
    APPLICATION_SCOPE,
    MessageContext
} from 'lightning/messageService';

import ConversationEndUserChannel from '@salesforce/messageChannel/lightning__conversationEndUserMessage';

export default class ConversationEndUserExample extends LightningElement {
    subscription = null;
    recordId;
    content;
    timestamp;

    // To pass scope, you must get a message context.
    @wire(MessageContext)
    messageContext;

    // Standard lifecycle hook used to subscribe to the message channel
    connectedCallback() {
        this.subscribeToMessageChannel();
    }

    // Pass scope to the subscribe() method.
    subscribeToMessageChannel() {
        if (!this.subscription) {
            this.subscription = subscribe(
                this.messageContext,
                ConversationEndUserChannel,
                (message) => this.handleMessage(message),
                { scope: APPLICATION_SCOPE }
            );
        }
    }

    // Handler for message received by component
    handleMessage(message) {
        this.recordId = message.recordId;
        this.content = message.content;
        this.timestamp = this.formatDate(message.timestamp);

        updateMessaginSession({msId: this.recordId, msDate:this.timestamp, message:this.content })
       .then(result => {
        })
        .catch(error => {
            console.log('catch lwc getOpportunity error:');
            this.handleError(error);
        });
    }

    formatDate(timestamp) {
        if (!timestamp || isNaN(timestamp)) {
            return 'Data inválida';
        }
        
        const dateObj = new Date(parseInt(timestamp, 10));
        const day = dateObj.getDate().toString().padStart(2, '0');
        const month = (dateObj.getMonth() + 1).toString().padStart(2, '0');
        const year = dateObj.getFullYear();
        const hours = dateObj.getHours().toString().padStart(2, '0');
        const minutes = dateObj.getMinutes().toString().padStart(2, '0');
        const seconds = dateObj.getSeconds().toString().padStart(2, '0');
    
        return `${month}-${day} ${hours}:${minutes}:${seconds}`;
    } 
}




