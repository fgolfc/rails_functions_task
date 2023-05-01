class UserMailer < ApplicationMailer
  default from: 'admin@example.com' # 送信元アドレスを指定

  def welcome_email(mail_params)
    @user = mail_params[:user]
    @to = mail_params[:to]
    mail(to: @to, subject: '登録完了') # タイトルに"登録完了"を表示
  end
end
