class ContentsController < ApplicationController
	before_action :authorized, only: [:create, :update_by_id, :delete_by_id]
	before_action :set_content, only: [:update_by_id, :delete_by_id]
		
	# GET /contents/:project_id/contents
	def show_by_project_id
		begin
			@contents = Content.where("project_id = ?", params[:project_id]) # Select content by project id
			if @contents.length > 0	# If the content exists,
				render json: ApiResponse.response(:INF_SUCCESS, handle_contents_data(@contents)) # Successfully processed.
			else
				render json: ApiResponse.response(:INF_NO_DATA, nil) # No Data.
			end
		rescue ActiveRecord::RecordNotFound => e
			render json: ApiResponse.response(:INF_NO_DATA, nil) # No Data.
		rescue => e
			render json: ApiResponse.response(:ERR_SERVER, nil) # Internal Server Error
		end
	end

	# GET /contents/:project_id/contents/:id
	def show_by_id
		begin
			@content = Content.where("id = ? and project_id = ?", params[:id], params[:project_id])[0]
			
			if @content # If the content exists,
				render json: ApiResponse.response(:INF_SUCCESS, handle_content_data(@content)) # Successfully processed.
			else
				render json: ApiResponse.response(:INF_NO_DATA, nil) # No Data.
			end
		rescue ActiveRecord::RecordNotFound => e
			render json: ApiResponse.response(:INF_NO_DATA, nil) # No Data.
		rescue => e
			render json: ApiResponse.response(:ERR_SERVER, nil) # Internal Server Error
		end
	end
	
	# POST /contents/:project_id/contents
	def create
		begin
			@project = Project.find(params[:project_id]) # select Project by id
		rescue ActiveRecord::RecordNotFound => e # If the project does not exists,
			render json: ApiResponse.response(:ERR_NOT_EXIST, nil)	# Data does not exist.
		else
			if @project.user_id == @user.id # If owner of the project,
				begin
					@content = Content.new(content_create_params)
				rescue ActionController::ParameterMissing => e # If the required parameters do not exist,
					render json: ApiResponse.response(:ERR_PARAM_MISSING, nil)	# Required parameter is missing.
				rescue ArgumentError => e
					render json: ApiResponse.response(:ERR_INVALID_VALUE, nil) # Value is invalid.
				rescue => e
					render json: ApiResponse.response(:ERR_SERVER, nil) # Internal Server Error. 
				else
					@content.user_id = @user.id # Set user id for content
					@content.project_id = @project.id
					
					begin
						save = @content.save # save content
					rescue => e
						render json: ApiResponse.response(:ERR_SERVER, nil) # Internal Server Error. 
					else
						if save	# If the content was saved successfully
							render json: ApiResponse.response(:INF_SUCCESS, handle_content_data(@content)) # Successfully processed.
						else # If the content is not saved successfully
							render json: ApiResponse.response(:ERR_DB, nil) # DB ERROR.
						end
					end
				end
			else # If not the owner of the project,
				render json: ApiResponse.response(:ERR_PERMISSON, nil) # You do not have permission.
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
					render json: ApiResponse.response(:ERR_INVALID_VALUE, nil)	# Value is invalid.
				rescue => e
					render json: ApiResponse.response(:ERR_SERVER, nil) # Internal Server Error. 
				else
					if update # If the content was updated successfully
						render json: ApiResponse.response(:INF_SUCCESS, handle_content_data(@content)) # Successfully processed.
					else # If the content is not saved successfully
						render json: ApiResponse.response(:ERR_DB, nil) # DB ERROR.
					end
				end
			else # If it is not a content of the requested user
				render json: ApiResponse.response(:ERR_PERMISSON, nil) # You do not have permission.
			end	
		else # If the content doesn't exist,
			render json: ApiResponse.response(:ERR_NOT_EXIST, nil) # "Data does not exist."
		end
	end

	# DELETE /contents/:id
	def delete_by_id
		if @content # If there is a content
			if @content.user_id == @user.id # Verify that the content belongs to the requested user
				begin
					destroy = @content.destroy # destroy content
				rescue => e
					render json: ApiResponse.response(:ERR_SERVER, nil) # Internal Server Error. 
				else
					if destroy # If the content was destroyed successfully
						render json: ApiResponse.response(:INF_DELETED, nil) # "Deleted."
					else
						render json: ApiResponse.response(:ERR_DB, nil) # DB ERROR.
					end
				end
			else	# If it is not a content of the requested user
				render json: ApiResponse.response(:ERR_PERMISSON, nil) # You do not have permission.
			end
		else # If the content doesn't exist
			render json: ApiResponse.response(:ERR_NOT_EXIST, nil) # Data does not exist.
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
	  		@content = Content.find(params[:id])
		rescue ActiveRecord::RecordNotFound => e
			@content = nil
		end
	end

	REQUIRED = [:title, :body]
	PERMITTED = REQUIRED
	
	# Only allow a trusted parameter "white list" through.
	def content_create_params
		params.require(REQUIRED)
		params.permit(PERMITTED)
    end
	
	def content_update_params
		params.permit(PERMITTED)
	end
end
