module Kernel
  def require_dir(___dir)
    @___dir ||= File.dirname(__FILE__)
    # require files using a consistent order based on the dir/file name.
    # this should be OS-neutral
    Dir["#{@___dir}/#{___dir}/*.rb"].sort.each do |___file|
      require(___file)
    end
  end
end

class Object
  unless self.methods.include?(:present?)
    def present?
      return false if self.nil?
      if self.is_a?(String) && (self == '')
        return false
      end
      true
    end
  end
end

