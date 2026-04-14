class GoogleCalendarIntegrationsController < ApplicationController
  CLIENT_ID = ENV["GOOGLE_CLIENT_ID"]
  CLIENT_SECRET = ENV["GOOGLE_CLIENT_SECRET"]
  REDIRECT_URI = "http://localhost:3000/auth/google/calendar/callback"

  def connect
    client = OAuth2::Client.new(
      ENV["GOOGLE_CLIENT_ID"],
      ENV["GOOGLE_CLIENT_SECRET"],
      site: "https://accounts.google.com",
      authorize_url: "/o/oauth2/auth",
      token_url: "/o/oauth2/token"
    )

    redirect_to client.auth_code.authorize_url(
      redirect_uri: REDIRECT_URI,
      scope: "https://www.googleapis.com/auth/calendar",
      access_type: "offline",
      prompt: "consent"
    ), allow_other_host: true
  end

  def callback
    client = OAuth2::Client.new(
      ENV["GOOGLE_CLIENT_ID"],
      ENV["GOOGLE_CLIENT_SECRET"],
      site: "https://accounts.google.com",
      authorize_url: "/o/oauth2/auth",
      token_url: "/o/oauth2/token"
    )

    token = client.auth_code.get_token(
      params[:code],
      redirect_uri: REDIRECT_URI
    )

    if current_user.google_calendar_integration
      current_user.google_calendar_integration.update(
        access_token: token.token,
        refresh_token: token.refresh_token,
        expires_at: Time.current + token.expires_in.seconds,
        sync_enabled: true
      )
    else
      current_user.create_google_calendar_integration(
        access_token: token.token,
        refresh_token: token.refresh_token,
        expires_at: Time.current + token.expires_in.seconds,
        sync_enabled: true
      )
    end

    redirect_to user_path(current_user), notice: "Googleカレンダーと連携しました！"
  end

  def destroy
    if current_user.google_calendar_integration
      current_user.google_calendar_integration.destroy
      redirect_to user_path(current_user), notice: "Googleカレンダーとの連携を解除しました。"
    else
      redirect_to user_path(current_user), alert: "Googleカレンダーとの連携が見つかりませんでした。"
    end
  end

  def show
    @integration = current_user.google_calendar_integration
  end

  def update
  end

  def toggle_sync
    integration = current_user.google_calendar_integration
    if integration
      integration.update(sync_enabled: !integration.sync_enabled)
      redirect_to user_path(current_user), notice: "Googleカレンダーの同期設定を更新しました。"
    else
      redirect_to user_path(current_user), alert: "Googleカレンダーとの連携が見つかりませんでした。"
    end
  end

  private
  def google_calendar_integration_params
    params.require(:google_calendar_integration).permit(:sync_enabled)
  end
end
