import { LightningElement, api, track } from 'lwc';
import getProductMovementCallout from '@salesforce/apexContinuation/ProductsMovementsCalloutsServicesUtil.productMovementCallout';

export default class SubproductsLWC extends LightningElement {
    @api producttype;
    @api personcode;

    @api savingsresponse;
    @api checkingsresponse;
    @api cardsresponse;
    @api loansresponse;

    @track isSavings = false;
    @track isCheckings = false;
    @track isCards = false;
    @track isLoans = false;

    @track isloading = false;

    @track currentPageLimit = 20; // TODO: Add as parameter on meta file
    @track currentOffset = 0;

    renderedCallback() {
        console.log('this.producttype', this.producttype);
        console.log('1error:', this.errormessage);
        this.isloading = true;
        switch (this.producttype) {
            case 'SAVINGS':
                this.isSavings = true;
                console.log('this.isavings, response rendered');
                console.log(this.savingsresponse);
                if (this.savingsresponse == null) {
                    return;
                }

                try {
                    this.savingsresponse = JSON.parse(this.savingsresponse);
                }
                catch (error) {
                    console.error('error', error);
                }
                break;
            case 'CHECKINGS':
                this.isCheckings = true;
                console.log('this.isCheckings, response rendered');
                console.log(this.checkingsresponse);
                if (this.checkingsresponse == null) {
                    this.isloading = false;
                    return;
                }
                try {
                    this.checkingsresponse = JSON.parse(this.checkingsresponse);
                    this.isloading = false;

                }
                catch (error) {
                    console.error('error', error);
                }
                break;
            case 'CREDIT_CARDS,DEBIT_CARDS':
                this.isCards = true;
                console.log('this.isCards, response rendered');
                console.log(this.cardsresponse);
                if (this.cardsresponse == null) {
                    this.isloading = false;
                    return;
                }
                try {
                    this.cardsresponse = JSON.parse(this.cardsresponse);
                    this.isloading = false;

                }
                catch (error) {
                    console.error('error', error);
                }
                break;
            case 'LOANS':
                this.isLoans = true;
                console.log('this.isLoans, response rendered');
                console.log(this.loansresponse);
                if (this.loansresponse == null) {
                    this.isloading = false;
                    return;

                }
                try {
                    this.loansresponse = JSON.parse(this.loansresponse);
                    this.isloading = false;
                }
                catch (error) {
                    console.error('error', error);
                }
                break;
        }
    }
    connectedCallback() {
        console.log('this.producttype', this.producttype);
        console.log('2error:', this.errormessage);
        switch (this.producttype) {
            case 'SAVINGS':
                this.isSavings = true;
                break;
            case 'CHECKINGS':
                this.isCheckings = true;
                break;
            case 'CREDIT_CARDS,DEBIT_CARDS':
                this.isCards = true;
                break;
            case 'LOANS':
                this.isLoans = true;
                break;
        }
    }

    addRemoveSelectedCustomBox(event) {
        const highlightedElement = this.template.querySelector('.custom-box-active');

        if (highlightedElement) {
            highlightedElement.classList.remove('custom-box-active');
        }
        const targetElement = event.currentTarget;

        targetElement.classList.add('custom-box-active');
        this.movementsFound = true;

    }



