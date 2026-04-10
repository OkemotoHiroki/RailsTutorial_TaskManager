import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["input", "preview"]

  dragover(e) {
    e.preventDefault()
    this.element.classList.add("bg-blue-100")
  }

  dragleave(e) {
    e.preventDefault()
    this.element.classList.remove("bg-blue-100")
  }

  drop(e) {
    e.preventDefault()

    this.element.classList.remove("bg-blue-100")

    const files = e.dataTransfer.files
    if (files.length === 0) return

    // inputへセット
    this.inputTarget.files = files
    this.inputTarget.dispatchEvent(new Event("change", { bubbles: true }))

    // preview表示
    Array.from(files).forEach(file => {
      this.previewImage(file)
    })
  }

  previewImage(file) {
    const reader = new FileReader()

    reader.onload = (e) => {
      const imageBox = document.createElement("div")
      imageBox.classList.add("inline-flex", "mx-1", "mb-2")

      const img = document.createElement("img")
      img.src = e.target.result
      img.width = 100
      img.classList.add("rounded")

      imageBox.appendChild(img)
      this.previewTarget.appendChild(imageBox)
    }

    reader.readAsDataURL(file)
  }
    previewFiles(event) {
    const files = event.target.files
    if (!files.length) return

    this.previewTarget.innerHTML = "" // ←重要（毎回クリア）

    Array.from(files).forEach(file => {
      this.previewImage(file)
    })
  }

}