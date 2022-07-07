module Graffiti
  module Spree
    module ProductsControllerDecorator
      def self.prepended(base)
        base.helper Graffiti::Spree::FrontendHelper
      end

      def show
        redirect_if_legacy_path

        @presenter = @product.presenter
        @taxons = @presenter[:taxons].size > 0 ? @presenter[:taxons][-1] : []
        @variants = []

        render 'spree/products/graffiti/show'
      end

      def related
        if @product.blank?
          load_product
        end

        @presenter = @product.presenter
        taxon = @presenter[:taxons].last&.last
        if params[:taxon_id].blank?
          taxon_id = taxon.nil? ? nil : taxon[:id]
        else
          taxon_id = params[:taxon_id]
        end
        if taxon_id.nil?
          @related_products = []
        else
          query = {
            taxon: taxon_id,
            per_page: 10,
            include_images: true,
            in_stock: true,
            purchasable: true,
          }
          searcher = build_searcher(query)
          products = searcher.retrieve_products.reject do |x|
            @product.present? && x.id == @product.id
          end
          @related_products = products.first(18).map {|product| product.presenter }
        end

        if @related_products.any?
          render template: 'spree/products/graffiti/related', layout: false
        else
          head :no_content
        end
      end
    end
  end
end

::Spree::ProductsController.prepend ::Graffiti::Spree::ProductsControllerDecorator