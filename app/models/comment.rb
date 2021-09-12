class Comment < ApplicationRecord
  include Reactionable

  belongs_to :user
  belongs_to :post

  has_many :reactions, dependent: :delete_all

  attr_reader :user_header

  def user_header
    "#{user.name} (#{ActionController::Base.helpers.time_ago_in_words(created_at)})"
  end
end
