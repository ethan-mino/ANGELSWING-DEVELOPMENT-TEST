class ContentsController < ApplicationController
	before_action :authorized, only: [:create, :update_by_id, :delete_by_id]
	before_action :set_content, only: [:update_by_id, :delete_by_id]
	
	REQUIRED = [:title, :body]
	PERMITTED = REQUIRED + [:user_id, :project_id]
	
	# GET /projects/:project_id/contents
	def show_by_project_id
		begin
			@contents = Content.where("project_id = ?", params[:project_id])
			if @contents
				render json: ApiResponse.response("INFO-200", handle_contents_data(@contents))
			else
				render json: ApiResponse.response("INFO-210", nil)
			end
		rescue => e
			render json: ApiResponse.response("ERROR-500", nil)
		end
	end

	# GET /projects/:project_id/contents/:id
	def show_by_id
		begin
			Content.where("id = ? and project_id = ?", params[:id], params[:project_id])
			if @content
				render json: ApiResponse.response("INFO-200", handle_content_data(@content))
			else
				render json: ApiResponse.response("INFO-210", nil)
			end
		rescue => e
			render json: ApiResponse.response("ERROR-500", nil)
		end
	end
	
	# POST /projects/:project_id/contents
	def create
		begin
			@content = Content.new(content_create_params)
		rescue ActionController::ParameterMissing => e # parameter missing
			render json: ApiResponse.response("ERROR-300", nil)
		rescue ArgumentError => e
			render json: ApiResponse.response("ERROR-310", nil)
		rescue => e
			render json: ApiResponse.response("ERROR-500", nil)
		else
			@content.user_id = @user.id
			
			begin
				save = @content.save
			rescue ActiveRecord::RecordNotUnique => e
				render json: ApiResponse.response("ERROR-400", nil)
			else
				if save
					render json: ApiResponse.response("INFO-200", handle_content_data(@content))
				else
					render json: ApiResponse.response("ERROR-310", nil)
				end
			end
		end
	end

	# PUT /contents/:id
	def update_by_id
		if @content
			if @content.user_id == @user.id
				begin
					update = @content.update(content_update_params)
				rescue ArgumentError => e
					render json: ApiResponse.response("ERROR-310", nil)
				rescue ActiveRecord::RecordNotUnique => e
					render json: ApiResponse.response("ERROR-400", nil)
				rescue => e
					render json: ApiResponse.response("ERROR-500", nil)
				else
					if update
						render json: ApiResponse.response("INFO-200", handle_content_data(@content))
					else
						render json: ApiResponse.response("ERROR-310", nil)
					end
				end
			else
				render json: ApiResponse.response("ERROR-410", nil)
			end	
		else
			render json: ApiResponse.response("ERROR-420", nil)
		end
	end

	# DELETE /contents/:id
	def delete_by_id
		begin
			if @content
				if @content.user_id == @user.id
					begin
						destroy = @content.destroy
					rescue ActiveRecord => e
						render json: ApiResponse.response("ERROR-430", nil)
					else
						if destroy
							code = "INFO-400"
							render json: ApiResponse.response(code, Content::CODE[code])
						else
							render json: ApiResponse.response("ERROR-420", nil)
						end
					end
				else
					render json: ApiResponse.response("ERROR-410", nil)
				end
			else
				render json: ApiResponse.response("ERROR-420", nil)
			end
		rescue => e
			render json: ApiResponse.response("ERROR-500", nil)
		end
	end

	private
	# method for processing project info
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
	
	# method for processing multiple project info
	def handle_contents_data(contents)
		if contents
			data = []
			contents.each do |project|
				data.append(handle_content_data(project))
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
