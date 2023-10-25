import { LightningElement, api, track } from 'lwc';

export default class TextFieldForm extends LightningElement {
    @api label;
    @api description;
    @api error;
    @api size;
    @api value = '';
    @api placeholder;
    @api htmlSize;
    @api readOnly;
    @api type;

    fieldId = 'text-field-id'; // You can generate a unique ID dynamically if needed
    inputDescriptionId = 'text-field-description-id'; // You can generate a unique ID dynamically if needed

    @track hasError = false;

    get computedClass() {
        // Compute your classes dynamically based on conditions
        // Example: 
        return `slds-form-element ${this.hasError ? 'slds-has-error' : ''}`;
    }

    get labelClass() {
        // Compute label classes if needed
        // Example:
        return 'slds-form-element__label';
    }

    get descriptionClass() {
        // Compute description classes if needed
        // Example:
        return 'slds-form-element__help';
    }

    get inputClass() {
        // Compute input classes if needed
        // Example:
        return 'navds-text-field__input navds-text-field__input:hover';
    }

    handleInputChange(event) {
        this.value = event.target.value;
        // Add any additional logic when input changes if needed
    }
}