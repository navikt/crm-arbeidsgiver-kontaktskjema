import { LightningElement, api, track } from 'lwc';
import { loadStyle } from 'lightning/platformResourceLoader';
import kontaktsjemaBilde from '@salesforce/resourceUrl/KontaktskjemaLogo';
import index from '@salesforce/resourceUrl/index';

export default class Kontaktskjema extends LightningElement {
    bildeKontaktskjema = kontaktsjemaBilde;

    @track selectedTheme = '';
    @track selectedContactedEmployeeRep = '';
    @track checkedRekruttere = false;
    @track checkedForebygge = false;
    @track checkedYesOrNo = false;

    @track fieldValues = { 
        FullName: '',
        OrganizationNumber: '',
        Email: '',
        Phone: ''

    }

    @track breadcrumbs = [
        {
            label: 'nav.no',
            href: ''
        },
        {
            label: 'Arbeidsgiver',
            href: 'mine-samtaler'
        },
        {
            label: 'Kontakt NAV',
            href: 'detail'
        },
        {
            label: 'Kontaktskjema',
            href: 'detail'
        }
    ];

    themeOptions = [
        { label: 'Rekruttere og inkludere', value: 'Rekruttere og inkludere', name: 'theme', checked: false},
        { label: 'Forebygge sykefravær', value: 'Forebygge sykefravær', name: 'theme', checked: false}
    ];

    contactedEmployeeRepOptions = [
        { label: 'Ja', value: 'Ja', name: 'contactedEmpRep', checked: false },
        { label: 'Nei', value: 'Nei', name: 'contactedEmpRep', checked: false }
    ];

    static delegatesFocus = true;

    handleTheme(event) {
        console.log('theme test: ');
        this.selectedTheme = event.detail;

        if (this.selectedTheme[0].checked === true) {
            this.checkedRekruttere = true;
            this.checkedForebygge = false;
        } else if (this.selectedTheme[1].checked === true) {
            this.checkedRekruttere = false;
            this.checkedForebygge = true;
        } else {
            this.checkedRekruttere = false;
            this.checkedForebygge = false;
        }
    }

    handleContactedEmployeeRep(event) {
        console.log('yes or no test: ');
        this.selectedContactedEmployeeRep = event.detail;

        if (selectedContactedEmployeeRep[0].checked === true) {
            this.checkedYesOrNo = true;
        } else {
            this.checkedYesOrNo = false;
        }
    }

    renderedCallback() {
        loadStyle(this, index);
    }

    handleResize() {
        const img = this.template.querySelector('[data-id="imageBanner"]');
        if (window.innerWidth < 800) {
            img.style.display = 'none';
        } else {
            img.style.display = 'flex';
        }
    }

    connectedCallback() {
        window.addEventListener('resize', this.handleResize.bind(this));
       // this.PhoneNumber = this.template.querySelector('#PhoneNumber');
    }

  

    disconnectedCallback() {
        window.removeEventListener('resize', this.handleResize.bind(this));
    }

    handleOrgNumberBlur(event) {
        //const inputValue = event.target.value;
        //var nameField = this.template.querySelector('[data-id="nameField"]');
        //nameField.focus();
        //var currcounter = 0;
        //currcounter = this.counter;
            
        const inputField = event.target;
        const isOrgNumberValid = inputField.validateOrgNumber(this.errorText);
        //event.preventDefault();
        //event.stopPropagation();

        /* if (!isOrgNumberValid) {
            // inputField.sendErrorMessage(this.errorText);
            //currcounter++;
            //console.log("The current counter is:"+currcounter);
            //this.counter = this.currcounter;
            //console.log("The current counter is:"+this.counter);
            //this.template.querySelector('name').focus();
            //var nameField = this.template.querySelector('[data-id="nameField"]');
            //nameField.focus();
            } */
        //this.inputField.focusOut();
        

    }

    handlePhoneBlur(event) {
        const inputFieldPhone = event.target;
        const isPhoneValid = inputFieldPhone.validatePhoneLength(this.errorText);

        if (!isPhoneValid) {
            inputFieldPhone.sendErrorMessage(this.errorText);
        }
        inputFieldPhone.blur();

    }

    handleEmptyField(event) {
        const inputVariousField = event.target;
        console.log("Input is : "+inputVariousField.value);
        if (inputVariousField.value == '' || inputVariousField.value == null || inputVariousField.value.length < 1) {
            console.log("Send message is called");
            console.log(inputVariousField.errorText);
            inputVariousField.sendErrorMessage(inputVariousField.errorText);
        }
    }

    handleEmailField(event) {
        const inputEmailField = event.target;
        let regExp = RegExp(/^(([^<>()[\]\\.,;:\s@"]+(\.[^<>()[\]\\.,;:\s@"]+)*)|.(".+"))@((\[[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\])|(([a-zA-Z\-0-9]+\.)+[a-zA-Z]{2,}))$/);
        let isValidEmail = regExp.test(inputEmailField.value) ? true : false;
        if (!isValidEmail || inputEmailField.value == '' || inputEmailField.value == null || inputEmailField.value.length < 1) {
            console.log("Send message is called");
            console.log(inputEmailField.errorText);
            inputEmailField.sendErrorMessage(inputEmailField.errorText);
        }
    }
}