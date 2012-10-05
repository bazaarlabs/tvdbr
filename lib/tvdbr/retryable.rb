module Tvdbr
  class RetryableError < StandardError; end
  class Retryable
    # Code originally by Chu Yeow, see
    # http://blog.codefront.net/2008/01/14/retrying-code-blocks-in-ruby-on-exceptions-whatever/
    # Slightly rewritten to allow for passing of more than just type of exception.
    # retryable(:tries => 5, :on => Timeout::Error) do
    #   open('http://example.com/flaky_api')
    # end
    #
    # Tvdbr::Retryable.retry(:on => :timeout) { open('http://someplace.com/somefile.xml') }
    # Tvdbr::Retryable.retry(:on => MultiXml::ParseError) { parse("some/xml") }
    #
    def self.retry( options = {}, &block )
      opts = { :tries => 3, :on => Exception, :ignore => RetryableError, :log => false, :reraise => true }.merge(options)
      return nil if opts[:tries] == 0
      retry_exception, ignore_exception, tries = [ opts[:on] ].flatten, [ opts[:ignore] ].flatten, opts[:tries]

      begin
        return yield
      rescue *retry_exception => e
        puts "Error occurred - #{$!.class}: #{$!.message} [#{$!}], retrying..." if opts[:log]
        if (tries -= 1) > 0 # more tries
          retry
        elsif opts[:reraise] # failed too many times, raise
          raise RetryableError.new("#{e.to_s}: #{e.message} -- #{e.inspect}")
        end
      rescue *ignore_exception
        puts "Ignored occurred - #{$!.class}: #{$!.message} [#{$!}], Ignoring..." if opts[:log]
        return nil
      end

      yield
    end
  end
end