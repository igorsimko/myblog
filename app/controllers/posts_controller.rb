class PostsController < ApplicationController
  before_action :set_post, only: %i[show edit update destroy]
  before_action :verify_user, only: %i[edit update destroy]

  # GET /posts or /posts.json
  def index
    @posts = User.find(params[:user_id]).posts

    respond_to do |format|
      format.html { render 'index' }
      format.json { render json: @posts }
    end
  end

  # GET /posts/1 or /posts/1.json
  def show
    @comment = Comment.new(post: @post, user: current_user)
  end

  # GET /posts/new
  def new
    @post = Post.new(user: current_user)
  end

  # GET /posts/1/edit
  def edit; end

  # POST /posts or /posts.json
  def create
    @post = current_user.posts.new(post_params)

    respond_to do |format|
      if @post.save
        ActionCable.server.broadcast("post_channel_#{@post.id}", { action: :post_created, post: @post })
        format.html { redirect_to @post, notice: 'Post was successfully created.' }
        format.json { render json: json_response('Post was successfully updated.', :ok) }
      else
        format.html { render :new, status: :unprocessable_entity }
        format.json { render json: @post.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /posts/1 or /posts/1.json
  def update
    respond_to do |format|
      post = current_user.posts.find(params[:id])
      if post.update(post_params)
        ActionCable.server.broadcast("post_channel_#{post.id}", { action: :post_updated, post_id: post.id })
        format.html { redirect_to @post, notice: 'Post was successfully updated.' }
        format.json { render json: json_response('Post was successfully updated.', :ok) }
      else
        format.html { render :edit, status: :unprocessable_entity }
        format.json { render json: @post.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /posts/1 or /posts/1.json
  def destroy
    @post.destroy
    respond_to do |format|
      format.html { redirect_to posts_url, notice: 'Post was successfully destroyed.' }
      format.json { render json: json_response('Post was successfully destroyed.', :ok) }
    end
  end

  private

  # Use callbacks to share common setup or constraints between actions.
  def set_post
    @post = Post.find(params[:id])
  end

  def verify_user
    redirect_to :root, notice: "You can't edit the post" unless current_user.posts.where(id: params[:id]).first
  end

  # Only allow a list of trusted parameters through.
  def post_params
    params.require(:post).permit(:content, :title)
  end
end