    @track movementsFound = true;
    async fetchMovements(accountNumber, nextPage, previousPage) {
        this.isLoading = true;
        this.movementsFound = true;
        let productTypeCorrected = this.producttype;
        console.log('🎁', this.producttype)
        if (this.producttype == 'CREDIT_CARDS,DEBIT_CARDS') {
            productTypeCorrected = 'CREDIT_CARDS'
        }
        console.log(productTypeCorrected);
        try {
            console.log(nextPage, previousPage);
            console.log(this.currentOffSet);
            console.log(this.currentPageLimit);
            // First load
            if (!nextPage && !previousPage) {
                this.currentOffSet = 0;
            }
            else {
                if (nextPage && this.currentOffSet == null) {
                    this.currentOffSet = 0;
                }
                else if (nextPage) {
                    this.currentOffSet += this.currentPageLimit;
                }

                if (previousPage && this.currentOffSet == null) {
                    this.currentOffSet = 0;
                }
                else if (previousPage && this.currentOffSet - this.currentPageLimit >= 0) {
                    this.currentOffSet -= this.currentPageLimit;
                }
            }


            console.log('currentoffset', this.currentOffSet);
            console.log('currentPageLimit', this.currentPageLimit);

            let movementResult = await getProductMovementCallout({ accountNumber: accountNumber, productType: productTypeCorrected, offset: this.currentOffSet, pageLimit: this.currentPageLimit });



            console.log('✔✔✔ Movements:', movementResult);
            console.log(movementResult == null);
            console.log(this.producttype);

            if (this.producttype == 'LOANS') {
                let mov = JSON.parse(movementResult).installments;

                if (mov == null){
                    console.log('NO MORE RESULTS');
                    this.movementsFound = false;
                    this.isLoading = false;
                    this.currentOffSet -= this.currentPageLimit;
                    console.log('return');
                    throw new Error('Return, no response');
                }
                
            }

            if (movementResult == null) {
                this.movementsFound = false;
                this.isLoading = false;
                console.log('return');
                throw new Error('Return, no response');

            }
            else {
                if (this.producttype == 'SAVINGS') {
                    let mov = JSON.parse(movementResult).movements;
                    this.recentSavingMovements = null;
                    this.recentSavingMovements = mov;
                    console.log('✔✔✔ SAVINGS:', this.recentSavingMovements);
                }
                if (this.producttype == 'LOANS') {
                    let mov = JSON.parse(movementResult).installments;

                    console.log('❤', mov);
                   
                    this.recentLoanMovements = null;
                    this.recentLoanMovements = mov;
                    console.log('✔✔✔ LOANS:', this.recentLoanMovements);
                }

                if (this.producttype == 'CHECKINGS') {
                    let mov = JSON.parse(movementResult).movements;
                    this.recentCheckingMovements = null;
                    this.recentCheckingMovements = mov;
                    console.log('✔✔✔ CHECKINGS:', this.recentCheckingMovements);
                }

                if (this.producttype == 'CREDIT_CARDS,DEBIT_CARDS') {
                    let mov = JSON.parse(movementResult).movements;
                    if (!mov) {
                        this.movementsFound = false;
                        this.isLoading = false;

                    }
                    else {
                        this.recentCardMovements = null;
                        this.recentCardMovements = mov;
                        console.log('✔✔✔ CREDIT_CARDS:', this.recentCardMovements);
                    }
                }
            }
            this.isLoading = false;
        }
        catch (error) {
            console.log(JSON.stringify(error));
            this.isLoading = false;
        }
    }

    // Cards 
    @track selectedCard = null;
    @track selectedCardDetailNumber = null;
    @track selectedCardIsCredit = null;

    @track recentCardMovements = null;

    handleCardClick(event) {
        this.addRemoveSelectedCustomBox(event);

        const selectedItem = event.currentTarget.dataset.cardNumber;
        this.recentCardMovements = null;
        this.movementsFound = true;
        console.log('selectedItem:', selectedItem);
        this.selectedCardDetailNumber = selectedItem;

        for (const card of this.cardsresponse) {
            console.log(card.cardNumber);
            console.log(card.cardNumber === selectedItem);
            if (card.cardNumber === selectedItem) {
                this.selectedCardIsCredit = card.isCredit
                this.selectedCard = card.moreDetails;
                break;
            }
        }
    }

    @track previousSelectedCard = null;

    handleMovementsCards() {
        console.log(JSON.stringify(this.recentCardMovements));
        console.log(this.recentCardMovements == true);
        if (this.recentCardMovements) {
            this.recentCardMovements = null;
            return;
        }

        this.previousSelectedCard = this.selectedCardDetailNumber;
        this.fetchMovements(this.selectedCard?.accountNumber, false, false);
        //this.fetchMovements('10187336', false, false);
        this.selectedCardDetailNumber = null;
    }


    handleReturnCards() {
        if (this.recentCardMovements) {
            this.recentCardMovements = null;
        }
        this.selectedCardDetailNumber = this.previousSelectedCard;
    }

    handlePrevioCards() {
        //this.fetchMovements('10187336', false, true);
        this.fetchMovements(this.selectedCard?.accountNumber, false, true);
    }

    handleSiguienteCards() {
        //this.fetchMovements('10187336', true, false);
        this.fetchMovements(this.selectedCard?.accountNumber, true, false);

    }




    // Loans
    @track selectedLoan = null;
    @track selectedLoanDetailNumber = null;
    @track recentLoanMovements = null;
    handleLoanClick(event) {
        this.addRemoveSelectedCustomBox(event);
        const selectedItem = event.currentTarget.dataset.accountNumber;
        this.selectedLoanDetailNumber = selectedItem;
        this.recentLoanMovements = null;

        for (const loan of this.loansresponse) {
            if (loan.accountNumber === selectedItem) {
                this.selectedLoan = loan.moreDetails;
                break;
            }
        }
    }
    @track previousSelectedLoan = null;

