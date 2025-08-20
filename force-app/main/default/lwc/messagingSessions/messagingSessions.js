import { LightningElement, track } from 'lwc';
import getMessagingSessions from '@salesforce/apex/MessagingSessionController.getMessagingSessions';

export default class MessagingSessionList extends LightningElement {
    @track messagingSessions;
    @track filteredSessions;
    @track error;
    @track isLoading = true;
    @track selectedStage = '';
    @track selectedDateFilter = '';
    @track selectedStatus = ''; 
    @track selectedSender = '';  
    @track lastUpdate;

    defaultSortDirection = 'asc';
    sortDirection = 'asc';
    sortedBy;

    stageOptions = [
        { label: 'Todas', value: '' }
    ];

    dateOptions = [
        { label: 'Todas', value: '' },
        { label: 'D0', value: '0' },
        { label: 'D1', value: '1' },
        { label: 'D2', value: '2' },
        { label: 'D3', value: '3' },
        { label: 'D4', value: '4' },
        { label: 'D5', value: '5' },
        { label: 'D6', value: '6' }
    ];

    statusOptions = [
        { label: 'Todas', value: '' },
        { label: 'Ativo', value: 'Active' },
        { label: 'Inativo', value: 'Inactive' }
    ];

    // Opções fixas para Sender
    senderOptions = [
        { label: 'Todos', value: '' },
        { label: 'Aluno', value: 'EndUser' },
        { label: 'Agente', value: 'Agent' },
        { label: 'Sistema', value: 'System' }
    ];

    // Colunas com 'sortable' nas colunas que podem ser ordenadas
    columns = [
        {
            label: 'Oportunidade',
            fieldName: 'messagingSessionUrl',
            type: 'url',
            typeAttributes: {
                label: { fieldName: 'OpportunityName' },
                target: '_unfencedTop'
            }
        },
        {
            label: 'Fase',
            fieldName: 'OpportunityStage',
            type: 'text',
            sortable: true
        },
        {
            label: 'Status',
            fieldName: 'Status',
            type: 'text',
            sortable: true
        },
        {
            label: 'Última Mensagem',
            fieldName: 'LastMessage',
            type: 'text'
        },
        {
            label: 'Data Última Mensagem',
            fieldName: 'lastMessageDate',
            type: 'text',
            sortable: true
        }
    ];

    pollInterval;

    connectedCallback() {
        this.loadMessagingSessions();
        this.startPolling();
    }

    disconnectedCallback() {
        this.stopPolling();
    }

    loadMessagingSessions() {
        this.isLoading = true;
        getMessagingSessions()
            .then((data) => {
                const baseUrl = window.location.origin;
                this.messagingSessions = data.map(session => ({
                    ...session,
                    messagingSessionUrl: `${baseUrl}/lightning/r/MessagingSession/${session.Id}/view`,
                    OpportunityName: session.Opportunity ? session.Opportunity.Name : 'No Opportunity',
                    OpportunityStage: session.Opportunity ? session.Opportunity.StageName : 'N/A',
                    lastModifiedDate: session.LastModifiedDate,
                    lastMessageDate: session.LastMessageDate__c,
                    lastMessageTimestamp: session.LastMessageDate__c,
                    Status: session.Status || 'N/A',
                    Sender: session.Sender__c || 'N/A',
                    LastMessage: session.LastMessage__c || 'N/A'
                }));

                // Ordena as sessões pelo LastMessageDate__c (timestamp) em ordem decrescente
                this.messagingSessions.sort((a, b) => b.lastMessageTimestamp - a.lastMessageTimestamp);

                this.updateFilters();
                this.error = undefined;
                this.isLoading = false;
                this.lastUpdate = new Date().toISOString();

                this.filterSessions();
            })
            .catch((error) => {
                console.error('Error loading messaging sessions:', JSON.stringify(error));
                this.error = error.body ? error.body.message : 'Unknown error';
                this.messagingSessions = undefined;
                this.filteredSessions = undefined;
                this.isLoading = false;
            });
    }

    updateFilters() {
        const uniqueStages = new Set();
        const uniqueStatuses = new Set();
        this.messagingSessions.forEach(session => {
            if (session.OpportunityStage && session.OpportunityStage !== 'N/A') {
                uniqueStages.add(session.OpportunityStage);
            }
            if (session.Status && session.Status !== 'N/A') {
                uniqueStatuses.add(session.Status);
            }
        });
        this.stageOptions = [...uniqueStages].map(stage => ({ label: stage, value: stage }));
        this.stageOptions.unshift({ label: 'Todas', value: '' });
        this.statusOptions = [...uniqueStatuses].map(status => ({ label: status, value: status }));
        this.statusOptions.unshift({ label: 'Todas', value: '' });
    }

    handleStageChange(event) {
        this.selectedStage = event.detail.value;
        this.filterSessions();
    }

    handleDateChange(event) {
        this.selectedDateFilter = event.detail.value;
        this.filterSessions();
    }

    handleStatusChange(event) {
        this.selectedStatus = event.detail.value;
        this.filterSessions();
    }

    handleSenderChange(event) {
        this.selectedSender = event.detail.value;
        this.filterSessions();
    }

    filterSessions() {
        this.filteredSessions = this.messagingSessions.filter(session => {
            const matchesStage = this.selectedStage === '' || session.OpportunityStage === this.selectedStage;
            const matchesDate = this.selectedDateFilter === '' || this.isDateInRange(session.CreatedDate, parseInt(this.selectedDateFilter, 10));
            const matchesStatus = this.selectedStatus === '' || session.Status === this.selectedStatus;
            const matchesSender = this.selectedSender === '' || session.Sender === this.selectedSender;
            return matchesStage && matchesDate && matchesStatus && matchesSender;
        });
        // Aplica a ordenação aos filteredSessions após a filtragem
        this.filteredSessions.sort(this.sortBy(this.sortedBy, this.sortDirection === 'asc' ? 1 : -1));
    }

    isDateInRange(lastModifiedDate, daysAgo) {
        const today = new Date();
        const targetDate = new Date(today);
        targetDate.setDate(today.getDate() - daysAgo);
    
        // Cria cópias dos objetos de data
        const sessionDate = new Date(lastModifiedDate);
        sessionDate.setHours(0, 0, 0, 0);
        targetDate.setHours(0, 0, 0, 0);
    
        return sessionDate.getTime() === targetDate.getTime();
    }    

    startPolling() {
        this.pollInterval = setInterval(() => {
            this.loadMessagingSessions();
        }, 5000);
    }

    stopPolling() {
        clearInterval(this.pollInterval);
    }

    // Função para ordenação
    sortBy(field, reverse, primer) {
        const key = primer
            ? function (x) {
                  return primer(x[field]);
              }
            : function (x) {
                  return x[field];
              };

        return function (a, b) {
            a = key(a);
            b = key(b);
            return reverse * ((a > b) - (b > a));
        };
    }

    onHandleSort(event) {
        const { fieldName: sortedBy, sortDirection } = event.detail;
        const cloneData = [...this.filteredSessions]; // Use filteredSessions para manter a ordenação

        cloneData.sort(this.sortBy(sortedBy, sortDirection === 'asc' ? 1 : -1));
        this.filteredSessions = cloneData; // Atualiza filteredSessions com os dados ordenados
        this.sortDirection = sortDirection; // Atualiza a direção de ordenação
        this.sortedBy = sortedBy; // Atualiza o campo ordenado
    }
}
