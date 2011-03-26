module Octopi
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
  end
end
