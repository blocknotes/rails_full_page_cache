class ApplicationRecord < ActiveRecord::Base
  self.abstract_class = true

  protected

    def remove_cache_deps
      []
    end

    def remove_from_cache
      app = ActionDispatch::Integration::Session.new Rails.application
      path = Rails.application.routes.url_helpers.url_for controller: self.model_name.route_key, action: :show, id: self.id, only_path: true
      ctrl = ( self.model_name.route_key + '_controller' ).camelize.constantize
      ctrl.expire_page path
      update_deps app, remove_cache_deps
    end

    def update_cache
      app = ActionDispatch::Integration::Session.new Rails.application
      path = Rails.application.routes.url_helpers.url_for controller: self.model_name.route_key, action: :show, id: self.id, only_path: true
      if ( code = app.get( path ) ) == 200
        update_deps app, update_cache_deps
      else
        Rails.logger.error( ">>> update_cache - error #{code} - #{path}" )
        # NOTE: raise exception?
      end
    end

    def update_cache_deps
      []
    end

    def update_deps( app, deps )
      deps.each do |dep|
        dep[:only_path] = true
        expire = dep.delete :expire
        path = Rails.application.routes.url_helpers.url_for dep
        unless expire
          Rails.logger.error( ">>> update_deps - error #{code} - #{path}" ) unless ( code = app.get( path ) ) == 200
          # NOTE: raise exception?
        else
          ( self.model_name.route_key + '_controller' ).camelize.constantize.expire_page path
          # TODO: remove empty dirs
        end
      end
    end
end
