class Image < ApplicationRecord
  # ブラウザにインライン表示させても安全な形式だけを許可する。
  # image/svg+xml はスクリプトを埋め込めるため意図的に含めない。
  INLINE_CONTENT_TYPES = %w[image/jpeg image/png image/gif image/webp].freeze

  belongs_to :task

  def inline_safe?
    INLINE_CONTENT_TYPES.include?(content_type)
  end

  # content_type はアップロード時の申告値なので信用できない。
  # 許可していない形式はブラウザに解釈させない型で返す。
  def safe_content_type
    inline_safe? ? content_type : "application/octet-stream"
  end
end
