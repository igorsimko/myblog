module Reactionable
  include ActiveSupport::Concern

  def likes
    reactions.like.count
  end

  def smiles
    reactions.smile.count
  end

  def thumbs_ups
    reactions.thumbs_up.count
  end

end