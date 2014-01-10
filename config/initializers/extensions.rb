class String
  def initcaps
    arr = ['or', 'and', 'is', 'in', 'at', 'a', 'an', 'the']
    self.split(' ').map {|w| (arr.index(w).nil? ? w.capitalize : w.downcase) }.join(' ')
  end
end

module ActiveSupport
  module Cache
    class RedisStore < Store
      def delete(key, options)
        delete_matched(key, options)
      end
    end
  end
end
