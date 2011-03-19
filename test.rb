#!/usr/bin/env ruby

require 'rubygems'
require 'bundler/setup'

require 'ap'
require './lib/hubcap'

TEST_REPO = "scottwb/hubcap-test-repo"

@session = Hubcap::Session.new(:repo => TEST_REPO)

def test_label_list
  puts
  puts "This repo has the following labels:"
  ap @session.labels
end

def test_add_label
  puts
  puts "Adding a 'defect' label"
  ap @session.add_label('defect')
end

def test_del_label
  puts
  puts "Removing the 'defect' label"
  ap @session.del_label('defect')
end

def test_user_list
  puts
  puts "This repo has the following users:"
  ap @session.users
end

def test_add_user
  puts
  puts "Adding a 'scottwb' user"
  ap @session.add_user('scottwb')
end

def test_del_user
  puts
  puts "Removing the 'scottwb' user"
  ap @session.del_user('scottwb')
end

def test_issue_filter
  puts
  puts "Scottwb has the following defects on this repo:"
  @session.issues(:labels => ["scottwb", "defect"]).each do |issue|
    puts "#{issue.number}) #{issue.title}"
    puts "  State:  #{issue.state}"
    puts "  Labels: #{issue.labels.join(',')}"
    puts
  end
end

############################################################

# Label tests
test_label_list
test_add_label
test_label_list
test_del_label
test_label_list

# User tests
test_user_list
test_add_user
test_user_list
test_del_user
test_user_list

# Issue tests
test_issue_filter
