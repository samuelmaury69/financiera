import { LightningElement, track, api } from 'lwc';
import getAccount from '@salesforce/apex/ProductsController.getAccount';
import getProductJsonSavingsCallout from '@salesforce/apexContinuation/ProductsCalloutsServicesUtil.productJsonSavingsCallout';

export default class Productslwc extends LightningElement {
    @api recordId;
    @api producttype;
    @api personCode;

    @track showMovimientos = false;   
    @track personCode = false;

    @api savingsresponse = [];
    @api checkingsresponse = [];
    @api cardsresponse = [];
    @api loansresponse = [];

    @track mockupData = true;

    @track isLoading = false;

    // DONE: Get from controller, when webservices are OK
    @track savingsMockup = '[{"totalAmount":"","status":"NORMAL","statementClosingDate":"","state":"","salary":"","personCode":"","pendingDebt":"","name":"","moreDetails":{"userCode":"","unemploymentInsurance":"","type":"","trialEntityCode":"","trialDate":"","transactionCostOthersATM":"","transactionCostATM":"","totalFees":"","totalDebt":"","tas":"","statusChangeDate":"31-12-2022 9:00 PM","startDate":"","signatureRegistered":"","retainedBalance":"0 GS","requiredSignaturesQty":"","requestNumber":"","renewal":"","registeredSignatureQty":"","rateValue":"","rateCode":"TASA AHORROS","promoterUserCode":"","productId":"","processDate":"","pendingFees":"","pendingDebitsAmount":"","pendingCreditsAmount":"","pendingConfirmationCreditsAmount":"","payoffAmount":"","paymentTypeAutomaticDebit":"","outlayAmount":"","originOfficeCode":"","openingDate":"31-12-2020 9:00 PM","openingAmount":"","officeCode":"CASA MATRIZ","monthPaymentAmount":"","minimumPay":"","loanType":"","loanInterestEarned":"","lastTotalAmountPaid":"","lastPaymentDate":"","lastPayment":"","lastMovementDate":"","lastExtractDate":"","lastExtractBalance":"","lastATMMovementDate":"","isOnTrial":"","isCombinedAccount":"","interestRate":"","holder":"","hasPendingAuthorization":"","hasAutomaticDebit":"","globalAccountNumber":"","freeTransactionATM":"","financingRate":"","feesPaid":"","feesDue":"","feeAmount":"","extractExpirationDate":"","expiredAmount":"","entityCode":"","emissionNumber":"","earlyCancellationCharges":"","dueDate":"","denomination":"XXXX XXXX XXXX XXXX","debtCancellationInsurance":"","daysPastDue":"","creditLineUsed":"","creditLine":"","closingDebt":"","checkbookName":"","channelCode":"","cashBack":"","cardNumber":"","cardColor":"","capitalBalance":"","cancellationDate":"","cancellationCodeCause":"","campaignCode":"","burialInsurance":"","blockedBalance":"0 GS","binNumber":"","batchStatus":"","availableCreditLine":"","alias":"","affinity":"","administrativeCommission":"","adherent":"","activationDate":"","accountNumber":""},"modality":"","message":"","loanEffectiveDate":"","isError":"","isCredit":"","isActive":"","expirationDate":"","dueDate":"","creditLineUsed":"","creditLine":"","cardType":"","cardNumber":"","balance":"100 GS","accountNumber":"969000015"},{"totalAmount":"","status":"NORMAL","statementClosingDate":"","state":"","salary":"","personCode":"","pendingDebt":"","name":"","moreDetails":{"userCode":"","unemploymentInsurance":"","type":"","trialEntityCode":"","trialDate":"","transactionCostOthersATM":"","transactionCostATM":"","totalFees":"","totalDebt":"","tas":"","statusChangeDate":"31-12-2021 9:00 PM","startDate":"","signatureRegistered":"","retainedBalance":"0 GS","requiredSignaturesQty":"","requestNumber":"","renewal":"","registeredSignatureQty":"","rateValue":"","rateCode":"TASA AHORROS","promoterUserCode":"","productId":"","processDate":"","pendingFees":"","pendingDebitsAmount":"","pendingCreditsAmount":"","pendingConfirmationCreditsAmount":"","payoffAmount":"","paymentTypeAutomaticDebit":"","outlayAmount":"","originOfficeCode":"","openingDate":"31-12-2020 9:00 PM","openingAmount":"","officeCode":"CASA MATRIZ","monthPaymentAmount":"","minimumPay":"","loanType":"","loanInterestEarned":"","lastTotalAmountPaid":"","lastPaymentDate":"","lastPayment":"","lastMovementDate":"","lastExtractDate":"","lastExtractBalance":"","lastATMMovementDate":"","isOnTrial":"","isCombinedAccount":"","interestRate":"","holder":"","hasPendingAuthorization":"","hasAutomaticDebit":"","globalAccountNumber":"","freeTransactionATM":"","financingRate":"","feesPaid":"","feesDue":"","feeAmount":"","extractExpirationDate":"","expiredAmount":"","entityCode":"","emissionNumber":"","earlyCancellationCharges":"","dueDate":"","denomination":"XXXX XXXX XXXX XXXX","debtCancellationInsurance":"","daysPastDue":"","creditLineUsed":"","creditLine":"","closingDebt":"","checkbookName":"","channelCode":"","cashBack":"","cardNumber":"","cardColor":"","capitalBalance":"","cancellationDate":"","cancellationCodeCause":"","campaignCode":"","burialInsurance":"","blockedBalance":"0 GS","binNumber":"","batchStatus":"","availableCreditLine":"","alias":"","affinity":"","administrativeCommission":"","adherent":"","activationDate":"","accountNumber":""},"modality":"","message":"","loanEffectiveDate":"","isError":"","isCredit":"","isActive":"","expirationDate":"","dueDate":"","creditLineUsed":"","creditLine":"","cardType":"","cardNumber":"","balance":"853038 GS","accountNumber":"96911832"}]';


