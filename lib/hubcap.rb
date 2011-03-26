
#
# Docs: https://github.com/fcoury/octopi
#
require 'octopi'
require 'octopi_ext'
require 'ap'

module Hubcap
  extend Octopi

  def Hubcap.load_gitconfig
    read_gitconfig
  end

  class Session
    def initialize(opts = {})
      config    = Hubcap.load_gitconfig

      @username = (config['github']['user'] rescue nil) || opts[:username]
      @token    = (config['github']['token'] rescue nil) || opts[:token]

      repo_path = opts[:repo] || raise("Must specify :repo")
      repo_parts = repo_path.split('/')
      repo_name  = repo_parts[-1]
      repo_user  = (repo_parts.size > 1) ? repo_parts.first : @username
      @repo = exec do
        Octopi::Repository.find(:user => repo_user, :name => repo_name)
      end
      raise "Invalid repo: #{repo_path}" if @repo.nil?
    end

    def exec(&block)
      Hubcap.authenticated_with({:login => @username, :token => @token}, &block)
    end

    ##############################
    # Issues
    ##############################
    def issues(opts = {})
      state            = opts[:state] || 'open'
      filter_by_labels = opts[:labels]
      
      issues = exec do
        Octopi::Issue.find_all(:repo => @repo, :state => state)
      end

      if filter_by_labels
        issues.reject!{|i| (filter_by_labels - i.labels).any?}
      end

      return issues
    end

    def add_issue(opts = {})
      params = {}
      params[:title] = opts[:title] if opts[:title]
      params[:body]  = opts[:description] if opts[:description]
      exec do
        Octopi::Issue.open(
          :repo   => @repo,
          :params => params
        )
      end
    end

    ##############################
    # Labels
    ##############################
    def labels
      exec{Octopi::Issue.labels(:repo => @repo)}['labels'].sort
    end

    def add_label(label)
      exec{Octopi::Issue.add_label(:repo => @repo, :label => label)}['labels'].sort
    end

    def del_label(label)
      exec{Octopi::Issue.del_label(:repo => @repo, :label => label)}['labels'].sort
    end
    

    ##############################
    # Users
    ##############################
    def user_to_label(user)
      "user-#{user}"
    end

    def user_from_label(label)
      label[/^user-(.+)/,1]
    end

    def users
      labels.map{|label| user_from_label(label)}.compact
    end

    def add_user(user)
      add_label(user_to_label(user)).map{|label| user_from_label(label)}.compact
    end

    def del_user(user)
      del_label(user_to_label(user)).map{|label| user_from_label(label)}.compact
    end
  end
end
