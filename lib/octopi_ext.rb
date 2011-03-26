module Octopi
  # Copy-and-paste of Octopi::Api#submit, plus the patch to fix
  # Octopi Issue #55: https://github.com/fcoury/octopi/issues#issue/55
  # as seen in this commit:
  #
  #   https://github.com/fcoury/octopi/commit/ac180183
  #
  class Api
    def submit(path, params = {}, klass=nil, format = :yaml, &block)
      # Ergh. Ugly way to do this. Find a better one!
      cache = params.delete(:cache) 
      cache = true if cache.nil?
      cache = false
      params.each_pair do |k,v|
        if path =~ /:#{k.to_s}/
          params.delete(k)
          path = path.gsub(":#{k.to_s}", v)
        end
      end
      begin
        key = "#{Api.api.class.to_s}:#{path}"
        resp = if cache
          APICache.get(key, :cache => 61) do
            yield(path, params, format, auth_parameters)
          end
        else
          yield(path, params, format, auth_parameters)
        end
      rescue Net::HTTPBadResponse
        raise RetryableAPIError
      end     
      
      raise RetryableAPIError, resp.code.to_i if RETRYABLE_STATUS.include? resp.code.to_i
      # puts resp.code.inspect
      raise NotFound, klass || self.class if resp.code.to_i == 404
      raise APIError, 
        "GitHub returned status #{resp.code}" unless (resp.code.to_i == 200) || (resp.code.to_i == 201)
      # FIXME: This fails for showing raw Git data because that call returns
      # text/html as the content type. This issue has been reported.
      
      # It happens, in tests.
      return resp if resp.headers.empty?
      content_type = Array === resp.headers['content-type'] ? resp.headers['content-type'] : [resp.headers['content-type']]
      ctype = content_type.first.split(";").first
      raise FormatError, [ctype, format] unless CONTENT_TYPE[format.to_s].include?(ctype)
      if format == 'yaml' && resp['error']
        raise APIError, resp['error']
      end  
      resp
    end
  end
  
  # Extend Octopi::Issue with a few class methods we'd like to have.
  class Issue
    def self.labels(options = {})
      ensure_hash(options)
      user, repo = gather_details(options)
      Api.api.get("/issues/labels/#{user}/#{repo}")
    end

    def self.add_label(options = {})
      ensure_hash(options)
      user, repo = gather_details(options)
      Api.api.get("/issues/label/add/#{user}/#{repo}/#{options[:label]}")
    end

    def self.del_label(options = {})
      ensure_hash(options)
      user, repo = gather_details(options)
      Api.api.get("/issues/label/remove/#{user}/#{repo}/#{options[:label]}")
    end

    attr_accessor :hubcap_session

    method = :close!
    authed_method   = "authed_#{method}".to_sym
    unauthed_method = "unauthed_#{method}".to_sym
    define_method(authed_method) do
      hubcap_session.exec{send(unauthed_method)}
    end
    alias_method unauthed_method, method
    define_method(method) do
      send(hubcap_session ? authed_method : unauthed_method)
    end

  end
end