   @track cardsMockup = '[{"totalAmount":"","status":"S","statementClosingDate":"","state":"","salary":"","personCode":"164082","pendingDebt":"","name":"XXXX XXXX XXXX XXXX","moreDetails":{"userCode":"APITRANSAC","unemploymentInsurance":"","type":"","trialEntityCode":"","trialDate":"","transactionCostOthersATM":"","transactionCostATM":"","totalFees":"","totalDebt":"","tas":"","statusChangeDate":"","startDate":"","signatureRegistered":"","retainedBalance":"","requiredSignaturesQty":"","requestNumber":"","renewal":"","registeredSignatureQty":"","rateValue":"","rateCode":"","promoterUserCode":"","productId":"","processDate":"","pendingFees":"","pendingDebitsAmount":"","pendingCreditsAmount":"","pendingConfirmationCreditsAmount":"","payoffAmount":"","paymentTypeAutomaticDebit":"","outlayAmount":"","originOfficeCode":"1","openingDate":"","openingAmount":"","officeCode":"","monthPaymentAmount":"","minimumPay":"","loanType":"","loanInterestEarned":"","lastTotalAmountPaid":"","lastPaymentDate":"","lastPayment":"","lastMovementDate":"","lastExtractDate":"","lastExtractBalance":"","lastATMMovementDate":"","isOnTrial":"","isCombinedAccount":"","interestRate":"","holder":"","hasPendingAuthorization":"","hasAutomaticDebit":"","globalAccountNumber":"13985184","freeTransactionATM":"","financingRate":"","feesPaid":"","feesDue":"","feeAmount":"","extractExpirationDate":"","expiredAmount":"","entityCode":"","emissionNumber":"02","earlyCancellationCharges":"","dueDate":"","denomination":"","debtCancellationInsurance":"","daysPastDue":"","creditLineUsed":"","creditLine":"","closingDebt":"","checkbookName":"","channelCode":"","cashBack":"","cardNumber":"4179994638474179","cardColor":"","capitalBalance":"","cancellationDate":"","cancellationCodeCause":"","campaignCode":"","burialInsurance":"","blockedBalance":"","binNumber":"558549","batchStatus":"","availableCreditLine":"","alias":"","affinity":"","administrativeCommission":"","adherent":"00","activationDate":"31-12-2021 9:00 PM","accountNumber":""},"modality":"","message":"","loanEffectiveDate":"","isError":"","isCredit":"false","isActive":"","expirationDate":"","dueDate":"31-12-2026 9:00 PM","creditLineUsed":"","creditLine":"","cardType":"MF","cardNumber":"","balance":"","accountNumber":"96911832"},{"totalAmount":"","status":"N","statementClosingDate":"","state":"","salary":"","personCode":"164082","pendingDebt":"","name":"XXXX XXXX XXXX XXXX","moreDetails":{"userCode":"GBACUNA","unemploymentInsurance":"","type":"","trialEntityCode":"","trialDate":"","transactionCostOthersATM":"","transactionCostATM":"","totalFees":"","totalDebt":"","tas":"","statusChangeDate":"","startDate":"","signatureRegistered":"","retainedBalance":"","requiredSignaturesQty":"","requestNumber":"","renewal":"N","registeredSignatureQty":"","rateValue":"","rateCode":"","promoterUserCode":"","productId":"","processDate":"","pendingFees":"","pendingDebitsAmount":"","pendingCreditsAmount":"","pendingConfirmationCreditsAmount":"","payoffAmount":"","paymentTypeAutomaticDebit":"","outlayAmount":"","originOfficeCode":"61","openingDate":"","openingAmount":"","officeCode":"","monthPaymentAmount":"","minimumPay":"","loanType":"","loanInterestEarned":"","lastTotalAmountPaid":"","lastPaymentDate":"","lastPayment":"","lastMovementDate":"","lastExtractDate":"","lastExtractBalance":"","lastATMMovementDate":"","isOnTrial":"","isCombinedAccount":"","interestRate":"","holder":"","hasPendingAuthorization":"","hasAutomaticDebit":"","globalAccountNumber":"","freeTransactionATM":"","financingRate":"","feesPaid":"","feesDue":"","feeAmount":"","extractExpirationDate":"","expiredAmount":"","entityCode":"","emissionNumber":"01","earlyCancellationCharges":"","dueDate":"","denomination":"","debtCancellationInsurance":"","daysPastDue":"","creditLineUsed":"","creditLine":"","closingDebt":"","checkbookName":"","channelCode":"","cashBack":"","cardNumber":"","cardColor":"","capitalBalance":"","cancellationDate":"","cancellationCodeCause":"","campaignCode":"","burialInsurance":"","blockedBalance":"","binNumber":"600691","batchStatus":"","availableCreditLine":"","alias":"","affinity":"","administrativeCommission":"","adherent":"00","activationDate":"","accountNumber":""},"modality":"","message":"","loanEffectiveDate":"","isError":"","isCredit":"false","isActive":"","expirationDate":"","dueDate":"31-12-2027 9:00 PM","creditLineUsed":"","creditLine":"","cardType":"C","cardNumber":"","balance":"","accountNumber":"6144927"},{"totalAmount":"","status":"Activa","statementClosingDate":"31-12-2023 9:00 PM","state":"","salary":"","personCode":"","pendingDebt":"","name":"","moreDetails":{"userCode":"","unemploymentInsurance":"","type":"","trialEntityCode":"","trialDate":"","transactionCostOthersATM":"0","transactionCostATM":"0 GS","totalFees":"","totalDebt":"450764 GS","tas":"","statusChangeDate":"","startDate":"","signatureRegistered":"","retainedBalance":"","requiredSignaturesQty":"","requestNumber":"","renewal":"","registeredSignatureQty":"","rateValue":"","rateCode":"","promoterUserCode":"","productId":"","processDate":"31-12-2023 9:00 PM","pendingFees":"","pendingDebitsAmount":"","pendingCreditsAmount":"","pendingConfirmationCreditsAmount":"","payoffAmount":"","paymentTypeAutomaticDebit":"T","outlayAmount":"","originOfficeCode":"","openingDate":"","openingAmount":"","officeCode":"","monthPaymentAmount":"1492813 GS","minimumPay":"93118 GS","loanType":"","loanInterestEarned":"","lastTotalAmountPaid":"","lastPaymentDate":"31-12-2023 9:00 PM","lastPayment":"1 GS","lastMovementDate":"","lastExtractDate":"","lastExtractBalance":"","lastATMMovementDate":"","isOnTrial":"","isCombinedAccount":"","interestRate":"15.41%","holder":"XXXX XXXX XXXX XXXX","hasPendingAuthorization":"","hasAutomaticDebit":"S","globalAccountNumber":"","freeTransactionATM":"0 GS","financingRate":"15.42","feesPaid":"","feesDue":"","feeAmount":"","extractExpirationDate":"31-12-2023 9:00 PM","expiredAmount":"","entityCode":"","emissionNumber":"","earlyCancellationCharges":"","dueDate":"","denomination":"","debtCancellationInsurance":"","daysPastDue":"","creditLineUsed":"","creditLine":"","closingDebt":"1492812 GS","checkbookName":"","channelCode":"","cashBack":"0 GS","cardNumber":"","cardColor":"Red","capitalBalance":"","cancellationDate":"","cancellationCodeCause":"","campaignCode":"","burialInsurance":"","blockedBalance":"","binNumber":"","batchStatus":"","availableCreditLine":"1049236 GS","alias":"","affinity":"Mastercard GP","administrativeCommission":"","adherent":"","activationDate":"","accountNumber":"15146197"},"modality":"","message":"","loanEffectiveDate":"","isError":"","isCredit":"true","isActive":"","expirationDate":"31-12-2027 9:00 PM","dueDate":"","creditLineUsed":"450764","creditLine":"1500000","cardType":"CRÉDITO FÍSICA","cardNumber":"1962999999431962","balance":"","accountNumber":"15146197"},{"totalAmount":"","status":"Proceso ","statementClosingDate":"","state":"","salary":"","personCode":"","pendingDebt":"","name":"","moreDetails":{"userCode":"","unemploymentInsurance":"","type":"","trialEntityCode":"","trialDate":"","transactionCostOthersATM":"","transactionCostATM":"","totalFees":"","totalDebt":"","tas":"","statusChangeDate":"","startDate":"","signatureRegistered":"","retainedBalance":"","requiredSignaturesQty":"","requestNumber":"","renewal":"","registeredSignatureQty":"","rateValue":"","rateCode":"","promoterUserCode":"","productId":"","processDate":"31-12-2023 9:00 PM","pendingFees":"","pendingDebitsAmount":"","pendingCreditsAmount":"","pendingConfirmationCreditsAmount":"","payoffAmount":"","paymentTypeAutomaticDebit":"","outlayAmount":"","originOfficeCode":"","openingDate":"","openingAmount":"","officeCode":"","monthPaymentAmount":"","minimumPay":"","loanType":"","loanInterestEarned":"","lastTotalAmountPaid":"","lastPaymentDate":"","lastPayment":"","lastMovementDate":"","lastExtractDate":"","lastExtractBalance":"","lastATMMovementDate":"","isOnTrial":"","isCombinedAccount":"","interestRate":"","holder":"","hasPendingAuthorization":"","hasAutomaticDebit":"","globalAccountNumber":"","freeTransactionATM":"","financingRate":"","feesPaid":"","feesDue":"","feeAmount":"","extractExpirationDate":"","expiredAmount":"","entityCode":"","emissionNumber":"","earlyCancellationCharges":"","dueDate":"","denomination":"","debtCancellationInsurance":"","daysPastDue":"","creditLineUsed":"","creditLine":"","closingDebt":"","checkbookName":"","channelCode":"","cashBack":"","cardNumber":"","cardColor":"","capitalBalance":"","cancellationDate":"","cancellationCodeCause":"","campaignCode":"","burialInsurance":"","blockedBalance":"","binNumber":"","batchStatus":"","availableCreditLine":"","alias":"","affinity":"","administrativeCommission":"","adherent":"","activationDate":"","accountNumber":""},"modality":"","message":"","loanEffectiveDate":"","isError":"","isCredit":"true","isActive":"","expirationDate":"31-12-2027 9:00 PM","dueDate":"","creditLineUsed":"","creditLine":"","cardType":"","cardNumber":"","balance":"","accountNumber":""},{"totalAmount":"","status":"N","statementClosingDate":"","state":"","salary":"","personCode":"164082","pendingDebt":"","name":"XXXX XXXX XXXX XXXX","moreDetails":{"userCode":"GBACUNA","unemploymentInsurance":"","type":"","trialEntityCode":"","trialDate":"","transactionCostOthersATM":"","transactionCostATM":"","totalFees":"","totalDebt":"","tas":"","statusChangeDate":"","startDate":"","signatureRegistered":"","retainedBalance":"","requiredSignaturesQty":"","requestNumber":"","renewal":"N","registeredSignatureQty":"","rateValue":"","rateCode":"","promoterUserCode":"","productId":"","processDate":"","pendingFees":"","pendingDebitsAmount":"","pendingCreditsAmount":"","pendingConfirmationCreditsAmount":"","payoffAmount":"","paymentTypeAutomaticDebit":"","outlayAmount":"","originOfficeCode":"61","openingDate":"","openingAmount":"","officeCode":"","monthPaymentAmount":"","minimumPay":"","loanType":"","loanInterestEarned":"","lastTotalAmountPaid":"","lastPaymentDate":"","lastPayment":"","lastMovementDate":"","lastExtractDate":"","lastExtractBalance":"","lastATMMovementDate":"","isOnTrial":"","isCombinedAccount":"","interestRate":"","holder":"","hasPendingAuthorization":"","hasAutomaticDebit":"","globalAccountNumber":"","freeTransactionATM":"","financingRate":"","feesPaid":"","feesDue":"","feeAmount":"","extractExpirationDate":"","expiredAmount":"","entityCode":"","emissionNumber":"01","earlyCancellationCharges":"","dueDate":"","denomination":"","debtCancellationInsurance":"","daysPastDue":"","creditLineUsed":"","creditLine":"","closingDebt":"","checkbookName":"","channelCode":"","cashBack":"","cardNumber":"","cardColor":"","capitalBalance":"","cancellationDate":"","cancellationCodeCause":"","campaignCode":"","burialInsurance":"","blockedBalance":"","binNumber":"600691","batchStatus":"","availableCreditLine":"","alias":"","affinity":"","administrativeCommission":"","adherent":"00","activationDate":"","accountNumber":""},"modality":"","message":"","loanEffectiveDate":"","isError":"","isCredit":"false","isActive":"","expirationDate":"","dueDate":"31-12-2027 9:00 PM","creditLineUsed":"","creditLine":"","cardType":"C","cardNumber":"","balance":"","accountNumber":"6144927"}]'

