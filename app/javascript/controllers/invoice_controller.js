import { Controller } from "@hotwired/stimulus"
import { get, post, destroy } from "@rails/request.js"
import TomSelect from 'tom-select'
export default class extends Controller {
  static targets = ["lineitem", "taxAndDiscountPoly", "product"]

  connect() {
    let addEventHandler = () => (...args) => this.addLineItem(...args);
    let removeEventHandler = () => (...args) => this.removeLineItem(...args);
    new TomSelect("#product_id", {
      plugins: ['remove_button'],
      create: true,
      closeAfterSelect: true,
      onItemAdd: addEventHandler(),
      onItemRemove: removeEventHandler(),
      render:{
        option:function(data,escape){
          return '<div class="d-flex"><span>' + escape(data.text) + '</span></div>';
        },
        item:function(data,escape){
          return '<div>' + escape(data.text) + '</div>';
        }
      }
    });

    let addEventHandle = () => (...args) => this.addTaxAndDiscount(...args);
    let removeEventHandle = () => (...args) => this.removeTaxAndDiscount(...args);
    new TomSelect("#tax_and_discount",{
      plugins: ['remove_button'],
      create: true,
      closeAfterSelect: true,
      onItemAdd: addEventHandle(),
      onItemRemove: removeEventHandle(),
      render:{
        option:function(data,escape){
          return '<div class="d-flex"><span>' + escape(data.text) + '</span></div>';
        },
        item:function(data,escape){
          return '<div>' + escape(data.text) + '</div>';
        }
      }
    });
  }

  addTaxAndDiscount(id) {
    let taxAndDiscountId = id; 
    post(`/invoices/tax_and_discount_polies`, {
      body: JSON.stringify({taxAndDiscountId}),
      responseKind: "turbo-stream"
    });
  }

  removeTaxAndDiscount(id) {
    // let taxAndDiscountId = this.taxAndDiscountPolyTarget.children[0].id
    let taxAndDiscountId = this.element.children[10].children[0].id
    // this.taxAndDiscountPolyTargets
    destroy(`/invoices/tax_and_discount_polies/${taxAndDiscountId}`, {
      responseKind: "turbo-stream"
    });
  }

  addLineItem(id) {
    let productId = this.productTarget.value;
    post(`/invoices/line_items`, {
      body: JSON.stringify({productId: id}),
      responseKind: "turbo-stream"
    });
  }

  // Three conditions to remove line item
  // 1. id will be as productId
  // 2. id will be as line item name
  // 3. id will be as line item data with semicolon
  removeLineItem(id) {
    let lineItem = this.lineitemTargets.find((lineitem) => lineitem.dataset.params == id);
    const lineItemId = lineItem.id
    
    destroy(`/invoices/line_items/${lineItemId}`, { 
      responseKind: "turbo-stream"
    });

    let taxAndDiscountId = this.element.children[10].children[0].id
    destroy(`/invoices/tax_and_discount_polies/${taxAndDiscountId}`, {
      responseKind: "turbo-stream"
    });
  }
 
  handleInputChange(event) {
    this.handleLineItemChange();
    this.handleTaxAndDiscountPolyChange();
  }

  lineitemTargetConnected() {
    this.handleLineItemChange()
  }

  lineitemTargetDisconnected(event) {
    this.handleLineItemChange()   
  }

  handleLineItemChange(event) {
    let lineItemsAttributes = [];
    this.lineitemTargets.forEach((lineitem) => {
      lineItemsAttributes.push({
        quantity: lineitem.children[1].children[0].value,
        unitRate: lineitem.children[2].children[0].value
      });
    });

    let taxAndDiscountPolyAttributes = [];
    this.taxAndDiscountPolyTargets.forEach((taxAndDiscountPoly) => {
      taxAndDiscountPolyAttributes.push({
        name: taxAndDiscountPoly.children[0].children[0].value,
        amount: taxAndDiscountPoly.children[1].children[0].value,
        td_type: taxAndDiscountPoly.children[2].children[0].value,
        tax_type: taxAndDiscountPoly.children[3].children[0].value
      });
    });

    post(`/invoices/amount_calculations`, {
      body: JSON.stringify({lineItemsAttributes, taxAndDiscountPolyAttributes}),
      responseKind: "turbo-stream"
    });
  }

  taxAndDiscountPolyTargetConnected(event) {
    this.handleTaxAndDiscountPolyChange()
  }

  taxAndDiscountPolyTargetDisconnected() {
    this.handleTaxAndDiscountPolyChange()
  }

  handleTaxAndDiscountPolyChange(event) {
    let lineItemsAttributes = [];
    this.lineitemTargets.forEach((lineitem) => {
      lineItemsAttributes.push({
        quantity: lineitem.children[1].children[0].value,
        unitRate: lineitem.children[2].children[0].value
      });
    });
  
    let taxAndDiscountPolyAttributes = [];
    this.taxAndDiscountPolyTargets.forEach((taxAndDiscountPoly) => {
      taxAndDiscountPolyAttributes.push({
        name: taxAndDiscountPoly.children[0].children[0].value,
        amount: taxAndDiscountPoly.children[1].children[0].value,
        td_type: taxAndDiscountPoly.children[2].children[0].value,
        tax_type: taxAndDiscountPoly.children[3].children[0].value
      });
    });

    post(`/invoices/amount_calculations`, {
      body: JSON.stringify({lineItemsAttributes, taxAndDiscountPolyAttributes}),
      responseKind: "turbo-stream"
    });
  }
}
