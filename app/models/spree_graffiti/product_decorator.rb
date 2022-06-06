module SpreeGraffiti
  module ProductDecorator
    def self.prepended(base)
      def base.search_fields
        [:name, :brand, :description]
      end

      def base.filter_fields
        [:price, :brand, :in_stock, :conversions, :has_image, :total_on_hand, :purchasable, :taxon_ids]
      end

      def base.replace_indice
        ::Spree::Product.searchkick_index.replace_indice

        begin
          ::Spree::Product.includes(:representation).find_in_batches.each do |batch|
            batch.each do |product|
              product.reindex(nil, mode: :inline)
            end
          end
        rescue ActiveRecord::ActiveRecordError => e
          ActiveRecord::Base.connection.reconnect!
          sleep 3

          retry
        end
      end
    end

    def search_data
      taxons = {}
      presenter[:taxons].each do |t_path|
        t_path.each do |taxon|
          unless taxons.has_key?(taxon[:id])
            taxons[taxon[:id]] = taxon
          end
        end
      end
      properties = presenter[:properties]&.select {|prop| !prop[:value].blank? }
      if properties.nil?
        properties = []
      end
      json = {
          id: presenter[:id],
          name: presenter[:name],
          slug: presenter[:slug],
          description: presenter[:description],
          active: presenter[:available],
          in_stock: presenter[:in_stock],
          created_at: presenter[:created_at],
          updated_at: presenter[:updated_at],
          price: presenter[:price],
          currency: presenter[:currency],
          conversions: presenter[:conversions],
          taxon_ids: taxons.values.map {|t| t[:id] },
          taxon_names: taxons.values.map {|t| t[:name] },
          skus: presenter[:variants].map {|v| v[:sku] },
          total_on_hand: presenter[:total_on_hand],
          has_image: presenter[:images].blank? ? false : true,
          purchasable: presenter[:purchasable],
          property_ids: properties.map {|prop| prop[:id] },
          property_names: properties.map {|prop| prop[:name] },
          properties: properties.map {|prop| { id: prop[:id], name: prop[:name], value: prop[:value] } }
      }

      properties.each do |prop|
        json.merge!(Hash[prop[:name].downcase, prop[:value].downcase])
      end

      json
    end

    def default_variant_resp
      resp = presenter
      if resp[:has_only_default_variant]
        resp[:variants].first
      else
        variant = resp[:variants].find {|v| v[:purchasable] && (v[:in_stock] || v[:backorderable]) }
        variant = resp[:variants].first if variant.blank?
      end
    end
  end
end

::Spree::Product.prepend ::SpreeGraffiti::ProductDecorator