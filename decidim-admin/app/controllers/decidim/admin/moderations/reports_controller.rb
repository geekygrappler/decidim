# frozen_string_literal: true

module Decidim
  module Admin
    module Moderations
      # This controller allows admins to manage reports in a moderation.
      class ReportsController < Decidim::Admin::ApplicationController
        helper_method :moderation, :reports

        def index
          enforce_permission_to :read, :moderation
        end

        def show
          enforce_permission_to :read, :moderation
          @report = reports.find(params[:id])
        end

        private

        def reports
          @reports ||= moderation.reports
        end

        def moderation
          @moderation ||= participatory_space_moderations.find(params[:moderation_id])
        end

        def participatory_space_moderations
          @participatory_space_moderations ||= Decidim::Moderation.where(participatory_space: current_participatory_space)
        end
      end
    end
  end
end
