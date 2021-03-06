class Gws::Monitor::AdminsController < ApplicationController
  include Gws::BaseFilter
  include Gws::CrudFilter
  include Gws::Monitor::TopicFilter

  before_action :check_readable

  navi_view "gws/monitor/main/navi"

  private

  def set_crumbs
    set_category
    @crumbs << [@cur_site.menu_monitor_label || t("modules.gws/monitor"), gws_monitor_main_path]
    if @category.present?
      @crumbs << [@category.name, gws_monitor_topics_path]
    end
    @crumbs << [t('gws/monitor.tabs.admin'), action: :index]
  end

  def set_items
    @items = @model.site(@cur_site).topic
    @items = @items.allow(:read, @cur_user, site: @cur_site, private_only: true)
    @items = @items.without_deleted
    @items = @items.search(params[:s])
    @items = @items.custom_order(params.dig(:s, :sort))
    @items = @items.page(params[:page]).per(50)
  end

  def check_readable
    if @item
      raise '403' unless @item.allowed?(:read, @cur_user, site: @cur_site)
    end
  end
end
