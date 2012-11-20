assign_sub_rb = '/../../lib/analytics/assignment_submission_date'
require 'mocha_standalone'
require 'active_support/core_ext'
require File.expand_path(File.dirname(__FILE__) + assign_sub_rb)

module Analytics

  describe AssignmentSubmissionDate do
    let(:time1) { Time.utc(2012, 12, 4, 20) }
    let(:time2) { Time.utc(2012, 10, 1, 16) }

    let(:user) { user = "user"; def user.id; 1 end; user }
    let(:assignment) { stub() }
    let(:submission) { stub(:user => user) }
    let(:assign_sub) { AssignmentSubmissionDate.new(assignment, user, submission) }

    it "initializes" do
      AssignmentSubmissionDate.new(assignment, user, submission)
    end

    it "memoizes VariedDueDate objects by user" do
      assign_sub.expects(:varied_due_date_unmemoized).returns(:something).once
      assign_sub.send(:varied_due_date)
      assign_sub.send(:varied_due_date)
    end

    it "returns a best-effort submission date - submitted_at" do
      submission.stubs(:submitted_at => time1)
      assign_sub.submission_date.should == time1
    end

    it "returns a best-effort submission date - varied_due_date" do
      assign_sub.expects(:varied_due_date).
        returns(stub(:due_at => time2)).once
      assignment.stubs(:submittable_type? => false)
      submission.stubs(
        :submitted_at => nil,
        :graded? => true,
        :user => user)
      assign_sub.submission_date.should == time2
    end

    it "returns a best-effort submission date - graded_at" do
      submission.stubs(
        :submitted_at => nil,
        :graded? => false,
        :graded_at => time2)
      assign_sub.submission_date.should == time2
    end

    it "returns a best-effort submission date - nil when none available" do
      submission.stubs(
        :submitted_at => nil,
        :graded? => false,
        :graded_at => nil)
      assign_sub.submission_date.should be_nil
    end
  end

end