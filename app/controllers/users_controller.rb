class UsersController < ApplicationController
  skip_before_action :require_login, only: %i(new create)

  def new
    @user = User.new
  end

  def create
    @user = User.new(user_params)

    if @user.save
      auto_login(@user, true)
      redirect_to root_path
    else
      render action: 'new'
    end
  end

  def edit
    @user = current_user
  end

  def update
    if current_user.update(user_params)
      redirect_back_or_to root_path
    else
      render action: 'edit'
    end
  end

  private

  def user_params
    params.require(:user).permit(:name, :password, :password_confirmation)
  end
end