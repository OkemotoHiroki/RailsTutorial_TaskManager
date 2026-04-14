class RenameOauthCredentialsToGoogleCalendarIntegrations < ActiveRecord::Migration[8.1]
  def change
    rename_table :oauth_credentials, :google_calendar_integrations
  end
end
