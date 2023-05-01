class UsersController < ApplicationController
  before_action :correct_user, only: [:show]
  skip_before_action :login_required, only: [:new, :create]

  def new
    @user = User.new
  end

  def create
    @user = User.new(user_params)
  
    if params[:user][:profile_image]
      processed_image = process_image(params[:user][:profile_image])
      @user.profile_image.attach(io: File.open(processed_image.path), filename: params[:user][:profile_image].original_filename)
    end
  
    respond_to do |format|
      if @user.save
        log_in(@user)
        mail_params = {
          user: @user,
          to: @user.email
        }
        UserMailer.with(user: @user).welcome_email(mail_params).deliver_later(queue: 'mailers')
        LogAsyncJob.perform_later(@user.id)
  
        format.html { redirect_to @user, notice: "ユーザ登録が完了しました。" }
        format.json { render :show, status: :created, location: @user }
      else
        format.html { render :new }
        format.json { render json: @user.errors, status: :unprocessable_entity }
      end
    end
  end

  def show
    @user = User.find(params[:id])
  end

  private

  def user_params
    params.require(:user).permit(:name, :email, :password, :password_confirmation, :profile_image)
  end  

  def correct_user
    @user = User.find(params[:id])
    redirect_to current_user unless current_user?(@user)
  end

  def process_image(image)
    require 'image_processing/mini_magick'
  
    ImageProcessing::MiniMagick
      .source(image.tempfile)
      .resize_to_limit(500, 600)
      .call
  end
end
