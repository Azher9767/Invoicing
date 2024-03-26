import { Controller } from "@hotwired/stimulus"
import { get } from "@rails/request.js"

export default class extends Controller {
  static targets = ["product"]

  handler() {
    let productId = this.productTarget.value;
    console.log(productId)
    get(`/invoices/add_line_items?product_id=${productId}`, {
      responseKind: "turbo-stream"
    });
  }
}