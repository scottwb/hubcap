require File.dirname(__FILE__) + '/../spec_helper'

describe Hubcap::Session do
  before :each do
    @session = Hubcap::Session.new(:repo => "scottwb/hubcap-test-repo")
  end
  
  describe "#labels" do
    before :each do
      @session.labels.each{|label| @session.del_label(label)}
    end

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
end
