module BigfishPayment

  module Helpers

    module GetObject
      # Gets the provided <tt>klass</tt> object by the provided <tt>param</tt> parameter
      def get_object(klass, param)
        obj = case param
          when klass
            param

          when Numeric
            begin
              klass.find(param.to_i)
            rescue ActiveRecord::RecordNotFound
              nil
            end

          when String
            klass.find_by_code(param)

          else
            nil
        end

        raise ArgumentError, "Could not find #{klass} '#{param}'" unless obj
        raise ArgumentError, "#{obj} is disabled" unless obj.enabled?

        obj
      end
    end

  end

end
