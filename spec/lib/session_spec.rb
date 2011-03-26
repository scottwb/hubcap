require File.dirname(__FILE__) + '/../spec_helper'

describe Hubcap::Session do
  before :each do
    @session = Hubcap::Session.new(:repo => "scottwb/hubcap-test-repo")
  end

  ############################################################
  # Label Methods
  ############################################################
  describe "Label Methods" do
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

      it "should remove that label from all issues" do
        pending
      end
    end
  end


  ############################################################
  # User Methods
  ############################################################
  describe "User Methods" do
    describe "#users" do
      before :each do
        @session.labels.each{|label| @session.del_label(label)}
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

    describe "#del_user" do
      it "should delete a user only if it already exists" do
        pending
      end
    end
  end


  ############################################################
  # Issues Methods
  ############################################################
  describe "Issue Methods" do
    before :each do
      @session.issues.each{|issue| issue.close!}
    end

    describe "#issues" do
      it "should return all open issues for the repository by default" do
        @session.issues.should be_empty
        
        @session.add_issue(:title => "Test Issue 1")
        @session.add_issue(:title => "Test Issue 2").close!
        @session.add_issue(:title => "Test Issue 3")

        issues = @session.issues
        issues.should have(2).issues
        issues.map{|i| i.title}.should include "Test Issue 1"
        issues.map{|i| i.title}.should_not include "Test Issue 2"
        issues.map{|i| i.title}.should include "Test Issue 3"
      end

      it "should be able to return all closed issues for the repository" do
        prefix = Digest::MD5.hexdigest(Time.now.to_s)[0,8]

        @session.add_issue(:title => "Test Issue #{prefix}.1").close!
        @session.add_issue(:title => "Test Issue #{prefix}.2")
        @session.add_issue(:title => "Test Issue #{prefix}.3").close!
        
        # Get all the closed issues, then filter to just the ones we
        # made for this test case, since closed issues on github stay
        # around forever.
        closed_issues = @session.issues(:state => 'closed').select do |issue|
          issue.title =~ /^Test Issue #{prefix}\.\d$/
        end
        closed_issues.should have(2).issues
        closed_issues.map{|i| i.title}.should include "Test Issue #{prefix}.1"
        closed_issues.map{|i| i.title}.should_not include "Test Issue #{prefix}.2"
        closed_issues.map{|i| i.title}.should include "Test Issue #{prefix}.3"
      end

      it "should sort issues by number by default" do
        pending
      end

      it "should be able to sort issues by priority" do
        pending
      end

      it "should be able to sort issues by votes" do
        pending
      end

      it "should be able to sort issues by creation time" do
        pending
      end

      it "should be able to sort issues by last-updated time" do
        pending
      end

      it "should be able to filter issues by label" do
        pending
      end

      it "should be able to filter issues by multiple labels" do
        pending
      end

      it "should be able to filter issues by user" do
        pending
      end
    end

    describe "#add_issue" do
      it "should create a new open issue, with no user or labels by default" do
        existing_issues = @session.issues

        issue = @session.add_issue(
          :title       => "New Issue",
          :description => "This is a new issue."
        )
        issue.should_not be_nil
        issue.title.should == "New Issue"
        issue.body.should == "This is a new issue."
        issue.number.should > existing_issues.size
        existing_issues.map{|i| i.number}.should_not include issue.number

        new_issues = @session.issues
        new_issues.should have(existing_issues.size + 1).issues
        new_issues.map{|i| i.number}.should include issue.number
        
        new_issue = new_issues.find{|i| i.number == issue.number}
        new_issue.title.should == issue.title
        new_issue.body.should == issue.body

        issue.close!
        orig_issues = @session.issues
        orig_issues.should == existing_issues
      end

      it "should be able to create a new open issue with a user and labels" do
        pending
      end
    end

    describe "#find_issue" do
      it "should be able to find an issue by number" do
        issue = @session.find_issue(1)
        issue.should_not be_nil
        issue.should be_an Octopi::Issue
        issue.number.should == 1
        issue.state.should == 'closed'
      end

      it "should return nil if the issue is not found" do
        @session.find_issue(99999).should be_nil
      end

      it "should return an authenticated instance of Octopi::Issue" do
        prefix = Digest::MD5.hexdigest(Time.now.to_s)[0,8]

        issue = @session.find_issue(1)
        issue.state.should == 'closed'

        # Test that we can do this w/o explicit auth.
        issue.reopen!
        issue = @session.find_issue(1)
        issue.state.should == 'open'

        issue.title = "Title for save test #{prefix}"
        issue.body  = "Body for save test #{prefix}"
        issue.save
        issue = @session.find_issue(1)
        issue.state.should == 'open'
        issue.title.should == "Title for save test #{prefix}"
        issue.body.should == "Body for save test #{prefix}"

        issue.comment("Test comment for #{prefix}")
        issue = @session.find_issue(1)
        comments = issue.comments
        comments.map(&:body).should include "Test comment for #{prefix}"
        comments.last.body.should == "Test comment for #{prefix}"

        issue.labels.should_not include prefix
        issue.add_label(prefix)
        issue.labels.should include prefix
        issue = @session.find_issue(1)
        issue.labels.should include prefix

        issue.remove_label(prefix)
        issue.labels.should_not include prefix
        issue = @session.find_issue(1)
        issue.labels.should_not include prefix

        @session.del_label(prefix)

        # Test that we can do this w/o explicit auth.
        issue.close!
        issue = @session.find_issue(1)
        issue.state.should == 'closed'
      end
    end
  end
end
