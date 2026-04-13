import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["input", "preview", "existingPreview", "deleteIds"]
  static values = { maxFiles: 10 }
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

    const files = Array.from(e.dataTransfer.files) // FileList を Array に変換
    const imageFiles = files.filter(file => file.type.startsWith('image/')) // 画像ファイルのみフィルタリング

    if (imageFiles.length === 0) return

  // 既存のファイルを配列化
  const existingFiles = Array.from(this.inputTarget.files || [])

  // 新しい画像ファイルを追加
  const allFiles = [...existingFiles, ...imageFiles]

  // DataTransfer でセット
  const dataTransfer = new DataTransfer()
  allFiles.forEach(file => dataTransfer.items.add(file))
  this.inputTarget.files = dataTransfer.files
  this.inputTarget.dispatchEvent(new Event("change", { bubbles: true }))
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
      // 削除ボタンを作成
      const deleteBtn = document.createElement("button")
      deleteBtn.textContent = "×"
      deleteBtn.classList.add("absolute", "top-0", "right-0", "bg-red-500", "text-white", "rounded-full", "w-6", "h-6", "text-xs", "flex", "items-center", "justify-center", "hover:bg-red-700")
      deleteBtn.addEventListener("click", () => this.removeImage(file, imageBox)) // 削除関数を呼び出し

      imageBox.appendChild(img)
      imageBox.appendChild(deleteBtn)

      this.previewTarget.appendChild(imageBox)
    }

    reader.readAsDataURL(file)
  }
  previewFiles(event) {
    const files = Array.from(event.target.files) 
    const imageFiles = files.filter(file => file.type.startsWith('image/')) 
    if (!imageFiles.length) return

    const existingFiles = this.previewTarget.querySelectorAll('[data-existing="true"]')
    this.previewTarget.innerHTML = ""
    existingFiles.forEach(img => this.previewTarget.appendChild(img))

    imageFiles.forEach(file => {
      this.previewImage(file)
    })
  }
  removeImage(fileToRemove, imageBox) {
    // プレビューから削除
    imageBox.remove()

    // ファイルリストから削除
    const currentFiles = Array.from(this.inputTarget.files)
    const updatedFiles = currentFiles.filter(file => file !== fileToRemove)

    // DataTransfer で更新
    const dataTransfer = new DataTransfer()
    updatedFiles.forEach(file => dataTransfer.items.add(file))
    this.inputTarget.files = dataTransfer.files
    this.inputTarget.dispatchEvent(new Event("change", { bubbles: true }))
  }
  removeExistingImage(event) {
    const imageDiv = event.target.closest("[data-image-id]")
    const imageId = imageDiv.dataset.imageId

    // プレビューから削除
    imageDiv.remove()

    // 削除IDをhiddenフィールドに追加
    const currentDeleteIds = this.deleteIdsTarget.value ? this.deleteIdsTarget.value.split(",") : []
    currentDeleteIds.push(imageId)
    this.deleteIdsTarget.value = currentDeleteIds.join(",")
  }
}