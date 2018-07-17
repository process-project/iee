# frozen_string_literal: true

module GitlabHelper
  def mock_gitlab_versions
    allow(Gitlab::Versions).
      to receive(:new).
      and_return(double(call: { branches: %w[b1 b2], tags: %w[t1 t2] }))
  end
end
