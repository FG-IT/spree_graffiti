module Graffiti
  module Spree
    module FrontendHelper
      @image_resize_endpoint = nil

      def image_resize_endpoint
        if ENV['IMAGE_RESIZE_ENDPOINT'].present?
          @image_resize_endpoint ||= ENV['IMAGE_RESIZE_ENDPOINT']
        elsif ENV['IMAGE_RESIZING_URL'].present?
          @image_resize_endpoint ||= ENV['IMAGE_RESIZING_URL']
        else
          @image_resize_endpoint ||= SpreeGraffiti::Config['image_resize_endpoint']
        end
      end

      def image_resize_url(url, width: nil, height: nil, format: 'jpg')
        if width.blank?
          "#{image_resize_endpoint}#{url}?format=#{format}"
        elsif height.blank?
          "#{image_resize_endpoint}#{url}?width=#{width}&format=#{format}"
        else
          "#{image_resize_endpoint}#{url}?width=#{width}&height=#{height}&format=#{format}"
        end
      end

      def style_image(url, style:, format: 'jpg')
        size = ::Spree::Image.styles[style]
        width, height = ::Spree::Image.unify_size(size)
        {
          url: image_resize_url(url, width: width, height: height, format: format),
          width: width,
          height: height
        }
      end

      def small_image(url, format: 'jpg')
        style_image(url, style: :small, format: format)
      end

      def list_image(url, format: 'jpg')
        style_image(url, style: :list, format: format)
      end

      def large_image(url, format: 'jpg')
        style_image(url, style: :large, format: format)
      end

      def zoom_image(url, format: 'jpg')
        style_image(url, style: :zoom, format: format)
      end

      def lazy_image_fixed(src:, alt:, width:, height:, srcset: '', **options)
        # We need placeholder image with the correct size to prevent page from jumping
        placeholder = "data:image/svg+xml,%3Csvg%20xmlns='http://www.w3.org/2000/svg'%20viewBox='0%200%20#{width}%20#{height}'%3E%3C/svg%3E"

        image_tag placeholder, data: {src: src, srcset: srcset}, class: "#{options[:class]} lazyload", alt: alt, width: width, height: height
      end

      def product_summary(product)
        {
          name: product.presenter[:name],
          images: product.presenter[:images].map do |img|
            image = list_image(img[:resize_url])
            {url_product: image[:url]}
          end
        }
      end

      def product_variants(product)
        product.presenter[:variants].map do |variant|
          images = variant[:images].map do |image|
            img = list_image(image[:resize_url])
            {alt: image[:alt], url_product: img[:url]}
          end

          option_values = variant[:option_values].map {|ov| {id: ov[:id], name: ov[:name], presentation: ov[:presentation]} }

          {
            id: variant[:id],
            sku: variant[:sku],
            purchasable: variant[:purchasable],
            display_price: variant[:display_price],
            price: variant[:price],
            display_compare_at_price: variant[:display_compare_at_price],
            should_display_compare_at_price: !variant[:compare_at_price].blank? && (variant[:compare_at_price] > variant[:price]),
            is_product_available_in_currency: product.presenter[:available],
            backorderable: variant[:backorderable],
            in_stock: variant[:in_stock],
            images: images,
            option_values: option_values,
          }
        end
      end
    end
  end
end