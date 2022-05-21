class ProjectsController < ApplicationController
  before_action :authorized, only: [:create]
  #skip_before_action :authorized, only: [:index, :show_by_id]	
  before_action :set_project, only: [:show_by_id, :update, :destroy]
	
  @@TYPE="project"
	
  # GET /projects
  def index
    @projects = Project.all
    render json: @projects
  end

  # GET /projects/:id
  def show_by_id
    render json: @project
  end
	
  # GET /projects/my_projects
  def show_own_all
    render json: @project
  end
	
  # POST /projects
  def create
	begin
    	@project = Project.new(project_params)
	rescue ActionController::ParameterMissing => e # parameter missing
		head 400
	else
		@project.user_id = @user.id
		if @project.save
			render json: handle_project_info(@project)
		  #render json: @project, status: :created, location: @project
		else
		  render json: @project.errors, status: :unprocessable_entity
		end
	end
  end

  # PUT /projects/1
  def update_by_id
    if @project.update(project_params)
      render json: @project
    else
      render json: @project.errors, status: :unprocessable_entity
    end
  end

  # DELETE /projects/1
  def delete_by_id
    @project.destroy
  end

  private
	def handle_project_info(project)	# method for processing project info
	ownername = User.username(@user.first_name, @user.last_name)
	{data: {
			id: @project.id, 
			type: @@TYPE, 
			attributes: {
				title: @project.title,
				thumbnail: @project.thumbnail.url,
				description: @project.description,
				location: @project.location,
				type: @project.type,
				ownername: ownername,
				created_at: @project.created_at,
				updated_at: @project.updated_at
			}
		}
	}
  end
	
    # Use callbacks to share common setup or constraints between actions.
    def set_project
      @project = Project.find(params[:id])
    end

    # Only allow a trusted parameter "white list" through.
    def project_params
		required = [:title, :type, :location, :thumbnail]
		permitted = required + [:description]
		params.require(required)
		params.permit(permitted)
    end
end
