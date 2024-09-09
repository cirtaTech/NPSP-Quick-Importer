import { LightningElement, api } from 'lwc';

export default class CirtaTechHeader extends LightningElement {
    @api iconName; // icon name passed from flow (e.g., "utility:upload")
    @api titleText; // title text passed from flow
    @api logoLink;  // hyperlink for the logo
}