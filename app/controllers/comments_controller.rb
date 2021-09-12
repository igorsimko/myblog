class CommentsController < ApplicationController
  before_action :set_comment, only: %i[show edit update destroy]

  # GET /comments or /comments.json
  def index
    @comments = Comment.all
  end

  # GET /comments/1 or /comments/1.json
  def show; end

  # GET /comments/1/edit
  def edit
    @post = @comment.post
  end

  # POST /comments or /comments.json
  def create
    @comment = Comment.new(comment_params)
    @comment.user = current_user

    respond_to do |format|
      if @comment.save
        ActionCable.server.broadcast("post_channel_#{@comment.post_id}", { action: :new_comment, html: render_to_string(partial: '/comments/show', locals: {comment: @comment}) })
        format.html { redirect_to post_url(@comment.post_id), notice: 'Comment was successfully created.' }
        format.json { render :show, status: :created, location: @comment }
      else
        format.html { redirect_to post_url(@comment.post_id), notice: @comment.errors.full_messages.join('. ').to_s }
        format.json { render json: @comment.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /comments/1 or /comments/1.json
  def update
    respond_to do |format|
      if @comment.update(comment_params)
        reaction_update(@comment)
        format.html { redirect_to post_url(@comment.post_id), notice: 'Comment was successfully updated.' }
        format.json { render :show, status: :ok, location: @comment }
      else
        format.html { render :edit, status: :unprocessable_entity }
        format.json { render json: @comment.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /comments/1 or /comments/1.json
  def destroy
    @comment.destroy
    respond_to do |format|
      ActionCable.server.broadcast("post_channel_#{@comment.post_id}", { action: :comment_deleted, comment_id: @comment.id })
      format.html { redirect_to post_url(@comment.post_id), notice: 'Comment was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  def react
    kind = params.require(:reaction).permit(:kind)[:kind]
    comment = Comment.where(id: params[:comment_id]).first

    return render json: json_response('Comment not found', :not_found), status: :not_found unless comment

    reaction = comment.reactions.where(user: current_user).first
    if reaction
      reaction.delete
      reaction_update(comment)
      return render json: json_response('Reaction deleted', :ok) if reaction.kind.to_s == kind
    end

    reaction = Reaction.new(user: current_user, comment: comment, kind: kind)
    if reaction.save
      reaction_update(comment)
      render json: json_response('Reaction created', :ok)
    else
      render json: json_response(reaction.errors.full_messages.join('. '), :unprocessable_entity), status: :unprocessable_entity
    end
  end

  private

  def reaction_update(comment)
    ActionCable.server.broadcast("post_channel_#{comment.post_id}", { action: :comment_updated, comment_id: comment.id, html: render_to_string(partial: '/comments/show', locals: {comment: comment}) })
  end

  # Use callbacks to share common setup or constraints between actions.
  def set_comment
    @comment = current_user.comments.find(params[:id])
    redirect_to :root unless @comment
  end

  # Only allow a list of trusted parameters through.
  def comment_params
    params.require(:comment).permit(:content, :user_id, :post_id)
  end
end
