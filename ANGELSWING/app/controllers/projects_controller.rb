class ProjectsController < ApplicationController
	before_action :authorized, only: [:create, :show_own_all, :update_by_id, :delete_by_id]
	before_action :set_project, only: [:show_by_id, :update_by_id, :delete_by_id]

	REQUIRED = [:title, :type, :location, :thumbnail]
	PERMITTED = REQUIRED + [:description, :user_id]
	
	# GET /projects
	def index
		begin
			@projects = Project.all
			if @projects
				render json: ApiResponse.response("INFO-200", handle_projects_data(@projects))
			else
				render json: ApiResponse.response("INFO-210", nil)
			end
		rescue => e
			render json: ApiResponse.response("ERROR-500", nil)
		end
	end

	# GET /projects/:id
	def show_by_id	
		begin
			if @project
				render json: ApiResponse.response("INFO-200", handle_project_data(@project))
			else
				render json: ApiResponse.response("INFO-210", nil)
			end
		rescue => e
			render json: ApiResponse.response("ERROR-500", nil)
		end
	end

	# GET /projects/my_projects
	def show_own_all
		@projects = Project.where("user_id = ?", @user.id)
		begin
			if @projects
				render json: ApiResponse.response("INFO-200", handle_projects_data(@projects))
			else
				render json: ApiResponse.response("INFO-210", nil)
			end
		rescue => e
			puts e
			render json: ApiResponse.response("ERROR-500", nil)
		end
	end
	
	# POST /projects
	def create
		begin
			@project = Project.new(project_create_params)
		rescue ActionController::ParameterMissing => e # parameter missing
			render json: ApiResponse.response("ERROR-300", nil)
		rescue ArgumentError => e
			render json: ApiResponse.response("ERROR-310", nil)
		rescue => e
			render json: ApiResponse.response("ERROR-500", nil)
		else
			@project.user_id = @user.id
			
			begin
				save = @project.save
			rescue ActiveRecord::RecordNotUnique => e
				render json: ApiResponse.response("ERROR-400", nil)
			else
				if save
					render json: ApiResponse.response("INFO-200", handle_project_data(@project))
				else
					render json: ApiResponse.response("ERROR-310", nil)
				end
			end
		end
	end

	# PUT /projects/:id
	def update_by_id
		if @project
			if @project.user_id == @user.id
				begin
					update = @project.update(project_update_params)
				rescue ArgumentError => e
					render json: ApiResponse.response("ERROR-310", nil)
				rescue ActiveRecord::RecordNotUnique => e
					render json: ApiResponse.response("ERROR-400", nil)
				rescue => e
					render json: ApiResponse.response("ERROR-500", nil)
				else
					if update
						render json: ApiResponse.response("INFO-200", handle_project_data(@project))
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

  	# DELETE /projects/:id
  	def delete_by_id
		begin
			if @project
				if @project.user_id == @user.id
					begin
						destroy = @project.destroy
					rescue ActiveRecord => e
						render json: ApiResponse.response("ERROR-430", nil)
					else
						if destroy
							code = "INFO-400"
							render json: ApiResponse.response(code, Project::CODE[code])
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
	
	# method for processing multiple project info
	def handle_projects_data(projects)	
		if projects
			data = []
			projects.each do |project|
				data.append(handle_project_data(project))
			end
			data
		else
			nil
		end
	end
		
	# method for processing project info
	def handle_project_data(project)	
		unless project.nil?
			owner = User.find(project.user_id);
			ownername = User.username(owner.first_name, owner.last_name)
			
			{
				id: project.id, 
				type: Project::TYPE, 
				attributes: {
					title: project.title,
					thumbnail: project.thumbnail.url,
					description: project.description,
					location: project.location,
					type: project.type,
					ownername: ownername,
					created_at: project.created_at,
					updated_at: project.updated_at
				}
			}
		else
			nil
		end
 	end
	
    # Use callbacks to share common setup or constraints between actions.
    def set_project
		begin
	  		@project = Project.find(params[:id])
		rescue ActiveRecord::RecordNotFound => e
			@project = nil
		end
    end

    # Only allow a trusted parameter "white list" through.
    def project_create_params
		params.require(REQUIRED)
		params.permit(PERMITTED)
    end
	
	def project_update_params
		params.permit(PERMITTED)
	end
end
