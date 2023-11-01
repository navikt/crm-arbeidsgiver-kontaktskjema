import { LightningElement, api, track } from 'lwc';
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
    }

    disconnectedCallback() {
        window.removeEventListener('resize', this.handleResize.bind(this));
    }

}