    @track loansMockup = '[{"totalAmount":"41018164 GS","status":"VIGENTE","statementClosingDate":"","state":"","salary":"","personCode":"","pendingDebt":"9458260 GS","name":"","moreDetails":{"userCode":"","unemploymentInsurance":"0 GS","type":"Consumo","trialEntityCode":"","trialDate":"","transactionCostOthersATM":"","transactionCostATM":"","totalFees":"24 GS","totalDebt":"","tas":"10","statusChangeDate":"","startDate":"31-12-2021 9:00 PM","signatureRegistered":"","retainedBalance":"","requiredSignaturesQty":"","requestNumber":"458338","renewal":"","registeredSignatureQty":"","rateValue":"","rateCode":"","promoterUserCode":"","productId":"","processDate":"","pendingFees":"5 GS","pendingDebitsAmount":"","pendingCreditsAmount":"","pendingConfirmationCreditsAmount":"","payoffAmount":"9221100 GS","paymentTypeAutomaticDebit":"","outlayAmount":"40000000 GS","originOfficeCode":"","openingDate":"","openingAmount":"","officeCode":"","monthPaymentAmount":"","minimumPay":"","loanType":"PRESTAMOS A FUNCIONARIOS","loanInterestEarned":"215600 GS","lastTotalAmountPaid":"0 GS","lastPaymentDate":"31-12-2023 9:00 PM","lastPayment":"","lastMovementDate":"","lastExtractDate":"","lastExtractBalance":"","lastATMMovementDate":"","isOnTrial":"","isCombinedAccount":"","interestRate":"","holder":"","hasPendingAuthorization":"","hasAutomaticDebit":"","globalAccountNumber":"","freeTransactionATM":"","financingRate":"","feesPaid":"19 GS","feesDue":"null GS","feeAmount":"1891660 GS","extractExpirationDate":"","expiredAmount":"1891660 GS","entityCode":"","emissionNumber":"","earlyCancellationCharges":"1018164 GS","dueDate":"","denomination":"","debtCancellationInsurance":"0 GS","daysPastDue":"0","creditLineUsed":"","creditLine":"","closingDebt":"","checkbookName":"","channelCode":"","cashBack":"","cardNumber":"","cardColor":"","capitalBalance":"9225962 GS","cancellationDate":"","cancellationCodeCause":"","campaignCode":"","burialInsurance":"0 GS","blockedBalance":"","binNumber":"","batchStatus":"","availableCreditLine":"","alias":"Prestamo","affinity":"","administrativeCommission":"0 GS","adherent":"","activationDate":"","accountNumber":""},"modality":"PRESTAMOS A FUNCIONARIOS","message":"","loanEffectiveDate":"31-12-2022 9:00 PM","isError":"","isCredit":"","isActive":"","expirationDate":"","dueDate":"","creditLineUsed":"","creditLine":"","cardType":"","cardNumber":"","balance":"","accountNumber":"61226000079"}]';

