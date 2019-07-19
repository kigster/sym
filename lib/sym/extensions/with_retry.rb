module Sym
  module Extensions
    module WithRetry

      def with_retry(retries: 3, fail_block: nil)
        attempts = 0
        yield if block_given?
      rescue StandardError => e
        raise(e) if attempts >= retries
        fail_block.call if fail_block
        attempts += 1
        retry
      end
    end
  end
end

