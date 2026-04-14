class CreateOauthCredentials < ActiveRecord::Migration[8.1]
  def change
    create_table :oauth_credentials do |t|
      t.references :user, null: false, foreign_key: true
      t.string :provider
      t.string :uid
      t.string :email
      t.text :access_token
      t.text :refresh_token
      t.datetime :expires_at
      t.string :scope
      t.boolean :sync_enabled

      t.timestamps
    end
  end
end
