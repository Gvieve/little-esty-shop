class ApplicationController < ActionController::Base
before_action :git_repo

  def git_repo
    @repo = GitRepository.new
  end
end
