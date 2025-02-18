# frozen_string_literal: true

module Decidim
  module Votings
    module Census
      module Admin
        class ExportAccessCodesJob < ApplicationJob
          queue_as :default

          def perform(dataset, user)
            filename = "#{SecureRandom.urlsafe_base64}.zip"
            path = Rails.root.join("tmp/#{filename}")
            password = SecureRandom.urlsafe_base64

            ActiveRecord::Base.transaction do
              UpdateDataset.call(dataset, { status: :exporting_codes }, user)

              generate_zip_file(dataset, path, password)
              save_or_upload_file(dataset, path)
              ExportMailer.access_codes_export(user, dataset.voting, filename, password).deliver_later

              UpdateDataset.call(dataset, { status: :freeze }, user)
            end
          end

          private

          def generate_zip_file(dataset, path, password)
            AccessCodesExporter.new(dataset, path, password).export
          end

          # Saves to file system or uploads to storage service depending on the configuration.
          def save_or_upload_file(dataset, path)
            Decidim::Votings::Census::VotingCensusUploader.new(dataset).store!(File.open(path, "rb"))
          end
        end
      end
    end
  end
end