    @track checkingMockup = '[{"totalAmount":"","status":"NORMAL","statementClosingDate":"","state":"","salary":"0 GS","personCode":"","pendingDebt":"","name":"","moreDetails":{"userCode":"","unemploymentInsurance":"","type":"","trialEntityCode":"","trialDate":"","transactionCostOthersATM":"","transactionCostATM":"","totalFees":"","totalDebt":"","tas":"","statusChangeDate":"31-12-2022 9:00 PM","startDate":"","signatureRegistered":"XXXX XXXX XXXX XXXX","retainedBalance":"","requiredSignaturesQty":"1","requestNumber":"","renewal":"","registeredSignatureQty":"1","rateValue":"","rateCode":"","promoterUserCode":"","productId":"","processDate":"","pendingFees":"","pendingDebitsAmount":"0 GS","pendingCreditsAmount":"0 GS","pendingConfirmationCreditsAmount":"0 GS","payoffAmount":"","paymentTypeAutomaticDebit":"","outlayAmount":"","originOfficeCode":"","openingDate":"31-12-2022 9:00 PM","openingAmount":"0 GS","officeCode":"61","monthPaymentAmount":"","minimumPay":"","loanType":"","loanInterestEarned":"","lastTotalAmountPaid":"","lastPaymentDate":"","lastPayment":"","lastMovementDate":"31-12-2023 9:00 PM","lastExtractDate":"","lastExtractBalance":"0 GS","lastATMMovementDate":"","isOnTrial":"N","isCombinedAccount":"false","interestRate":"","holder":"","hasPendingAuthorization":"false","hasAutomaticDebit":"","globalAccountNumber":"","freeTransactionATM":"","financingRate":"","feesPaid":"","feesDue":"","feeAmount":"","extractExpirationDate":"","expiredAmount":"","entityCode":"","emissionNumber":"","earlyCancellationCharges":"","dueDate":"","denomination":"XXXX XXXX XXXX XXXX","debtCancellationInsurance":"","daysPastDue":"","creditLineUsed":"","creditLine":"","closingDebt":"","checkbookName":"XXXX XXXX XXXX XXXX","channelCode":"","cashBack":"","cardNumber":"","cardColor":"","capitalBalance":"","cancellationDate":"","cancellationCodeCause":"","campaignCode":"","burialInsurance":"","blockedBalance":"","binNumber":"","batchStatus":"NORMAL","availableCreditLine":"","alias":"","affinity":"","administrativeCommission":"","adherent":"","activationDate":"","accountNumber":""},"modality":"","message":"","loanEffectiveDate":"","isError":"","isCredit":"","isActive":"","expirationDate":"","dueDate":"","creditLineUsed":"","creditLine":"","cardType":"","cardNumber":"","balance":"","accountNumber":"6144927"},{"totalAmount":"","status":"NORMAL","statementClosingDate":"","state":"","salary":"2.08 USD","personCode":"","pendingDebt":"","name":"","moreDetails":{"userCode":"","unemploymentInsurance":"","type":"","trialEntityCode":"","trialDate":"","transactionCostOthersATM":"","transactionCostATM":"","totalFees":"","totalDebt":"","tas":"","statusChangeDate":"31-12-2023 9:00 PM","startDate":"","signatureRegistered":"XXXX XXXX XXXX XXXX","retainedBalance":"","requiredSignaturesQty":"1","requestNumber":"","renewal":"","registeredSignatureQty":"1","rateValue":"","rateCode":"","promoterUserCode":"","productId":"","processDate":"","pendingFees":"","pendingDebitsAmount":"0 USD","pendingCreditsAmount":"0 USD","pendingConfirmationCreditsAmount":"0 USD","payoffAmount":"","paymentTypeAutomaticDebit":"","outlayAmount":"","originOfficeCode":"","openingDate":"31-12-2023 9:00 PM","openingAmount":"0 USD","officeCode":"61","monthPaymentAmount":"","minimumPay":"","loanType":"","loanInterestEarned":"","lastTotalAmountPaid":"","lastPaymentDate":"","lastPayment":"","lastMovementDate":"31-12-2023 9:00 PM","lastExtractDate":"","lastExtractBalance":"0 USD","lastATMMovementDate":"","isOnTrial":"N","isCombinedAccount":"false","interestRate":"","holder":"","hasPendingAuthorization":"false","hasAutomaticDebit":"","globalAccountNumber":"","freeTransactionATM":"","financingRate":"","feesPaid":"","feesDue":"","feeAmount":"","extractExpirationDate":"","expiredAmount":"","entityCode":"","emissionNumber":"","earlyCancellationCharges":"","dueDate":"","denomination":"XXXX XXXX XXXX XXXX","debtCancellationInsurance":"","daysPastDue":"","creditLineUsed":"","creditLine":"","closingDebt":"","checkbookName":"XXXX XXXX XXXX XXXX","channelCode":"","cashBack":"","cardNumber":"","cardColor":"","capitalBalance":"","cancellationDate":"","cancellationCodeCause":"","campaignCode":"","burialInsurance":"","blockedBalance":"","binNumber":"","batchStatus":"NORMAL","availableCreditLine":"","alias":"","affinity":"","administrativeCommission":"","adherent":"","activationDate":"","accountNumber":""},"modality":"","message":"","loanEffectiveDate":"","isError":"","isCredit":"","isActive":"","expirationDate":"","dueDate":"","creditLineUsed":"","creditLine":"","cardType":"","cardNumber":"","balance":"","accountNumber":"6145018"}]';
   
