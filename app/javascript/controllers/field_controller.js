import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = [ "items", "selector" ]

  connect() {
    // console.log("Hello, Stimulus!", this.element)
    this.toggle();
  }

  toggle() {
    const selector = this.selectorTarget
    const items = this.itemsTarget
    console.log(selector.value);

    if (selector.value == "liste") {
      items.classList.remove("hidden");
      items.classList.add("inline");
    }else{
      items.classList.add("hidden");
      items.classList.remove("inline");
    }
  }
}
