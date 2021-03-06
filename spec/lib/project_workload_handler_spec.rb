require 'spec_helper'

describe ProjectWorkloadHandler do

  let(:handler) { ProjectWorkloadHandler.new(project) }
  let(:project) { double.as_null_object }

  let(:workload) { double }

  describe '#workload_created' do
    after { handler.workload_created(workload) }

    before { workload.stub(:add_job) }

    it 'should add the feed_url' do
      workload.should_receive(:add_job).with(:feed_url, project.feed_url)
    end

    it 'should add the build_status_url' do
      workload.should_receive(:add_job).with(:build_status_url, project.build_status_url)
    end
  end

  describe '#workload_complete' do
    let(:workload) { double.as_null_object }

    after { handler.workload_complete(workload) }

    it 'should set status content' do
      workload.should_receive(:recall).with(:feed_url)
    end

    it 'should set build status content' do
      workload.should_receive(:recall).with(:build_status_url)
    end

  end

  describe '#workload_failed' do
    let(:error) { double }

    before do
      error.stub(:message).and_return("message")
      error.stub(:backtrace).and_return(["backtrace","more"])
    end

    after { handler.workload_failed(workload, error) }

    it 'should add a log entry' do
      project.payload_log_entries.should_receive(:build)
      .with(error_type: "RSpec::Mocks::Mock", error_text: "message", update_method: "Polling", status: "failed", :backtrace=>"message\nbacktrace\nmore")
    end

    it 'should set building to false' do
      project.should_receive(:building=).with(false)
    end

    it 'should set online to false' do
      project.should_receive(:online=).with(false)
    end

    it 'should save the project' do
      project.should_receive :save!
    end

  end

end
