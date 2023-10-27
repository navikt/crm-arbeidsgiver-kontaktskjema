import { LightningElement, track } from 'lwc';
import { loadStyle } from 'lightning/platformResourceLoader';
import kontaktsjemaBilde from '@salesforce/resourceUrl/KontaktskjemaLogo';
import index from '@salesforce/resourceUrl/index';

export default class Kontaktskjema extends LightningElement {
    bildeKontaktskjema = kontaktsjemaBilde;

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

    renderedCallback() {
        loadStyle(this, index);
    }
}