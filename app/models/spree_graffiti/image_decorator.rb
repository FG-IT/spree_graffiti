module SpreeGraffiti
  module ImageDecorator
    module ClassMethods
      def styles
        {
            mini: '48x48>',
            small: '100x100>',
            product: '270x270>',
            list: '270x270>',
            large: '650x650>',
            zoom: '1044x1044>'
        }
      end

      def dimensions
        sizes = {}
        styles.each do |name, size|
          width, height = unify_size(size)
          sizes[name.to_sym] = {width: width, height: height}
        end

        sizes
      end

      def unify_size(size)
        if size.is_a?(String)
          if size.ends_with?('>')
            size = size.chop.split('x')
          else
            size = size.split('x')
          end
        end
        if size.is_a?(Array) && size.size == 2
          return size
        else
          raise 'size is not in right format'
        end
      end
    end

    def self.prepended(base)
      base.inheritance_column = nil
      base.singleton_class.prepend ClassMethods
    end
  end
end

::Spree::Image.prepend ::SpreeGraffiti::ImageDecorator
