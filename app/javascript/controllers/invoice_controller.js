import { Controller } from "@hotwired/stimulus"
import { get, post } from "@rails/request.js"

export default class extends Controller {
  static targets = ["product", "lineitem"]

  handler() {
    let productId = this.productTarget.value;
    get(`/invoices/add_line_items?product_id=${productId}`, {
      responseKind: "turbo-stream"
    });
  }

  handleInputChange(event) {
    this.handleLineItemChange();
  }

  lineitemTargetConnected() {
    this.handleLineItemChange()
  }

  lineitemTargetDisconnected() {
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
