module Spree
  module Admin
    class GraffitiSettingsController < Spree::Admin::BaseController
      include Spree::Backend::Callbacks

      def edit
        @preferences_security = []
      end

      def update
        config = SpreeGraffiti::Config
        params.each do |name, value|
          # # next unless Spree::Config.has_preference? name
          # Spree::Config[name] = value
          next unless config.has_preference? name
          config[name] = value
        end

        flash[:success] = Spree.t(:successfully_updated, resource: Spree.t(:general_settings))
        redirect_to edit_admin_graffiti_settings_path
      end
    end
  end
end