    handleMovementsLoans() {

        if (this.recentLoanMovements) {
            this.recentLoanMovements = null;
            return;
        }


        //this.recentLoanMovements = this.genericMovementsMockup;//this.selectedLoan.installments;
        this.previousSelectedLoan = this.selectedLoanDetailNumber;
        this.fetchMovements(this.previousSelectedLoan, false, false);
        this.selectedLoanDetailNumber = null;

    }

    handleReturnLoans() {
        if (this.recentLoanMovements) {
            this.recentLoanMovements = null;
        }
        this.selectedLoanDetailNumber = this.previousSelectedLoan;
    }

    handlePrevioLoans() {
        this.fetchMovements(this.previousSelectedLoan, false, true);
    }

    handleSiguienteLoans() {
        this.fetchMovements(this.previousSelectedLoan, true, false);
    }

    @track columnsLoans = [
        { label: 'Cuota', fieldName: 'installmentNumber', wrapText: true, initialWidth: 100 },
        {
            label: 'Fecha de Vencimiento', fieldName: 'expirationDate', wrapText: false, initialWidth: 250, type: "date",
            typeAttributes: {
                year: "numeric",
                month: "long",
                day: "2-digit",
                hour: "2-digit",
                minute: "2-digit"
            }
        },
        { label: 'Estado', fieldName: 'status', wrapText: true, initialWidth: 100 },
        { label: 'Monto', fieldName: 'amount', type: 'currency', wrapText: true, initialWidth: 100 },
        { label: 'Descripción', fieldName: 'description', wrapText: true, initialWidth: 150 },
        {
            label: 'Fecha de Pago', fieldName: 'paymentDate', wrapText: false, initialWidth: 250, type: "date",
            typeAttributes: {
                year: "numeric",
                month: "long",
                day: "2-digit",
                hour: "2-digit",
                minute: "2-digit"
            }
        },
        { label: 'Alias Débito', fieldName: 'debitAccountAlias', wrapText: true, initialWidth: 100 },
        { label: 'Cuenta de Débito', fieldName: 'debitAccountNumber', wrapText: true, initialWidth: 200 },
        { label: 'Nombre Cuenta de Origen', fieldName: 'fromAccountName', wrapText: true, initialWidth: 200 },
        { label: 'Numero Cuenta de Origen', fieldName: 'fromAccountNumber', wrapText: true, initialWidth: 200 },
        { label: 'Negocio del Cheque', fieldName: 'checkBusinessName', wrapText: true, initialWidth: 200 }
    ];


    // Checking
    @track selectedChecking = null;
    @track selectedCheckingDetailNumber = null;
    @track recentCheckingMovements = null;
    handleCheckingClick(event) {
        this.addRemoveSelectedCustomBox(event);
        const selectedItem = event.currentTarget.dataset.accountNumber;
        this.selectedCheckingDetailNumber = selectedItem;
        this.recentCheckingMovements = null;

        for (const checking of this.checkingsresponse) {
            if (checking.accountNumber === selectedItem) {
                this.selectedChecking = checking.moreDetails;
                break;
            }
        }
    }
    @track previousSelectedChecking = null;

    handleMovementsCheckings() {

        console.log(JSON.stringify(this.recentCheckingMovements));
        console.log(this.recentCheckingMovements == true);
        if (this.recentCheckingMovements) {
            this.recentCheckingMovements = null;
            return;
        }


        //this.recentCheckingMovements = this.genericMovementsMockup;//this.selectedChecking.movements;
        console.log(JSON.stringify(this.recentCheckingMovements));
        this.previousSelectedChecking = this.selectedCheckingDetailNumber;
        this.fetchMovements(this.previousSelectedChecking, false, false);
        console.log(JSON.stringify(this.previousSelectedChecking));
        this.selectedCheckingDetailNumber = null;
    }

    handleReturnCheckings() {
        if (this.recentCheckingMovements) {
            this.recentCheckingMovements = null;
        }
        this.selectedCheckingDetailNumber = this.previousSelectedChecking;
        this.movementsFound = true;
    }

    handlePrevioCheckings() {
        this.fetchMovements(this.previousSelectedChecking, false, true);
        this.movementsFound = true;
    }

    handleSiguienteCheckings() {
        this.fetchMovements(this.previousSelectedChecking, true, false);
        this.movementsFound = true;
    }

