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

class User < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable, :validatable, :omniauthable, omniauth_providers: %i[saml google]

  before_create :set_encrypted_id
  has_attached_file :background
  validates_attachment :background,
                       :content_type => { :content_type => ["image/jpg", "image/jpeg", "image/gif", "image/png"] }

  def self.from_omniauth_params(auth)
    user = find_or_initialize_by(uid: auth['uid'], provider: auth['provider'])
    user.name = auth["name"]
    user.username = auth["username"]
    user.email = auth["email"]
    user.password = auth['password']
    user.encrypted_id = "#{user.username}-#{Digest::SHA1.hexdigest(user.uid+user.provider)[0..7]}"
    user.customer_info = auth["customer_info"]
    user.save!
    user
  end
  def self.from_omniauth(auth)
    user = find_or_initialize_by(uid: auth['uid'], provider: auth['provider'])
    user.name = send("#{auth['provider']}_name", auth)
    user.username = send("#{auth['provider']}_username", auth)
    user.email = send("#{auth['provider']}_email", auth)
    user.password = SecureRandom.urlsafe_base64
    user.encrypted_id = "#{user.username}-#{Digest::SHA1.hexdigest(user.uid+user.provider)[0..7]}"
    user.save!
    user
  end


  # Provider attributes.
  def self.saml_name(auth)
    auth['info']['first_name'] + ' ' + auth['info']['last_name']
  end

  def self.saml_username(auth)
    auth['extra']['raw_info']['displayName']
  end

  def self.saml_email(auth)
    auth['info']['email']
  end

  def self.twitter_username(auth_hash)
    auth_hash['info']['nickname']
  end

  def self.twitter_email(auth_hash)
    auth_hash['info']['email']
  end

  def self.google_name(auth)
    auth['info']['name']
  end

  def self.google_username(auth_hash)
    auth_hash['info']['email'].split('@').first
  end

  def self.google_email(auth_hash)
    auth_hash['info']['email']
  end

  def self.ldap_username(auth_hash)
    auth_hash['info']['nickname']
  end
  
  def self.ldap_email(auth_hash)
    auth_hash['info']['email']
  end

  def self.saml_username(auth_hash)
    auth_hash['info']['nickname']
  end
  
  def self.saml_email(auth_hash)
    auth_hash['info']['email']
  end

  def set_encrypted_id
    self.encrypted_id = "#{username[0..1]}-#{Digest::SHA1.hexdigest(uid+provider)[0..7]}"
  end
end
