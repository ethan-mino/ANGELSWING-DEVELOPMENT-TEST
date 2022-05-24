class ContentsController < ApplicationController
	before_action :authorized, only: [:create, :update_by_id, :delete_by_id]
	before_action :set_content, only: [:update_by_id, :delete_by_id]
	
	REQUIRED = [:title, :body]
	PERMITTED = REQUIRED + [:user_id, :project_id]
	
	# GET /projects/:project_id/contents
	def show_by_project_id
		begin
			@contents = Content.where("project_id = ?", params[:project_id]) # Select content by project id
			if @contents	# If the content exists,
				render json: ApiResponse.response("INFO-200", handle_contents_data(@contents)) # Successfully processed.
			else
				render json: ApiResponse.response("INFO-210", nil) # No Data.
			end
		rescue ActiveRecord::RecordNotFound => e
			render json: ApiResponse.response("INFO-210", nil) # No Data.
		rescue ActiveRecord => e
			render json: ApiResponse.response("ERROR-430", nil) # DB ERROR.
		rescue => e
			render json: ApiResponse.response("ERROR-500", nil) # Internal Server Error
		end
	end

	# GET /projects/:project_id/contents/:id
	def show_by_id
		begin
			Content.where("id = ? and project_id = ?", params[:id], params[:project_id])
			if @content # If the content exists,
				render json: ApiResponse.response("INFO-200", handle_content_data(@content)) # Successfully processed.
			else
				render json: ApiResponse.response("INFO-210", nil) # No Data.
			end
		rescue ActiveRecord::RecordNotFound => e
			render json: ApiResponse.response("INFO-210", nil) # No Data.
		rescue ActiveRecord => e
			render json: ApiResponse.response("ERROR-430", nil) # DB ERROR.
		rescue => e
			render json: ApiResponse.response("ERROR-500", nil) # Internal Server Error
		end
	end
	
	# POST /projects/:project_id/contents
	def create
		
		begin
			@content = Content.new(content_create_params)
		rescue ActionController::ParameterMissing => e # If the required parameters do not exist,
			render json: ApiResponse.response("ERROR-300", nil)	# Required parameter is missing.
		rescue ArgumentError => e
			render json: ApiResponse.response("ERROR-310", nil) # Value is invalid.
		rescue => e
			render json: ApiResponse.response("ERROR-500", nil) # Internal Server Error. 
		else
			@content.user_id = @user.id # Set user id for content
		
			begin
				save = @content.save # save content
			rescue ActiveRecord => e
				render json: ApiResponse.response("ERROR-430", nil) # "DB ERROR."
			else
				if save	# If the content was saved successfully
					render json: ApiResponse.response("INFO-200", handle_content_data(@content)) # Successfully processed.
				else # If the content is not saved successfully
					render json: ApiResponse.response("ERROR-430", nil) # DB ERROR.
				end
			end
		end
	end

	# PUT /contents/:id
	def update_by_id
		if @content # If there is a content
			if @content.user_id == @user.id	# Verify that the content belongs to the requested user
				begin
					update = @content.update(content_update_params)
				rescue ArgumentError => e
					render json: ApiResponse.response("ERROR-310", nil)	# Value is invalid.
				rescue ActiveRecord => e
					render json: ApiResponse.response("ERROR-430", nil) # "DB ERROR."
				else
					if update # If the content was updated successfully
						render json: ApiResponse.response("INFO-200", handle_content_data(@content)) # Successfully processed.
					else # If the content is not saved successfully
						render json: ApiResponse.response("ERROR-430", nil) # DB ERROR.
					end
				end
			else # If it is not a content of the requested user
				render json: ApiResponse.response("ERROR-410", nil) # You do not have permission.
			end	
		else # If the content doesn't exist,
			render json: ApiResponse.response("ERROR-420", nil) # "Data does not exist."
		end
	end

	# DELETE /contents/:id
	def delete_by_id
		if @content # If there is a content
			if @content.user_id == @user.id # Verify that the content belongs to the requested user
				begin
					destroy = @content.destroy # destroy content
				rescue ActiveRecord => e
					render json: ApiResponse.response("ERROR-430", nil) # DB ERROR.
				else
					if destroy # If the content was destroyed successfully
						code = "INFO-400"
						render json: ApiResponse.response(code, Content::CODE[code]) # "Deleted."
					else
						render json: ApiResponse.response("ERROR-430", nil) # DB ERROR.
					end
				end
			else	# If it is not a content of the requested user
				render json: ApiResponse.response("ERROR-410", nil) # You do not have permission.
			end
		else # If the content doesn't exist
			render json: ApiResponse.response("ERROR-420", nil) # Data does not exist.
		end
	end

	private
	# method for processing content info
	def handle_content_data(content)
		unless content.nil?
			owner = User.find(content.user_id);
			projectOwnerName = User.username(owner.first_name, owner.last_name)
			
			{
				id: content.id, 
				type: Content::TYPE, 
				attributes: {
					projectId: content.project_id,
					projectOwnerName: projectOwnerName,
					title: content.title,
					body: content.body,
					created_at: content.created_at,
					updated_at: content.updated_at
				}
			}
		else
			nil
		end	
	end
	
	# method for processing multiple content info
	def handle_contents_data(contents)
		if contents
			data = []
			contents.each do |content|
				data.append(handle_content_data(content))
			end
			data
		else
			nil
		end
	end
		
	# Use callbacks to share common setup or constraints between actions.
	def set_content
		begin
	  		@content = content.find(params[:id])
		rescue ActiveRecord::RecordNotFound => e
			@content = nil
		end
	end

	# Only allow a trusted parameter "white list" through.
	def content_create_params
		params.require(REQUIRED)
		params.permit(PERMITTED)
    end
	
	def content_update_params
		params.permit(PERMITTED)
	end
end
