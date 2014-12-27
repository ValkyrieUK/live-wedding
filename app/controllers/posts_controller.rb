class PostsController < ApplicationController
  before_filter :validate_instagram_token, only: [ :index ]
  after_filter :update_state, only: [ :last, :index ]

  def index
    load_images_from_insta
    @posts = Post.where(state: 'notviewed').desc(:created_at)
    if @posts.empty?
      @posts = Post.all.desc(:created_at)
    end

    respond_to do |format|
      format.html
      format.js
    end
  end

  def last
    load_images_from_insta
    @post = Post.where(state: 'notviewed').desc(:created_at).first
    if @post
      respond_to do |format|
        format.json
      end
    else
      head :not_modified
    end
  end

  private

  def load_images_from_insta
    Instagram.tag_recent_media(INSTA_TAG).each do |insta_post|
      next if Post.where(insta_id: insta_post.id).any?
      if insta_post and insta_post.caption
        post = Post.create!(
          insta_id: insta_post.id,
          author: insta_post.caption.from.username,
          text: insta_post.caption.text,
          created_at: Time.at(insta_post.created_time.to_i).utc
        )
        if post
          post.image = Image.new(
            standart: insta_post.images.standard_resolution.url,
            thumbnail: insta_post.images.thumbnail.url,
            profile: insta_post.caption.from.profile_picture
          )
          post.save!
        end
      end
    end
  end

  def update_state
    if @posts or @post
      if @post
        @post.viewed
      else
        (@posts || []).map do |post|
          post.viewed
        end
      end
    end
  end

  def validate_instagram_token
    render text: params[:'hub.challenge'] if params[:'hub.challenge']
  end

end
