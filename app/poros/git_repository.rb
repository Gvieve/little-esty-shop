class GitRepository
    attr_reader :repo_name,
                :repo_commits,
                :repo_pull_requests

  def initialize
    @github_service = GithubService.new
    @repo_name ||= name
    @repo_usernames ||= usernames
    @repo_commits ||= commits
    @repo_pull_requests ||= pull_requests
  end

  private

  def name
    @github_service.get_data("")[:name]
  end

  def usernames
    @github_service.usernames.map do |key, value|
      key[:login]
    end.uniq[0..2]
  end

  def commits
     @repo_usernames.each_with_object({}) do |username, commits|
      commits[username] = @github_service.commits(username).count
    end
  end

  def pull_requests
     @github_service.pull_requests.count
  end
end
