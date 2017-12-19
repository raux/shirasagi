module Gws::Portal::PortletModel
  extend ActiveSupport::Concern
  extend SS::Translation
  include Gws::Addon::Portal::Portlet::Free
  include Gws::Addon::Portal::Portlet::Link
  include Gws::Addon::Portal::Portlet::Schedule
  include Gws::Addon::Portal::Portlet::Reminder
  include Gws::Addon::Portal::Portlet::Bookmark
  include Gws::Addon::Portal::Portlet::Board
  include Gws::Addon::Portal::Portlet::Faq
  include Gws::Addon::Portal::Portlet::Qna
  include Gws::Addon::Portal::Portlet::Circular
  include Gws::Addon::Portal::Portlet::Monitor
  include Gws::Addon::Portal::Portlet::Share
  include Gws::Addon::Portal::Portlet::Report
  include Gws::Addon::Portal::Portlet::Workflow

  PORTLETS = {
    free:     { size_x: 2, size_y: 2, addons: [Gws::Addon::Portal::Portlet::Free] },
    links:    { size_x: 2, size_y: 3, addons: [Gws::Addon::Portal::Portlet::Link] },
    reminder: { size_x: 2, size_y: 3, addons: [Gws::Addon::Portal::Portlet::Reminder] },
    bookmark: { size_x: 2, size_y: 3, addons: [Gws::Addon::Portal::Portlet::Bookmark] },
    schedule: { size_x: 4, size_y: 2, addons: [Gws::Addon::Portal::Portlet::Schedule] },
    board:    { size_x: 2, size_y: 3, addons: [Gws::Addon::Portal::Portlet::Board] },
    faq:      { size_x: 2, size_y: 3, addons: [Gws::Addon::Portal::Portlet::Faq] },
    qna:      { size_x: 2, size_y: 3, addons: [Gws::Addon::Portal::Portlet::Qna] },
    circular: { size_x: 2, size_y: 3, addons: [Gws::Addon::Portal::Portlet::Circular] },
    monitor:  { size_x: 2, size_y: 3, addons: [Gws::Addon::Portal::Portlet::Monitor] },
    share:    { size_x: 2, size_y: 3, addons: [Gws::Addon::Portal::Portlet::Share] },
    report:   { size_x: 2, size_y: 3, addons: [Gws::Addon::Portal::Portlet::Report] },
    workflow: { size_x: 2, size_y: 3, addons: [Gws::Addon::Portal::Portlet::Workflow] },
  }.freeze

  included do
    field :name, type: String
    field :portlet_model, type: String
    field :grid_data, type: Hash
    field :limit, type: Integer, default: 5

    permit_params :name, :portlet_model, :limit

    validates :name, presence: true
    validates :portlet_model, inclusion: { in: PORTLETS.keys.map(&:to_s) }
    validates :setting_id, presence: true

    after_validation :set_default_grid_data, if: ->{ grid_data.blank? }

    default_scope -> {
      order_by "grid_data.row" => 1, "grid_data.col" => 1
    }
  end

  def portlet_model_options
    PORTLETS.keys.map { |k| [I18n.t("gws/portal.portlets.#{k}.name"), k] }
  end

  def portlet_model_enabled?
    portlet_model.present? && PORTLETS.key?(portlet_model.to_sym)
  end

  def portlet_addons
    self.class.portlet_addons(portlet_model)
  end

  def default_grid_data
    PORTLETS[portlet_model.to_sym].slice(:size_x, :size_y)
  end

  def view_file
    "gws/portal/portlets/#{portlet_model}/index.html.erb"
  end

  def portlet_id_class
    "portlet-id-#{id}"
  end

  def portlet_model_class
    "portlet-model-#{portlet_model}"
  end

  private

  def set_default_grid_data
    self.grid_data = default_grid_data
  end

  module ClassMethods
    def search(params)
      criteria = where({})
      return criteria if params.blank?

      if params[:keyword].present?
        criteria = criteria.keyword_in params[:keyword], :name
      end
      criteria
    end

    def portlet_model(type)
      {
        type: type,
        name: I18n.t("gws/portal.portlets.#{type}.name"),
        text: I18n.t("gws/portal.portlets.#{type}.text"),
      }
    end

    def default_portlets(conf)
      conf.map do |data|
        grid = data.delete('grid') || {}
        data = data.map { |k, v| [k.to_sym, v] }.to_h

        item = default_portlet(data.delete(:model))
        item.attributes = data
        item.grid_data.merge!(grid.symbolize_keys) if grid.present?
        item
      end
    end

    def default_portlet(type)
      item = self.new(portlet_model: type)
      item.name = I18n.t("gws/portal.portlets.#{type}.name")
      item.grid_data = item.default_grid_data
      item
    end

    def portlet_addons(type)
      portlets = PORTLETS[type.to_sym][:addons] || []
      self.addons.select do |addon|
        addon.type.nil? || portlets.include?(addon.klass)
      end
    end
  end
end