    // Savings
    @track selectedSaving = null;
    @track selectedSavingDetailNumber = null;
    @track recentSavingMovements = null;
    handleSavingClick(event) {
        this.addRemoveSelectedCustomBox(event);
        const selectedItem = event.currentTarget.dataset.accountNumber;
        this.selectedSavingDetailNumber = selectedItem;
        this.recentSavingMovements = null;

        for (const saving of this.savingsresponse) {
            if (saving.accountNumber == selectedItem) {
                this.selectedSaving = saving.moreDetails;
                break;
            }
        }
    }

    @track genericMovementsMockup = [
        {
            "movementType": "CONSUMO",
            "movementDate": "31-12-2023 9:00 PM",
            "description": "Compra de alimentos",
            "amount": "20 USD"
        },
        {
            "movementType": "CONSUMO",
            "movementDate": "31-12-2023 9:00 PM",
            "description": "Gasolina para el auto",
            "amount": "50 USD"
        },
        {
            "movementType": "CONSUMO",
            "movementDate": "31-12-2023 9:00 PM",
            "description": "Compras en línea",
            "amount": "75 USD"
        }
    ];

    /* {
        "pageLimit": "0",
        "offset": "25",
        "movements": [
            {
                "movementType": "CONSUMO",
                "movementDate": "31-12-2023 9:00 PM",
                "description": "Compra de alimentos",
                "amount": "20 USD"
            },
            {
                "movementType": "CONSUMO",
                "movementDate": "31-12-2023 9:00 PM",
                "description": "Gasolina para el auto",
                "amount": "50 USD"
            },
            {
                "movementType": "CONSUMO",
                "movementDate": "31-12-2023 9:00 PM",
                "description": "Compras en línea",
                "amount": "75 USD"
            }
        ]
    }; */

    genericMovementColumns = [
        { label: 'Descripcion', fieldName: 'description', wrapText: true, initialWidth: 250 },
        { label: 'Tipo Movimiento', fieldName: 'movementType', wrapText: false, initialWidth: 150 },
        { label: 'Fecha Movimiento', fieldName: 'movementDate', wrapText: false, initialWidth: 200 },
        { label: 'Monto', fieldName: 'amount', wrapText: true, initialWidth: 100 },
    ];

    savingMovementColumns = [
        { label: 'Concepto', fieldName: 'concept', wrapText: true, initialWidth: 250 },
        { label: 'Tipo Movimiento', fieldName: 'movementType', wrapText: false, initialWidth: 150 },
        { label: 'Fecha Movimiento', fieldName: 'movementDate', wrapText: false, initialWidth: 200 },
        { label: 'Monto', fieldName: 'amount', wrapText: true, initialWidth: 100 },
        { label: 'Transacción Padre', fieldName: 'parentTransaction', wrapText: true, initialWidth: 100 },
        { label: 'Transacción Hijo', fieldName: 'childTransaction', wrapText: true, initialWidth: 100 },
        { label: 'Ingresado por', fieldName: '', wrapText: true, initialWidth: 100 },
        { label: 'Situacion', fieldName: '', wrapText: true, initialWidth: 100 },
        { label: 'Código Swift', fieldName: '', wrapText: true, initialWidth: 100 },

    ];

