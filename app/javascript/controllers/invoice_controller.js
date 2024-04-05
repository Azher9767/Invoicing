import { Controller } from "@hotwired/stimulus"
import { get, post, destroy } from "@rails/request.js"
import TomSelect from 'tom-select'


export default class extends Controller {
  static targets = ["product", "lineitem"]

  connect() {
    let addEventHandler = () => (...args) => this.addHandler(...args);
    let removeEventHandler = () => (...args) => this.removeHandler(...args);
    this.select = new TomSelect("#product_id",{
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
          console.log(data)
          return '<div>' + escape(data.text) + '</div>';
        }
      }
    });

    // this.select.on('item_remove', (event) => {
    //   // console.log(this.element.children[4].id)
    //   let lineItemId = this.element.children[4].id;
    //   let elementToRemove = document.getElementById(lineItemId);
    //   console.log(elementToRemove)
    //     elementToRemove.remove();
    // });
  }

  addHandler(id) {
    let productId = this.productTarget.value;
    get(`/invoices/add_line_items?product_id=${id}`, {
      responseKind: "turbo-stream"
    });
  }

  removeHandler(id) {
    console.log(id)
    destroy(`/invoices/delete_line_items?line_item_id=${this.element.children[4].id}`, { 
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
    // this.handleItemRemove(event)   
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
  
  handleItemRemove(event) {
    let selectedItems = this.select.items;
    let deletedLineItem = event.children[4].value;
    selectedItems.forEach(item => {
        if (item === deletedLineItem) {
            this.select.removeItem(item);
        }
    });
  } 
}
