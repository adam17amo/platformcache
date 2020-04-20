// opportunitiesOverAmount.js
 /* eslint-disable no-console */
 /* eslint-disable @lwc/lwc/no-async-operation */
import { LightningElement, track, wire } from 'lwc';
import { refreshApex } from '@salesforce/apex';
import getAccountOverRevenue from '@salesforce/apex/AccountsOverAmountApex.getAccountOverRevenue';
import updateOpptyStage from '@salesforce/apex/AccountsOverAmountApex.updateOpptyStage';

/** The delay used when debouncing event handlers before invoking Apex. */
const DELAY = 300;

export default class AccountsOverAmount extends LightningElement {
    //@api amount = 999999;
    @track amount = '';
    startTime = new Date().getTime();
    endTime = 0;

    @wire(getAccountOverRevenue, { amount: '$amount' })
    accountsOverAmount;

    constructor() {
        super();
        //this.startTime = new Date().getTime();
        console.log('Start time in constructor is ' + this.startTime);
    }

    connectedCallback() {
        this.endTime = new Date().getTime();
        console.log('End time in callback is ' + this.endTime);
        console.log('Total time is ' + (this.endTime-this.startTime));
    }

    renderedCallback() {
        this.endTime = new Date().getTime();
        console.log('End time in renderedCallback is ' + this.endTime);
        console.log('Total time from render is ' + (this.endTime-this.startTime-DELAY));
    }

    handleAmountChange(event) {
        // Debouncing this method: Do not update the reactive property as long as this function is
        // being called within a delay of DELAY. This is to avoid a very large number of Apex method calls.
        this.startTime = new Date().getTime();
        console.log('*********AMOUNT CHANGED at ' + this.startTime);
    
        window.clearTimeout(this.delayTimeout);
        const amount = event.target.value;
        this.delayTimeout = setTimeout(() => {
            this.amount = amount;
        }, DELAY);
    }

    handleClick() {
        this.startTime = new Date().getTime();
        console.log('Start time in handleClick ' + this.startTime);
        updateOpptyStage({
            amount: this.amount,
            stage: 'Closed Won'
        })
        .then(() => {
            return refreshApex(this.accountsOverAmount);
        })
        .catch((error) => {
            this.message = 'Error received: code' + error.errorCode + ', ' +
                'message ' + error.body.message;
        });
        this.endTime = new Date().getTime();
        console.log('End time in handleClick is ' + this.endTime);
        console.log('Difference is ' + (this.endTime-this.startTime));
    }
}