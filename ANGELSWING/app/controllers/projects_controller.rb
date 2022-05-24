class ProjectsController < ApplicationController
	before_action :authorized, only: [:create, :show_own_all, :update_by_id, :delete_by_id]
	before_action :set_project, only: [:show_by_id, :update_by_id, :delete_by_id]

	REQUIRED = [:title, :type, :location, :thumbnail]
	PERMITTED = REQUIRED + [:description, :user_id]
	
	# GET /projects
	def index
		begin
			@projects = Project.all	 # Select all project
			
			if @projects.length > 0	# If there is a project
				render json: ApiResponse.response(:SUCCESS, handle_projects_data(@projects))	# Successfully processed.
			else # If the project doesn't exist,
				render json: ApiResponse.response(:NO_DATA, nil) # No Data.
			end
		rescue => e # Rescue StandardError
			render json: ApiResponse.response(:SERVER_ERROR, nil) # Internal Server Error. 
		end
	end

	# GET /projects/:id
	def show_by_id	
		begin
			if @project # If there is a project
				render json: ApiResponse.response(:SUCCESS, handle_project_data(@project)) # Successfully processed.
			else	# If the project doesn't exist,
				render json: ApiResponse.response(:NO_DATA, nil) # No Data.
			end
		rescue => e	# Rescue StandardError
			render json: ApiResponse.response(:SERVER_ERROR, nil) # Internal Server Error.
		end
	end

	# GET /projects/my_projects
	def show_own_all
		begin	
			@projects = Project.where("user_id = ?", @user.id)	# Select project by user_id
		rescue => e
			render json: ApiResponse.response(:SERVER_ERROR, nil) # # Internal Server Error. 
		else	
			begin
				if @projects.length > 0 # If there is a project
					render json: ApiResponse.response(:SUCCESS, handle_projects_data(@projects)) # Successfully processed.
				else
					render json: ApiResponse.response(:NO_DATA, nil) # No Data.
				end
			rescue => e 
				render json: ApiResponse.response(:SERVER_ERROR, nil) # Internal Server Error. 
			end
		end
	end
	
	# POST /projects
	def create
		begin
			@project = Project.create(project_create_params) 
		rescue ActionController::ParameterMissing => e # If the required parameters do not exist,
			render json: ApiResponse.response(:PARAMETER_MISSING, nil)	# Required parameter is missing.
		rescue ArgumentError => e
			render json: ApiResponse.response(:INVALID_VALUE, nil) # Value is invalid.
		rescue => e
			render json: ApiResponse.response(:SERVER_ERROR, nil) # Internal Server Error. 
		else
			@project.user_id = @user.id # Set user id for project
			
			if @project.valid?
				render json: ApiResponse.response(:SUCCESS, handle_project_data(@project)) # Successfully processed.
			else
				render json: ApiResponse.response(:DB_ERROR, nil) # DB ERROR.
			end
		end
	end

	# PUT /projects/:id
	def update_by_id
		if @project # If there is a project
			if @project.user_id == @user.id	# Verify that the project belongs to the requested user
				begin
					update = @project.update(project_update_params)
				rescue ArgumentError => e
					render json: ApiResponse.response(:INVALID_VALUE, nil)	# Value is invalid.
				rescue => e
					render json: ApiResponse.response(:SERVER_ERROR, nil) # Internal Server Error. 
				else
					if update # If the project was updated successfully
						render json: ApiResponse.response(:SUCCESS, handle_project_data(@project)) # Successfully processed.
					else # If the project is not saved successfully
						render json: ApiResponse.response(:DB_ERROR, nil) # DB ERROR.
					end
				end
			else # If it is not a project of the requested user
				render json: ApiResponse.response(:PERMISSON_ERROR, nil) # You do not have permission.
			end	
		else # If the project doesn't exist,
			render json: ApiResponse.response(:DATA_NOT_EXIST, nil) # "Data does not exist."
		end
	end

  	# DELETE /projects/:id
  	def delete_by_id
		if @project # If there is a project
			if @project.user_id == @user.id # Verify that the project belongs to the requested user
				begin
					destroy = @project.destroy # destroy project
				rescue => e
					render json: ApiResponse.response(:SERVER_ERROR, nil) # Internal Server Error. 
				else
					if destroy # If the project was destroyed successfully
						code = :DELETED
						render json: ApiResponse.response(code, Project::CODE[code]) # "Deleted."
					else
						render json: ApiResponse.response(:DB_ERROR, nil) # DB ERROR.
					end
				end
			else	# If it is not a project of the requested user
				render json: ApiResponse.response(:PERMISSON_ERROR, nil) # You do not have permission.
			end
		else # If the project doesn't exist
			render json: ApiResponse.response(:DATA_NOT_EXIST, nil) # Data does not exist.
		end
  	end

  	private
	
	# method for processing multiple project info
	def handle_projects_data(projects)	
		if projects	# If the projects exist
			data = []
			projects.each do |project|
				data.append(handle_project_data(project)) # append project to data
			end
			data
		else	# If the projects do not exist
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
