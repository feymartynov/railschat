class ChatsController < ApplicationController
  def index
    @chat = Chat.new
  end

  def show
    @chat = Chat.find_by!(name: params[:id])
    @chat.join(current_user)
  end

  def leave
    @chat = Chat.find_by!(name: params[:id])
    @chat.leave(current_user)
    redirect_to root_path
  end

  def create
    name = URI::encode(params.require(:chat).require(:name))

    @chat = Chat.create_with(creator: current_user)
                .find_or_create_by(name: name)

    if @chat
      redirect_to chat_path(@chat.name)
    else
      render :index
    end
  end
end
