class TasksController < ApplicationController
  before_action :authenticate_user!
  def index
    @tasks = current_user.tasks
  end
  def new
    @task = current_user.tasks.new
  end

  def create
    @task = current_user.tasks.new(task_params)
    if @task.save
      images = Array(params.dig(:task, :images)).reject(&:blank?)
      images.each do |image|
        @task.images.create!(
          data: image.read,
          content_type: image.content_type,
          filename: image.original_filename
        )
      end
      integration = current_user.google_calendar_integration
      if integration&.sync_enabled
        GoogleCalendarService.new(current_user.google_calendar_integration).add_event_to_google_calendar(@task)
      end
      redirect_to tasks_path, notice: "タスクが作成されました。"
    else
      render :new, status: :unprocessable_entity
    end
  end

  def show
    @task = current_user.tasks.find(params[:id])
  end

  def edit
    @task = current_user.tasks.find(params[:id])
  end

  def update
    @task = current_user.tasks.find(params[:id])


    if params.dig(:task, :images_to_delete).present?
      params[:task][:images_to_delete].split(",").each do |id|
        @task.images.find(id)&.destroy
      end
    end

    if params.dig(:task, :images).present?
      images = Array(params.dig(:task, :images)).reject(&:blank?)
      images.each do |image|
        @task.images.create!(
          data: image.read,
          content_type: image.content_type,
          filename: image.original_filename
        )
      end
    end

    if @task.update(task_params)
      integration = current_user.google_calendar_integration
      if integration&.sync_enabled
        GoogleCalendarService.new(current_user.google_calendar_integration).update_event_to_google_calendar(@task)
      end
      redirect_to task_path(@task), notice: "タスクが更新されました。"
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @task = current_user.tasks.find(params[:id])
    integration = current_user.google_calendar_integration
    if integration&.sync_enabled && @task.event_id.present?
      GoogleCalendarService.new(current_user.google_calendar_integration).delete_event_to_google_calendar(@task)
    end
    @task.destroy
    redirect_to tasks_path, notice: "タスクが削除されました。"
  end

  def image
    @image = Image.find(params[:id])
    if @image.task.user_id != current_user.id
      head :forbidden
      return
    end
    send_data @image.data, type: @image.content_type, filename: @image.filename, disposition: "inline"
  end


  private
  def task_params
    params.require(:task).permit(:name, :detail, :start_datetime, :end_datetime)
  end
end
