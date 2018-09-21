require 'rubygems'
require 'json'

class SiteBanner < ApplicationRecord
  include Rails.application.routes.url_helpers
  has_one_attached :logo
  has_one_attached :background_image
  belongs_to :publisher

  LOGO = "logo".freeze
  LOGO_DIMENSIONS = "148x148".freeze
  LOGO_UNIVERSAL_FILE_SIZE = 20_000

  BACKGROUND = "background".freeze
  BACKGROUND_DIMENSIONS = "900x176".freeze
  BACKGROUND_UNIVERSAL_FILE_SIZE = 200_000

  def read_only_react_property
    {
      title: self.title,
      description: self.description,
      backgroundUrl: url_for(self.background_image),
      logoUrl: url_for(self.logo),
      donationAmounts: self.donation_amounts,
      socialLinks: self.social_links
    }
  end

  def url_for(object)
    return nil if object.nil? || object.attachment.nil?

    extension = if object.blob.content_type == "image/png"
                  ".png"
                elsif object.blob.content_type.in?(['image/jpg', 'image/jpeg'])
                  ".jpeg"
                end

    if Rails.env.development? || Rails.env.test?
      # (Albert Wang): I couldn't figure out how to play nicely with localhost
      "https://localhost:3000" + rails_blob_path(object, only_path: true) + extension
    else
      "#{Rails.application.secrets[:s3_rewards_public_domain]}/#{object.blob.key}"
    end
  end
end
