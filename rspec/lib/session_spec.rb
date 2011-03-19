require File.dirname(__FILE__) + '/../spec_helper'

describe Hubcap::Session do
  before :each do
    @session = Hubcap::Session.new(:repo => "scottwb/hubcap-test-repo")
    @session.labels.each{|label| @session.del_label(label)}
  end
  
  describe "#labels" do
    it "should return an empty array if the repository has no labels" do
      @session.labels.should be_empty
    end

    it "should return an array of labels in alphabetical order" do
      @session.add_label('foo')
      @session.add_label('bar')
      @session.add_label('zed')
      @session.labels.should == ['bar', 'foo', 'zed']
    end
  end

  describe "#add_label" do
    it "should add a new label only if it does not exist already" do
      orig_labels = @session.labels
      orig_labels.should_not include 'somelabel'

      new_labels = @session.add_label('somelabel')
      new_labels.should have(orig_labels.size + 1).labels
      new_labels.should include 'somelabel'

      @session.labels.should == new_labels
      @session.add_label('somelabel').should == new_labels
      @session.labels.should == new_labels
    end
  end

  describe "#del_label" do
    it "should delete a label only if it already exists" do
      orig_labels = @session.add_label('somelabel')
      orig_labels.should include 'somelabel'
      
      new_labels = @session.del_label('somelabel')
      new_labels.should_not include 'somelabel'
      new_labels.should have(orig_labels.size - 1).labels
      new_labels.should == orig_labels.reject{|l| l == 'somelabel'}

      @session.labels.should == new_labels
    end
  end

  describe "#users" do
    before :each do
      @session.add_label('foo')
    end

    it "should return an empty array if the repository has no users" do
      @session.users.should be_empty
    end

    it "should not return non-user labels as users" do
      @session.add_user('scottwb')
      @session.users.should == ['scottwb']
    end

    it "should return an array of users in alphabetical order" do
      @session.add_user('scottwb')
      @session.add_user('kate')
      @session.add_user('laurie')
      @session.users.should == ['kate', 'laurie', 'scottwb']
    end
  end

  describe "#add_user" do
    it "should add a new user only if it does not exist already" do
      orig_users = @session.users
      orig_users.should_not include 'someuser'

      new_users = @session.add_user('someuser')
      new_users.should have(orig_users.size + 1).users
      new_users.should include 'someuser'

      @session.users.should == new_users
      @session.add_user('someuser').should == new_users
      @session.users.should == new_users
    end
  end
end
