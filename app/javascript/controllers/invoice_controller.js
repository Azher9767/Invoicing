import { Controller, ElementObserver } from "@hotwired/stimulus"
import { get, post, destroy, put } from "@rails/request.js"
import TomSelect from 'tom-select'
export default class extends Controller {
  static targets = ["lineitem", "taxAndDiscountPoly", "product"];
  static values = {
    edit: String
  }

  connect() {
    let addEventHandler = () => (...args) => this.addLineItem(...args);
    let removeEventHandler = () => (...args) => this.removeLineItem(...args);
    new TomSelect("#product_id", {
      plugins: ['remove_button'],
      create: true,
      closeAfterSelect: true,
      hidePlaceholder: true,
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
      hidePlaceholder: true,
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
    let taxAndDiscount = this.taxAndDiscountPolyTargets.find((taxAndDiscountPoly) => taxAndDiscountPoly.dataset.params == id);
    const taxAndDiscountId = taxAndDiscount.id
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

  // removeLineItem function use to find a line item based on the data-params attribute (lineitem.dataset.params) 
  //  Using the data-params attribute specifying the conditions for removing a line item
  // example: ID
  // a Number(1)
  // a Text(Work)
  // a Text(Work;10;10)
  removeLineItem(id) {
    let lineItem = this.lineitemTargets.find((lineitem) => lineitem.children[6].value == id);
    const lineItemId = lineItem.id
    destroy(`/invoices/line_items/${lineItemId}`, { 
      responseKind: "turbo-stream"
    });
  }
 
  handleInputChange(event) {
    this.handleLineItemChange();
    this.handleTaxAndDiscountPolyChange();
  }

  lineitemTargetConnected(target) {
    this.addTaxDiscountDropdown(target.id);
    this.handleLineItemChange();
  }

  lineitemTargetDisconnected(event) {
    this.handleLineItemChange();
  }

  //when the url is edit then rowId will be "line_item_198"
  //when url is new then rowId will be something alpha numeric
  addTaxDiscountDropdown(rowId) {
    let addEventHandlerTd = () => (...args) => this.handleTaxAndDiscountOnLineItem(...args);
    let removeEventHandlerTd = () => (...args) => this.handleTaxAndDiscountOnLineItem(args);
    let rowHtmlId;
    if (this.editValue) {
      const lineItemRegex = /^line_item_\d+$/;
      const hashRegex = /^-?\d+$/; // Matches any integer, including negative numbers

      if (lineItemRegex.test(rowId)) {
        // rowId follows the line_item_<id> format
        const lineItemId = rowId.split('_')[2];
        // invoice_line_items_attributes_-917897757923998642_tax_and_discount_ids
        rowHtmlId = `#invoice_line_items_attributes_${lineItemId}_tax_and_discount_ids`;
      } else if (hashRegex.test(rowId)) {
        // rowId is a numerical hash (including negative numbers)
        rowHtmlId = `#invoice_line_items_attributes_${rowId}_tax_and_discount_ids`;
      }
    } else {
      const rowIdOther = rowId
      rowHtmlId = `#invoice_line_items_attributes_${rowIdOther}_tax_and_discount_ids`;
    }
  
    new TomSelect(rowHtmlId, { 
      plugins: ['checkbox_options', 'remove_button'],
      create: false,
      hidePlaceholder: true,
      onItemAdd: addEventHandlerTd(),
      onItemRemove:removeEventHandlerTd(),
      render:{
        option:function(data,escape){
          return '<div class="d-flex"><span>' + escape(data.text) + '</span></div>';
        },

        item:function(data, escape){
          //  corrected later
          // let polyArray = JSON.parse(data.polyId);
          // let polyId = polyArray[0].p_id;

          // let isTrue = data.polyId.includes('true');
          return '<div>' + escape(data.text) + '</div>';
        }
      }
    });
  }

  handleTaxAndDiscountOnLineItem(event) {
    // this.removeLineItemTdsFromDb(event)
    this.taxAndDiscountOfLineItems();
  }

  removeLineItemTdsFromDb(event) {
    let polyId = event[1].dataset.polyId

    console.log(polyId)
    let htmlTdIds = `invoice_line_items_attributes_${polyId}_tax_and_discount_polies_attributes_0__destroy`
    let el = document.getElementById(htmlTdIds)
    console.log(el)
    // let lineItemTdsId = event[0]
    // this.extractLineItemAttributes(lineItemTdsId)
  }


  taxAndDiscountOfLineItems(){
    const taxAndDiscountPolyAttributes = this.taxAndDiscountPolyTargets.map((taxAndDiscountPoly) => ({
      name: taxAndDiscountPoly.children[0].children[0].value,
      amount: taxAndDiscountPoly.children[1].children[0].value,
      td_type: taxAndDiscountPoly.children[2].children[0].value
    }));

    post(`/invoices/calculations`, {
      body: JSON.stringify({ calculation: { lineItemsAttributes: this.extractLineItemAttributes(), taxAndDiscountPolyAttributes: taxAndDiscountPolyAttributes } }),
      responseKind: "turbo-stream"
    });
  }

  handleLineItemChange(event) {
    const taxAndDiscountPolyAttributes = this.taxAndDiscountPolyTargets.map((taxAndDiscountPoly) => ({
      name: taxAndDiscountPoly.children[0].children[0].value,
      amount: taxAndDiscountPoly.children[1].children[0].value,
      td_type: taxAndDiscountPoly.children[2].children[0].value
    }));

    post(`/invoices/calculations`, {
      body: JSON.stringify({ calculation: { lineItemsAttributes: this.extractLineItemAttributes(), taxAndDiscountPolyAttributes: taxAndDiscountPolyAttributes } }),
      responseKind: "turbo-stream"
    });
  }

  extractLineItemAttributes(){
    return this.lineitemTargets.map((lineitem) => {
      let tdIds = []
      let selectedTds = []
      let htmlElement = lineitem.children[4].children[1]?.children[0]?.children
      console.log(lineitem.children[4].children[1])
      if (htmlElement) {
        selectedTds = Array.from(htmlElement).slice(0, -1)
        tdIds = selectedTds.map(element => element.dataset.value)
      }
     
      return {
        quantity: lineitem.children[1].children[0].value,
        unitRate: lineitem.children[2].children[0].value,
        objId: lineitem.children[8].value,
        tdIds: tdIds
      };
    });
  }

  taxAndDiscountPolyTargetConnected(event) {
    this.handleTaxAndDiscountPolyChange()
  }

  taxAndDiscountPolyTargetDisconnected() {
    this.handleTaxAndDiscountPolyChange()
  }

  handleTaxAndDiscountPolyChange(event) {
    this.taxAndDiscountOfLineItems();
  }
}
