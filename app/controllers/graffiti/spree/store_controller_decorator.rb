module Graffiti
  module Spree
    module StoreControllerDecorator
      def self.prepended(base)
        base.helper Graffiti::Spree::FrontendHelper
      end
    end
  end
end

::Spree::StoreController.prepend Graffiti::Spree::StoreControllerDecorator
