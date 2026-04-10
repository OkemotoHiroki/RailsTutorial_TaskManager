// Import and register all your controllers from the importmap via controllers/**/*_controller
import { application } from "controllers/application"
import { eagerLoadControllersFrom } from "@hotwired/stimulus-loading"
import FileDropController from "controllers/file_drop_controller"

application.register("file-drop", FileDropController)
eagerLoadControllersFrom("controllers", application)
