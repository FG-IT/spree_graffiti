module SpreeGraffiti
  module ProductDecorator
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