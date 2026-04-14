class User < ApplicationRecord
  has_secure_password
  has_many :tasks, dependent: :destroy
  has_one :google_calendar_integration, dependent: :destroy

  validates :name, presence: true
  validates :email, presence: true, uniqueness: true
  validates :password, presence: true, length: { minimum: 6 }, if: :password_required?

  private
  def password_required?
    provider.nil?
  end
end
