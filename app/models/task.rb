class Task < ApplicationRecord
  belongs_to :user

  has_many_attached :images

  validates :name, presence: true
  validates :detail, presence: true
  validates :start_datetime, presence: true
  validates :end_datetime, presence: true
  # validates :images, content_type: { in: [ :png, :jpg, :jpeg ], message: "はpng, jpg, jpegいずれかの形式にして下さい" },
  # size: { between: 1.kilobyte..4.megabytes, message: "画像容量が大きすぎます。4MB以下でお願いします。" }
end