    /*savingsColumns = [
        { label: 'Account Number', fieldName: 'accountNumber',  wrapText: true, initialWidth: 100},
        { label: 'Person Code', fieldName: 'personCode',  wrapText: true, initialWidth: 100},
        { label: 'Denomination', fieldName: 'denomination',  wrapText: true, initialWidth: 100},
        { label: 'Movement Type Code', fieldName: 'movementTypeCode',  wrapText: true, initialWidth: 100},
        { label: 'Movement Type', fieldName: 'movementType',  wrapText: true, initialWidth: 100},
        { label: 'Date', fieldName: 'date',  wrapText: true, initialWidth: 100},
        { label: 'User Code', fieldName: 'userCode',  wrapText: true, initialWidth: 100},
        { label: 'Balance', fieldName: 'balance.amount',  wrapText: true, initialWidth: 100},
        { label: 'Currency Code', fieldName: 'balance.currency.code',  wrapText: true, initialWidth: 100},
        { label: 'Currency Description', fieldName: 'balance.currency.description',  wrapText: true, initialWidth: 100},
        { label: 'Office Code', fieldName: 'officeCode',  wrapText: true, initialWidth: 100},
        { label: 'Error Code', fieldName: 'errorCode',  wrapText: true, initialWidth: 100},
        { label: 'Status', fieldName: 'status',  wrapText: true, initialWidth: 100},
        { label: 'Cause Code', fieldName: 'causeCode',  wrapText: true, initialWidth: 100},
        { label: 'Cause Description', fieldName: 'causeDescription',  wrapText: true, initialWidth: 100},
        { label: 'Bank Description', fieldName: 'bankDescription',  wrapText: true, initialWidth: 100},
        { label: 'Origin Office Description', fieldName: 'originOfficeDescription',  wrapText: true, initialWidth: 100},
        { label: 'Concept', fieldName: 'concept',  wrapText: true, initialWidth: 100},
        { label: 'Rate Code', fieldName: 'rateCode',  wrapText: true, initialWidth: 100},
        { label: 'Rate Value', fieldName: 'rateValue',  wrapText: true, initialWidth: 100},
        { label: 'Category Code', fieldName: 'categoryCode',  wrapText: true, initialWidth: 100},
        { label: 'Category Description', fieldName: 'categoryDescription',  wrapText: true, initialWidth: 100},
        { label: 'Is Reversed', fieldName: 'isReversed',  wrapText: true, initialWidth: 100},
        { label: 'Reversion User Code', fieldName: 'reversionUserCode',  wrapText: true, initialWidth: 100},
        { label: 'Reversion Time', fieldName: 'reversionTime',  wrapText: true, initialWidth: 100},
        { label: 'Has Issued Notice', fieldName: 'hasIssuedNotice',  wrapText: true, initialWidth: 100},
        { label: 'Parent Transaction Description', fieldName: 'parentTransaction.transactionDescription',  wrapText: true, initialWidth: 100},
        { label: 'Transaction Description', fieldName: 'transaction.transactionDescription',  wrapText: true, initialWidth: 100},
        { label: 'Document Number', fieldName: 'documentNumber',  wrapText: true, initialWidth: 100},
        { label: 'Document Number 2', fieldName: 'documentNumber2',  wrapText: true, initialWidth: 100},
        { label: 'Document Number 3', fieldName: 'documentNumber3',  wrapText: true, initialWidth: 100},
        { label: 'Document Number 4', fieldName: 'documentNumber4',  wrapText: true, initialWidth: 100},
        { label: 'Is Protected', fieldName: 'isProtected', wrapText: true, initialWidth: 100 }
    ];*/
    savingsColumns = [
        { label: 'Estado', fieldName: 'status', wrapText: true, initialWidth: 100 },
        { label: 'Tipo Movimiento', fieldName: 'movementType', wrapText: false, initialWidth: 150 },
        { label: 'Fecha Movimiento', fieldName: 'movementDate', wrapText: false, initialWidth: 200 },
        { label: 'Concepto', fieldName: 'concept', wrapText: true, initialWidth: 100 },
        { label: 'Cantidad', fieldName: 'amount', wrapText: true, initialWidth: 100 }
    ];

    loanColumns = [
        { label: 'Estado', fieldName: 'status', wrapText: true, initialWidth: 100 },
        { label: 'Numero de Cuota', fieldName: 'installmentNumber', wrapText: false, initialWidth: 150 },
        { label: 'Fecha Expiracion', fieldName: 'expirationDate', wrapText: false, initialWidth: 200 },
        { label: 'Días de Mora Desc ', fieldName: 'daysPastDueDesc', wrapText: true, initialWidth: 100 },
        { label: 'Cantidad', fieldName: 'amount', wrapText: true, initialWidth: 100 },
        { label: 'Saldo interes', fieldName: '', wrapText: true, initialWidth: 100 },
        { label: 'Ultimo pago Días', fieldName: 'paymentDate', wrapText: true, initialWidth: 100 }


    ];

    @track previousSelectedSaving = null;


    handleMovementsSavings() {
        if (this.recentSavingMovements) {
            this.recentSavingMovements = null;
            return;
        }
        //this.recentSavingMovements = this.genericMovementsMockup;
        this.previousSelectedSaving = this.selectedSavingDetailNumber;
        this.fetchMovements(this.previousSelectedSaving, false, false);
        this.selectedSavingDetailNumber = null;
    }

    handleReturnSavings() {
        if (this.recentSavingMovements) {
            this.recentSavingMovements = null;
        }
        this.selectedSavingDetailNumber = this.previousSelectedSaving;
        this.movementsFound = true;
    }


    handlePrevioSavings() {
        this.fetchMovements(this.previousSelectedSaving, false, true);
        this.movementsFound = true;
    }

    handleSiguienteSavings() {
        this.fetchMovements(this.previousSelectedSaving, true, false);
        this.movementsFound = true;
    }

}