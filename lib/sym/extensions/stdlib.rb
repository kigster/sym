# frozen_string_literal: true

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
  unless methods.include?(:present?)
    def present?
      return false if nil?

      if is_a?(String)
        return false if self == ''
      end
      true
    end
  end
end
