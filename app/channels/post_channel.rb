class PostChannel < ApplicationCable::Channel
  def subscribed
    p params
    stream_from "post_channel_#{params[:post_id]}"
  end

  def unsubscribed
    # Any cleanup needed when channel is unsubscribed
  end
end
