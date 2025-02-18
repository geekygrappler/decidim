# frozen_string_literal: true

require "decidim/core"

module Decidim
  module Accountability
    # This is the engine that runs on the public interface of `decidim-accountability`.
    # It mostly handles rendering the created results associated to a participatory
    # process.
    class Engine < ::Rails::Engine
      isolate_namespace Decidim::Accountability

      routes do
        resources :results, only: [:index, :show] do
          resources :versions, only: [:show, :index]
        end
        root to: "results#home"
      end

      initializer "decidim_accountability.assets" do |app|
        app.config.assets.precompile += %w(decidim_accountability_manifest.js)
      end

      initializer "decidim_accountability.view_hooks" do
        Decidim.view_hooks.register(:participatory_space_highlighted_elements, priority: Decidim::ViewHooks::LOW_PRIORITY) do |view_context|
          view_context.cell("decidim/accountability/highlighted_results", view_context.current_participatory_space)
        end
      end

      initializer "decidim_accountability.add_cells_view_paths" do
        Cell::ViewModel.view_paths << File.expand_path("#{Decidim::Accountability::Engine.root}/app/cells")
        Cell::ViewModel.view_paths << File.expand_path("#{Decidim::Accountability::Engine.root}/app/views")
      end

      initializer "decidim_accountability.register_metrics" do
        Decidim.metrics_registry.register(:results) do |metric_registry|
          metric_registry.manager_class = "Decidim::Accountability::Metrics::ResultsMetricManage"

          metric_registry.settings do |settings|
            settings.attribute :highlighted, type: :boolean, default: false
            settings.attribute :scopes, type: :array, default: %w(home)
            settings.attribute :weight, type: :integer, default: 4
          end
        end
      end
    end
  end
end
