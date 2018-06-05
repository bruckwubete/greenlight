# BigBlueButton open source conferencing system - http://www.bigbluebutton.org/.
#
# Copyright (c) 2016 BigBlueButton Inc. and by respective authors (see below).
#
# This program is free software; you can redistribute it and/or modify it under the
# terms of the GNU Lesser General Public License as published by the Free Software
# Foundation; either version 3.0 of the License, or (at your option) any later
# version.
#
# BigBlueButton is distributed in the hope that it will be useful, but WITHOUT ANY
# WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A
# PARTICULAR PURPOSE. See the GNU Lesser General Public License for more details.
#
# You should have received a copy of the GNU Lesser General Public License along
# with BigBlueButton; if not, see <http://www.gnu.org/licenses/>.

require 'bigbluebutton_api'
require 'digest/sha1'

class ApplicationController < ActionController::Base
  protect_from_forgery prepend: true
  before_action :authenticate_user!, if: proc { Rails.configuration.loadbalanced_configuration }

  before_action :set_locale
  #skip_before_action :verify_authenticity_token
  MEETING_NAME_LIMIT = 200
  USER_NAME_LIMIT = 100

  def set_locale
    I18n.locale = http_accept_language.language_region_compatible_from(I18n.available_locales)
  end

  def current_user
    @current_user ||=  User.where(:id => session[:user_id]).first
  end
  helper_method :current_user

  def relative_root
    Rails.configuration.relative_url_root || ""
  end
  helper_method :relative_root

  def meeting_name_limit
    MEETING_NAME_LIMIT
  end
  helper_method :meeting_name_limit

  def user_name_limit
    USER_NAME_LIMIT
  end
  helper_method :user_name_limit

  def bigbluebutton_endpoint_default?
    !Rails.configuration.loadbalanced_configuration && Rails.configuration.bigbluebutton_endpoint_default == Rails.configuration.bigbluebutton_endpoint
  end
  helper_method :bigbluebutton_endpoint_default?

  def qrcode_generation_enabled?
    Rails.configuration.enable_qrcode_generation
  end
  helper_method :qrcode_generation_enabled?

  def authenticate_user!
    sign_in(current_user) if current_user
    if user_signed_in?
      super
    else
      super
    end
  end

  def omniauth_authorize_path(resource_name, provider)
    send "#{resource_name}_omniauth_authorize_path", provider
  end

  def is_flashing_format?
    false
  end

end
