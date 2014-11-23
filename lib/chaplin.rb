require_relative 'chaplin/config'
require_relative 'chaplin/router'
require_relative 'chaplin/server'

class Chaplin


  def initialize(project_path)
    @project_path = project_path
    @config = Config.new(@project_path)
    @router = Router.new(@project_path)
  end

  def server
    ApiEndpoint.configure(@config.api_url, @config.default_headers, @config.basic_auth)
    Server.setup(@project_path)
    build_server
    Server.new
  end

  private

  def build_server
    @router.load_routes

    @router.routes.each do |route|
      Server.add_route(route)
    end
  end

end

