class Webmail::AddressesController < ApplicationController
  include Webmail::BaseFilter
  include Sns::CrudFilter

  model Webmail::Address

  before_action :set_address_group
  before_action :set_group_navi, only: [:index]

  private

  def set_crumbs
    set_address_group
    account = params[:account] || @cur_user.imap_default_index
    @crumbs << [t("mongoid.models.webmail/address"), webmail_addresses_path(account: account)]
    @crumbs << [@address_group.name, action: :index] if @address_group
    @webmail_other_account_path = :webmail_addresses_path
  end

  def fix_params
    { cur_user: @cur_user }
  end

  def set_address_group
    return if params[:group].blank?
    @address_group ||= Webmail::AddressGroup.user(@cur_user).find(params[:group])
  end

  def set_group_navi
    @group_navi = Webmail::AddressGroup.user(@cur_user)
  end

  public

  def index
    s_params = params[:s] || {}
    s_params[:address_group_id] = @address_group.id if @address_group.present?

    @items = @model.
      user(@cur_user).
      search(s_params).
      page(params[:page]).
      per(50)
  end

  def new
    super

    # entry from address
    if data = params[:item].presence
      @item.name  = data[:name].presence
      @item.email = data[:email].presence
    end
  end

  def download
    s_params = params[:s] || {}
    s_params[:address_group_id] = @address_group.id if @address_group.present?

    items = @model.user(@cur_user).
      search(s_params)

    @item = @model.new(fix_params)
    send_data @item.export_csv(items), filename: "personal_addresses_#{Time.zone.now.to_i}.csv"
  end

  def import
    @item = @model.new
    return if request.get?

    @item.attributes = get_params
    result = @item.import_csv
    flash.now[:notice] = t("ss.notice.saved") if result
    render_create result, location: { action: :index }, render: { file: :import }
  end

  def add
    email = params.dig(:item, :email).to_s
    redirect_to(action: :index) if email.blank?

    if item = @model.user(@cur_user).where(email: email).first
      redirect_to action: :edit, id: item.id
    else
      redirect_to action: :new, item: params[:item].to_unsafe_h
    end
  end
end
