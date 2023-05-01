class LogAsyncJob < ApplicationJob
  queue_as :async_log

  def perform(user_id)
    user = User.find(user_id)
    Rails.logger.info("ユーザー登録が完了しました: #{user.email}")
  end
end
