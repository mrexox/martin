class Admin::MessagesController < ApplicationController
  def index
      @messages = Message.sorted
  end

  def destroy
      @message = Message.find(params[:id])
      respond_to do |format|
	  if @message.delete
	      format.html { render 'index' }
	      format.json { render :json => {:message_id => @message.id, :error => ''},
		     status: 200 }
	  else
	      flash.now[:error] = @message.error
	      format.html { render 'index' }
	      format.json { render :json => {:error => ''},
		     status: 500 }
	  end
      end
  end
end
