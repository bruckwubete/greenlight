# frozen_string_literal: true

class Users::OmniauthCallbacksController < Devise::OmniauthCallbacksController
  # You should configure your model like this:
  # devise :omniauthable, omniauth_providers: [:twitter]

  # You should also create an action method in this controller like this:
  # def twitter
  # end

  # More info at:
  # https://github.com/plataformatec/devise#omniauth

  # GET|POST /resource/auth/twitter
  # def passthru
  #   super
  # end

  # GET|POST /users/auth/twitter/callback
  # def failure
  #   super
  # end

  # protected

  # The path used when OmniAuth fails
  # def after_omniauth_failure_path_for(scope)
  #   super(scope)
  # end
  #
  def saml
    user = User.from_omniauth(request.env["omniauth.auth"])
    session[:user_id] = user.id
    sign_in(user)
    redirect_to meeting_room_url(resource: 'rooms', id: user.encrypted_id)
  rescue => e
    logger.error "Error authenticating via omniauth: #{e}"
    redirect_to root_path
  end

  def google
    user = User.from_omniauth(request.env["omniauth.auth"])
    session[:user_id] = user.id
    sign_in(user)
    redirect_to meeting_room_url(resource: 'rooms', id: user.encrypted_id)
  rescue => e
    logger.error "Error authenticating via omniauth: #{e}"
    redirect_to root_path
  end
end
