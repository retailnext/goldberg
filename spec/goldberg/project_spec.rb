require "spec_helper"

describe Goldberg::Project do
  it "checks out a new git project" do
    Goldberg::Paths.stub!(:projects).and_return('some_path')
    Git.should_receive(:clone).with('git://some.url.git', 'some_project', :path => 'some_path')
    project = Goldberg::Project.add({:url => "git://some.url.git", :name => 'some_project'})
    project.name.should == 'some_project'
    project.url.should == 'git://some.url.git'
  end
end
