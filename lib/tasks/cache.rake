CACHE_ROUTES = {
  'posts' => {
    'index' => nil,
    'new'   => nil,
    'show'  => Proc.new { Post.all.map { |post| {id: post.id} } }, # record ids to fetch
    'edit'  => Proc.new { Post.all.map { |post| {id: post.id} } },
  }
}.freeze unless defined? CACHE_ROUTES

namespace :cache do
  task generate_all: :environment do |t, args|
    app = ActionDispatch::Integration::Session.new Rails.application
    controllers = {}
    # Prepare routes list
    routes = Rails.application.routes.routes.map do |route|
      ctrl = route.defaults[:controller]
      next unless ctrl
      if !route.internal && route.verb == 'GET'
        controllers[ctrl] = ( ctrl + '_controller' ).camelize.constantize unless controllers[ctrl]
        [ ctrl, route.defaults[:action], route.name ]
      end
    end.uniq.compact
    # Process routes
    routes.each do |route|
      ctrl, act, named = route
      if CACHE_ROUTES.include?( ctrl ) && CACHE_ROUTES[ctrl].include?( act )
        if CACHE_ROUTES[ctrl][act] # route with params
          CACHE_ROUTES[ctrl][act].call.each do |params|
            puts "> #{ctrl}, #{act}, #{named}, #{params.inspect}"
            options = { controller: ctrl, action: act, only_path: true }
            options.merge! params
            path = Rails.application.routes.url_helpers.url_for options
            code = app.get( path )
            Rails.logger.error( ">>> cache:generate_all - error #{code} - #{path}" ) unless code == 200
          end
        else # route without params
          puts "> #{ctrl}, #{act}, #{named}"
          options = { controller: ctrl, action: act, only_path: true }
          path = Rails.application.routes.url_helpers.url_for options
          # NOTE: use expire to delete cache ?
          code = app.get( path )
          Rails.logger.error( ">>> cache:generate_all - error #{code} - #{path}" ) unless code == 200
        end
      end
    end
  end

  task :generate, [:ctrl, :act, :key, :id] => :environment do |t, args|
    if args[:ctrl] && args[:act]
      app = ActionDispatch::Integration::Session.new Rails.application
      ctrl, act, key, id = args[:ctrl], args[:act], args[:key], args[:id]
      options = { controller: ctrl, action: act, only_path: true }
      options[key] = id if key && id
      path = Rails.application.routes.url_helpers.url_for options
      puts "> #{ctrl}, #{act}, #{options[key].inspect}"
      if path
        code = app.get( path )
        Rails.logger.error( ">>> cache:generate - error #{code} - #{path}" ) unless code == 200
      end
    end
  end
end
