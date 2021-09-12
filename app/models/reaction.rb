class Reaction < ApplicationRecord
  belongs_to :comment
  belongs_to :user

  enum kind: {
    like: 'like',
    smile: 'smile',
    thumbs_up: 'thumbs_up'
  }

  def post?
    post_id.present? && comment_id.nil?
  end

  def comment?
    comment_id.present? && post_id.nil?
  end
end
