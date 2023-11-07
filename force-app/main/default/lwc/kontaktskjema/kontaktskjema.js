import { LightningElement, api, track } from 'lwc';
import { loadStyle } from 'lightning/platformResourceLoader';
import kontaktsjemaBilde from '@salesforce/resourceUrl/KontaktskjemaLogo';
import index from '@salesforce/resourceUrl/index';

export default class Kontaktskjema extends LightningElement {
    bildeKontaktskjema = kontaktsjemaBilde;
    //PhoneNumber;

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
        const inputField = event.target;
        const isOrgNumberValid = inputField.validateOrgNumber(this.errorText);

        if (!isOrgNumberValid) {
            inputField.sendErrorMessage(this.errorText);
        }
        inputField.blur();

    }

    handlePhoneBlur(event) {
        const inputFieldPhone = event.target;
        const isPhoneValid = inputFieldPhone.validatePhoneLength(this.errorText);

        if (!isPhoneValid) {
            inputFieldPhone.sendErrorMessage(this.errorText);
        }
        inputFieldPhone.blur();

    }
/*
    handleEmptyField(event) {
        const inputVariousField = event.target.value;
        console.log(toString(inputVariousField));
        if (inputVariousField === '') {
            inputVariousField.sendErrorMessage(this.errorText);
        }
    }*/
}