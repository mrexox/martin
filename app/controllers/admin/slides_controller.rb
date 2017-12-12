class Admin::SlidesController < ApplicationController
	layout 'admin'
	def new
		@slide = Slide.new
	end

	def index
		@slides = Slide.all		
	end

	def edit
		@slide = Slide.find(params[:id])
	end

	def create
		@slide = Slide.new(slider_params)
		if @slide.save
			flash[:notice] = 'Слайд добавлен'
			redirect_to admin_slides_path
		else
			flash.now[:error] = 'Не удалось добавить слайд'
		end
	end

	def update
		@slide = Slide.find(params[:id])
		if @slide.update_attributes(slider_params)
			flash[:notice] = 'Слайд изменён'
			redirect_to admin_slides_path
		else
			flash.now[:error] = 'Не удалось изменить слайд'
		end
	end

	def destroy
		@slide = Slide.find(params[:id])
		if @slide.delete
			flash[:notice] = 'Слайд был удалён'
		else
			flash[:error] = 'Не удалось удалить слайд'
		end
		redirect_to admin_slides_path
	end

	private

	def slider_params
		params.require(:slide).permit(:photo, :name, :description)
	end
end
