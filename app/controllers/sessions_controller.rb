class SessionsController < ApplicationController
  def new
    redirect_to tasks_path if current_user
  end

  def create
    user = User.find_by(email: params[:email])
    if user&.authenticate(params[:password])
      session[:user_id] = user.id
      redirect_to tasks_path(user), notice: "ログインに成功しました。"
    else
      flash.now[:alert] = "メールアドレスまたはパスワードが正しくありません。"
      render :new, status: :unprocessable_entity
    end
  end

  def destroy
    session.delete(:user_id)
    redirect_to login_path, notice: "ログアウトしました。"
  end


  def google_login
    client = OAuth2::Client.new(
      ENV["GOOGLE_CLIENT_ID"],
      ENV["GOOGLE_CLIENT_SECRET"],
      site: "https://accounts.google.com",
      authorize_url: "/o/oauth2/auth",
      token_url: "/o/oauth2/token"
    )
    redirect_to client.auth_code.authorize_url(
      redirect_uri: "http://localhost:3000/auth/google/login/callback",
      scope: "email profile",
      prompt: "consent"
    ), allow_other_host: true
  end

  def google_callback
    client = OAuth2::Client.new(
      ENV["GOOGLE_CLIENT_ID"],
      ENV["GOOGLE_CLIENT_SECRET"],
      site: "https://accounts.google.com",
      authorize_url: "/o/oauth2/auth",
      token_url: "/o/oauth2/token"
    )
    token = client.auth_code.get_token(params[:code], redirect_uri: "http://localhost:3000/auth/google/login/callback")
    user_info = JSON.parse(token.get("https://www.googleapis.com/oauth2/v2/userinfo").body)

    user = User.find_or_create_by(provider: "google", uid: user_info["id"]) do |u|
      u.name = user_info["name"]
      u.email = user_info["email"]
      u.password = SecureRandom.hex(16)
    end

    session[:user_id] = user.id
    redirect_to tasks_path, notice: "ログインしました。"
  end
end
