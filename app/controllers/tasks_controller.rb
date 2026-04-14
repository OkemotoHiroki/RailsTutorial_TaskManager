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


    if params[:task][:images_to_delete].present?
      params[:task][:images_to_delete].split(",").each do |id|
        @task.images.find(id).purge
      end
    end

    if params[:task][:images].present?
      @task.images.attach(params[:task][:images])
    end

    if @task.update(task_params.except(:images))
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

  private
  def task_params
    params.require(:task).permit(:name, :detail, :start_datetime, :end_datetime, images: [])
  end
end
