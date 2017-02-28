module Sym
  module App
    module Password
      module Providers

        class << self
          attr_accessor :registry
          attr_accessor :providers
          attr_accessor :detected

          def register(provider_class)
            self.registry                        ||= {}
            registry[short_name(provider_class)] = provider_class
            self.providers                       ||= []
            self.providers << provider_class
          end

          # Detect first instance that is "alive?" and return it.
          def detect
            self.detected ||= self.providers.inject(nil) do |instance, provider_class|
              instance || (p = provider_class.new; p.alive? ? p : nil)
            end
          end

          def provider(p = nil, **opts, &block)
            provider_from_argument(p, **opts, &block) || detect
          end

          def provider_list
            registry.keys.map(&:to_s).join(', ')
          end

          private

          def short_name(klass)
            klass.name.gsub(/.*::(\w+)Provider/, '\1').downcase.to_sym
          end

          def provider_from_argument(p, **opts, &block)
            case p
              when String, Symbol
                provider_class_name = "#{p.to_s.capitalize}Provider"
                Sym::App::Password::Providers.const_defined?(provider_class_name) ?
                  Sym::App::Password::Providers.const_get(provider_class_name).new(**opts, &block) :
                  nil
            end
          end
        end
      end
    end
  end
end

# Order is important — they are tried in this order for auto detect
require 'sym/app/password/providers/memcached_provider'
require 'sym/app/password/providers/drb_provider'
