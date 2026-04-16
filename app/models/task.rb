class Task < ApplicationRecord
  belongs_to :user
  has_many :images, dependent: :destroy

  validates :name, presence: true
  validates :detail, presence: true
  validates :start_datetime, presence: true
  validates :end_datetime, presence: true
end
