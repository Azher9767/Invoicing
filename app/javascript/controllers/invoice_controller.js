import { Controller } from "@hotwired/stimulus"
import { get, post, destroy } from "@rails/request.js"
import TomSelect from 'tom-select'
export default class extends Controller {
  static targets = ["lineitem", "taxAndDiscountPoly", "product"]

  connect() {
    let addEventHandler = () => (...args) => this.addHandler(...args);
    let removeEventHandler = () => (...args) => this.removeHandler(...args);
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

    let addEvent = () => (...args) => this.addHandle(...args);
    new TomSelect("#tax_and_discount",{
      plugins: ['remove_button'],
      create: true,
      closeAfterSelect: true,
      onItemAdd: addEvent(),
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

  addHandle(id) {
    let taxAndDiscountId = id; 
    post(`/invoices/add_td_fields?taxAndDiscountId=${taxAndDiscountId}`, {
      responseKind: "turbo-stream"
    });
  }

  addHandler(id) {
    let productId = this.productTarget.value;
    console.log(productId)
    post(`/invoices/line_items`, {
      body: JSON.stringify({productId: id}),
      responseKind: "turbo-stream"
    });
  }

  removeHandler(event) {
    let lineItemId = this.element.children[4].id;
    destroy(`/invoices/line_items/${lineItemId}`, { 
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
      })
    })

    let taxAndDiscountPolyAttributes = [];
    this.taxAndDiscountPolyTargets.forEach((taxAndDiscountPoly) => {
      taxAndDiscountPolyAttributes.push({
        name: taxAndDiscountPoly.children[0].children[0].value,
        amount: taxAndDiscountPoly.children[1].children[0].value,
        td_type: taxAndDiscountPoly.children[2].children[0].value
      });
    });

    post(`/invoices/calculate_sub_total`, {
      body: JSON.stringify({lineItemsAttributes, taxAndDiscountPolyAttributes}),
      responseKind: "turbo-stream"
    })
  }

  taxAndDiscountPolyTargetConnected(event) {
    this.handleTaxAndDiscountPolyChange()
  }

  taxAndDiscountPolyTargetDisconnected() {
    console.log("disconnected")
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
        td_type: taxAndDiscountPoly.children[2].children[0].value
      });
    });
  
    post(`/invoices/calculate_sub_total`, {
      body: JSON.stringify({ lineItemsAttributes, taxAndDiscountPolyAttributes}),
      responseKind: "turbo-stream"
    })
  }
}
