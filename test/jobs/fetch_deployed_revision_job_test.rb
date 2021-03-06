require 'test_helper'

class FetchDeployedRevisionJobTest < ActiveSupport::TestCase
  setup do
    @stack = stacks(:shipit)
    @job = FetchDeployedRevisionJob.new
    @commit = commits(:fifth)
  end

  test 'the job abort if the stack is deploying' do
    @stack.expects(:deploying?).returns(true)
    assert_no_difference 'Deploy.count' do
      @job.perform(@stack)
    end
  end

  test 'the job abort if #fetch_deployed_revision returns nil' do
    @stack.expects(:deploying?).returns(false)
    StackCommands.any_instance.expects(:fetch_deployed_revision).returns(nil)
    @stack.expects(:update_deployed_revision).never
    @job.perform(@stack)
  end

  test 'the job call update_deployed_revision if #fetch_deployed_revision returns something' do
    @stack.expects(:deploying?).returns(false)
    StackCommands.any_instance.expects(:fetch_deployed_revision).returns(@commit.sha)
    @stack.expects(:update_deployed_revision).with(@commit.sha)
    @job.perform(@stack)
  end
end
