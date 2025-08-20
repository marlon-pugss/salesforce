import { LightningElement, track } from 'lwc';
import getCaseOrderRows from '@salesforce/apex/CaseOrderTableController.getCaseOrderRows';

const STATUS_OPTIONS = [
    { label: 'PAID', value: 'PAID' },
    { label: 'CHARGEBACK', value: 'CHARGEBACK' },
    { label: 'REFUSED', value: 'REFUSED' },
    { label: 'PENDING', value: 'PENDING' },
    { label: 'REFUNDED', value: 'REFUNDED' },
    { label: 'EXPIRED', value: 'EXPIRED' },
    { label: 'DELAYED', value: 'DELAYED' },
    { label: 'CANCELED', value: 'CANCELED' },
    { label: 'REFUND REQUESTED', value: 'REFUND REQUESTED' },
    { label: 'DISPUTE', value: 'DISPUTE' }
];

export default class TESTE_CASO extends LightningElement {
    @track allRows = [];
    @track error;
    @track isLoading = false;
    @track filtroContratoId = '';
    @track startDate;
    @track endDate;
    @track exceedsLimit = false;
    @track totalRecords = 0;
    @track selectedStatus = ['DELAYED', 'CANCELED', 'PENDING', 'EXPIRED'];
    statusOptions = STATUS_OPTIONS;

    columns = [
        { label: 'Nome da Conta', fieldName: 'accountName', type: 'text' },
        { label: 'Email do Proprietário', fieldName: 'ownerEmail', type: 'email' },
        { label: 'Email da Conta', fieldName: 'accountEmail', type: 'text' },
        { label: 'Telefone Completo', fieldName: 'fullPhone', type: 'text' },
        { label: 'Telefone do Contato', fieldName: 'contactPhone', type: 'text' },
        { label: 'ID do Caso', fieldName: 'caseId', type: 'text' },
        { label: 'ID da Ordem', fieldName: 'paymentOrderId', type: 'text' },
        { 
            label: 'Data do Pedido', 
            fieldName: 'orderDate', 
            type: 'date',
            typeAttributes: {
                year: "numeric",
                month: "2-digit",
                day: "2-digit"
            }
        },
        { label: 'ID do Contrato', fieldName: 'contractId', type: 'text' },
        { label: 'Pedidos Atrasados', fieldName: 'delayedOrders', type: 'number' },
        { label: 'Link de Pagamento', fieldName: 'paymentLink', type: 'text' }
    ];

    connectedCallback() {
        const today = new Date();
        this.endDate = today.toISOString().split('T')[0];
        today.setDate(today.getDate() - 30);
        this.startDate = today.toISOString().split('T')[0];
    }

    async loadData() {
        if (!this.startDate || !this.endDate) {
            this.error = 'Por favor, selecione o período de datas.';
            return;
        }
        try {
            this.isLoading = true;
            this.error = undefined;
            this.exceedsLimit = false;

            const result = await getCaseOrderRows({
                startDate: this.startDate,
                endDate: this.endDate,
                statusList: this.selectedStatus
            });

            if (result.exceedsLimit) {
                this.exceedsLimit = true;
                this.totalRecords = result.totalRecords;
                this.allRows = [];
                this.error = `O período selecionado retornou ${result.totalRecords} registros, excedendo o limite de 20000. Reduza o intervalo de datas para obter menos registros.`;
                return;
            }

            this.allRows = result.records;
            this.totalRecords = result.totalRecords;
        } catch (error) {
            this.error = 'Erro ao carregar dados: ' + (error.body?.message || error.message || 'Erro desconhecido');
            this.allRows = [];
        } finally {
            this.isLoading = false;
        }
    }

    get allRowsFiltradas() {
        let rows = this.allRows;
        if (this.filtroContratoId) {
            rows = rows.filter(row =>
                row.contractId && row.contractId.toLowerCase().includes(this.filtroContratoId.toLowerCase())
            );
        }
        return rows;
    }

    get rowsFiltradas() {
        return this.allRowsFiltradas.slice(0, 50);
    }

    get registrosInfo() {
        const filteredCount = this.allRowsFiltradas.length;
        return `Mostrando ${Math.min(filteredCount, 50)} de ${filteredCount} registros filtrados (${this.totalRecords} encontrados no total)`;
    }

    get showNoData() {
        return !this.isLoading && (!this.allRowsFiltradas || this.allRowsFiltradas.length === 0);
    }

    handleDateChange(event) {
        const { name, value } = event.target;
        this[name] = value;
    }

    handleFiltroContratoId(event) {
        this.filtroContratoId = event.target.value;
    }

    handleStatusChange(event) {
        this.selectedStatus = event.detail.value;
    }

    handleSearch() {
        this.loadData();
    }

    handleRefresh() {
        this.loadData();
    }

    exportarCSV() {
        let selectedRows = [];
        let downloadRecords = [];

        try {
            selectedRows = this.template.querySelector("lightning-datatable").getSelectedRows();
        } catch (error) {
            selectedRows = [];
        }

        if (selectedRows.length > 0) {
            downloadRecords = [...selectedRows];
        } else {
            downloadRecords = [...this.allRowsFiltradas];
        }

        if (!downloadRecords || downloadRecords.length === 0) {
            alert('Nenhum registro para exportar');
            return;
        }

        const csvFile = this.convertArrayToCsv(downloadRecords);
        this.createLinkForDownload(csvFile);
    }

    convertArrayToCsv(records) {
        const headers = [
            'Proprietário do Caso',
            'Email do Proprietário',
            'Nome da Conta',
            'Email da Conta',
            'Telefone Completo',
            'Telefone do Contato',
            'ID do Caso',
            'ID do Pedido',
            'Data do Pedido',
            'ID do Contrato',
            'Pedidos Atrasados',
            'Link de Pagamento'
        ];

        const rows = records.map(record => ({
            'Proprietário do Caso': record.ownerName || '',
            'Email do Proprietário': record.ownerEmail || '',
            'Nome da Conta': record.accountName || '',
            'Email da Conta': record.accountEmail || '',
            'Telefone Completo': record.fullPhone || '',
            'Telefone do Contato': record.contactPhone || '',
            'ID do Caso': record.caseId || '',
            'ID do Pedido': record.paymentOrderId || '',
            'Data do Pedido': record.orderDate ? new Date(record.orderDate).toLocaleDateString('pt-BR') : '',
            'ID do Contrato': record.contractId || '',
            'Pedidos Atrasados': record.delayedOrders || '',
            'Link de Pagamento': record.paymentLink || ''
        }));

        const csvRows = [
            headers.join(','),
            ...rows.map(row => headers.map(header => 
                `"${String(row[header] || '').replace(/"/g, '""')}"`
            ).join(','))
        ];

        return csvRows.join('\n');
    }

    createLinkForDownload(csvFile) {
        const timestamp = new Date().toISOString().replace(/[:.]/g, '-');
        const downLink = document.createElement("a");
        downLink.href = "data:text/csv;charset=utf-8,\uFEFF" + encodeURI(csvFile);
        downLink.target = '_blank';
        downLink.download = `contratos_casos_ordens_${timestamp}.csv`;
        downLink.click();
    }
}