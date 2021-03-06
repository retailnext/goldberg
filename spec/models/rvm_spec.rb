require "spec_helper"

describe RVM do
  before(:each) do
    Env.stub!(:[]).with('HOME').and_return('home')
  end

  paths = {'user' => 'home/.rvm/scripts/rvm', 'server' => '/usr/local/rvm/scripts/rvm',}
  context "installed?" do
    paths.each do |installation_type, path|
      context "for #{installation_type}" do
        before(:each) do
          File.stub!(:exist?).with(paths['user']).and_return(false) if installation_type == 'server'
          File.stub!(:exist?).with(path).and_return(true)
        end

        it "writes the required rvmrc contents" do
          Environment.should_receive(:write_file).with('home/.rvmrc', "rvm_install_on_use_flag=1\nrvm_gemset_create_on_use_flag=1\n")
          RVM.write_ci_rvmrc_contents
        end

        it "prepares a gemset with bundler" do
          expect_command(
            "source #{path} && rvm use --create project@global && (gem list | grep bundler) || gem install bundler",
            :execute => true)
          RVM.prepare_ruby('project')
        end

        it "marks the .rvmrc as trusted" do
          expect_command('rvm rvmrc trust code_path', :execute => true)
          RVM.trust_rvmrc('code_path')
        end

        it "generates an 'rvm use' script" do
          RVM.use_script('ruby', 'a_gemset').should == "source #{path} && rvm use --create ruby@a_gemset"
        end
      end
    end
  end

  context "not installed?" do
    it "generates a nil 'rvm use' script" do
      File.stub!(:exist?).with(paths['user']).and_return(false)
      File.stub!(:exist?).with(paths['server']).and_return(false)
      RVM.use_script('ruby', 'a_gemset').should be_nil
    end
  end
end
