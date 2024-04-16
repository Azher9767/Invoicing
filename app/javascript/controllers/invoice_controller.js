import { Controller } from "@hotwired/stimulus"
import { get, post, destroy } from "@rails/request.js"
import TomSelect from 'tom-select'
export default class extends Controller {
  static targets = ["product", "lineitem", "taxOrDiscount"]

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

    new TomSelect("#tax_or_discount",{
      plugins: ['remove_button'],
      create: true,
      closeAfterSelect: true,
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

  addHandler(id) {
    let productId = this.productTarget.value;
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
    post(`/invoices/calculate_sub_total`, {
      body: JSON.stringify({ lineItemsAttributes }),
      responseKind: "turbo-stream"
    })
  }
}
