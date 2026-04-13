class Task < ApplicationRecord
  belongs_to :user

  has_many_attached :images

  validates :name, presence: true
  validates :detail, presence: true
  validates :start_datetime, presence: true
  validates :end_datetime, presence: true
  validates :images, blob: { content_type: [ "image/png", "image/jpg", "image/jpeg" ], size: 1..(5.megabytes) }
end
