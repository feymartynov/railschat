class SessionsController < ApplicationController
  skip_before_action :require_login, except: %i(destroy)

  def new
    @user = User.new
  end

  def create
    @user = login(params[:name], params[:password], true)

    if @user
      redirect_back_or_to root_path
    else
      flash.now[:error] = 'Wrong name or password'
      render action: 'new'
    end
  end

  def destroy
    logout
    redirect_to '/login'
  end
end