    // Gets fields from account, personCode
    retrieveAccountData(){
        getAccount({recordId : this.recordId})
        .then((result) => {
            console.log(result);        

          this.personCode = result?.PersonCode__c;
          console.log(this.personCode);
        }).catch((error) => {
            console.log(error);        
        });
    }
    @track activeValues = ['Normal', 'Abierto', 'Abierta', 'Activo', 'Activa', 'Vigente'];
    @track neutralValues = ['Bloqueado', 'Bloqueada', 'Proceso'];
    @track errorValues = ['Inactivo', 'Inactiva', 'Cancelado', 'Cancelada', 'Pendiente'];

    @track errorMessage = null;
    @track hasErrors = false;

    @track noResults = false;
    async fetchData(){
        console.log('0data📅');
        this.isLoading = true;
        const accResult = await(getAccount({recordId : this.recordId}));
        this.personCode = accResult?.PersonCode__c;
        console.log(this.personCode);
        const prodResult = await(getProductJsonSavingsCallout({personCode : this.personCode, productType : this.producttype}));
        console.log('prodResult', prodResult);

        if (prodResult == null){
            this.isLoading = false;
            this.noResults = true;
        }
        else{
            console.log('length', JSON.parse(prodResult).length);
            if (JSON.parse(prodResult).length == 0){
                this.isLoading = false;
                this.noResults = true;
            }
        }

        //console.log(prodResult.includes('Error'));

        /*if (prodResult.includes('Error')){
            this.errorMessage = prodResult;
            this.hasErrors = true;
            this.isLoading = false;
            return;
        }*/
        switch (this.producttype){
             case 'SAVINGS':
                 console.log('1SAVINGS🤷‍♀️');
                 this.savingsresponse = JSON.parse(prodResult);

                 console.log('1SAVINGS🤷‍♀️,', this.savingsresponse);

                    this.savingsresponse.forEach(saving => {

                        let statusLowerCase = saving.status.toLowerCase();
                        let isActive = this.activeValues.some(value => statusLowerCase.includes(value.toLowerCase()));
                        let isNeutral = this.neutralValues.some(value => statusLowerCase.includes(value.toLowerCase()));
                        let isError = this.errorValues.some(value => statusLowerCase.includes(value.toLowerCase()));
                        saving.isActive = isActive;
                        saving.isNeutral = isNeutral;
                        saving.isError = isError;

                        /*if (saving?.moreDetails?.denomination != null) {
                            saving.denomination = saving?.moreDetails?.denomination;
                            if (saving?.denomination?.length > 4){
                                saving.denominationShort = saving.denomination.slice(-4);
                            }
    
                        } */   
                        
                        saving.denominationShort = saving.denomination.slice(-4);
                        console.log('👍saving?.denominationShort', saving?.denominationShort);
                    });

                 break;            
             case 'CHECKINGS':
                 this.checkingsresponse = JSON.parse(prodResult);

                 this.checkingsresponse.forEach(checking => {
                    console.log(checking.status);
                   
                    let statusLowerCase = checking.status.toLowerCase();
                    let isActive = this.activeValues.some(value => statusLowerCase.includes(value.toLowerCase()));
                    let isNeutral = this.neutralValues.some(value => statusLowerCase.includes(value.toLowerCase()));
                    let isError = this.errorValues.some(value => statusLowerCase.includes(value.toLowerCase()));
                    checking.isActive = isActive;
                    checking.isNeutral = isNeutral;
                    checking.isError = isError;

                    checking.denominationShort = checking.denomination.slice(-4);
                    console.log('👍checking?.denominationShort', checking?.denominationShort);
                     
                });

                 console.log('2checkings✔👀');
                 console.log(this.checkingsresponse);
             break;
             case 'CREDIT_CARDS,DEBIT_CARDS':
                 this.cardsresponse = JSON.parse(prodResult);

                 this.cardsresponse.forEach(card => {
                    console.log(card.status);
                   
                    let statusLowerCase = card.status.toLowerCase();
                    let isActive = this.activeValues.some(value => statusLowerCase.includes(value.toLowerCase()));
                    let isNeutral = this.neutralValues.some(value => statusLowerCase.includes(value.toLowerCase()));
                    let isError = this.errorValues.some(value => statusLowerCase.includes(value.toLowerCase()));
                    card.isActive = isActive;
                    card.isNeutral = isNeutral;
                    card.isError = isError;   

                    if (!card.isActive && !card.isNeutral && !card.isError){
                        card.isActive = true;
                    }

                    card.cardNumberShort = card.cardNumber.slice(-4);
                    console.log('👍card?.cardNumberShort', card?.cardNumberShort);
                });


                 console.log('3card💳');
                 console.log(this.cardsresponse);
             break;
             case 'LOANS':
                 this.loansresponse = JSON.parse(prodResult);
                 
                 this.loansresponse.forEach(loan => {
                    console.log(loan.status);
                   
                    let statusLowerCase = loan.status.toLowerCase();
                    let isActive = this.activeValues.some(value => statusLowerCase.includes(value.toLowerCase()));
                    let isNeutral = this.neutralValues.some(value => statusLowerCase.includes(value.toLowerCase()));
                    let isError = this.errorValues.some(value => statusLowerCase.includes(value.toLowerCase()));
                    loan.isActive = isActive;
                    loan.isNeutral = isNeutral;
                    loan.isError = isError;               
                });


                 console.log('4loan🔃');
                 console.log(this.loansresponse);

             break;
         }
         this.isLoading = false;
    }

    connectedCallback() {   
        console.log(this.recordId);
        console.log(this.producttype);

        this.fetchData();
       
        /*this.savingsresponse = this.savingsMockup;
        this.checkingsresponse = this.checkingMockup;
        this.cardsresponse = this.cardsMockup;
        this.loansresponse = this.loansMockup; */             
    }
}