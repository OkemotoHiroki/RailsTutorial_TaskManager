class GoogleCalendarService
  CLIENT_ID = ENV["GOOGLE_CLIENT_ID"]
  CLIENT_SECRET = ENV["GOOGLE_CLIENT_SECRET"]
  def initialize(google_calendar_integration)
    @session = {}
    @session[:access_token] = google_calendar_integration.access_token
    @session[:refresh_token] = google_calendar_integration.refresh_token
  end

  def authorized_client
    client = Signet::OAuth2::Client.new(
      client_id: CLIENT_ID,
      client_secret: CLIENT_SECRET,
      token_credential_uri: "https://oauth2.googleapis.com/token",
      access_token: @session[:access_token],
      refresh_token: @session[:refresh_token]
    )
    begin
      if client.expired?
        client.refresh!
        @session[:access_token] = client.access_token
      end
    rescue Signet::AuthorizationError => e
      Rails.logger.error("Google OAuth refresh failed: #{e.message}")
      @session.delete(:access_token)
      return nil
    end
    client
  end


  def add_event_to_google_calendar(task)
    return false unless @session[:access_token]
    service = Google::Apis::CalendarV3::CalendarService.new
    service.authorization = authorized_client

    event = Google::Apis::CalendarV3::Event.new(
      summary: task.name,
      description: task.detail,
      start: Google::Apis::CalendarV3::EventDateTime.new(date_time: task.start_datetime.iso8601, time_zone: "Asia/Tokyo"),
      end: Google::Apis::CalendarV3::EventDateTime.new(date_time: task.end_datetime.iso8601, time_zone: "Asia/Tokyo")
    )
    created_event=service.insert_event("primary", event)
    task.update(event_id: created_event.id)
  end

  def update_event_to_google_calendar(task)
    return false unless @session[:access_token]
    service = Google::Apis::CalendarV3::CalendarService.new
    service.authorization = authorized_client

    begin
      event = service.get_event("primary", task.event_id)
      event.summary = task.name
      event.description = task.detail
      event.start = Google::Apis::CalendarV3::EventDateTime.new(date_time: task.start_datetime.iso8601, time_zone: "Asia/Tokyo")
      event.end = Google::Apis::CalendarV3::EventDateTime.new(date_time: task.end_datetime.iso8601, time_zone: "Asia/Tokyo")
      service.update_event("primary", event.id, event)
    rescue Google::Apis::ClientError
      false
    end
  end

  def delete_event_to_google_calendar(task)
    return false unless @session[:access_token]
    service = Google::Apis::CalendarV3::CalendarService.new
    service.authorization = authorized_client
    begin
      event = service.get_event("primary", task.event_id)

      service.delete_event("primary", event.id)
    rescue Google::Apis::ClientError
      false
    end
  end
end
