class Cms::Site
  include SS::Model::Site
  include Cms::SitePermission
  include Cms::Addon::PageSetting
  include Cms::Addon::DefaultReleasePlan
  include SS::Addon::MobileSetting
  include SS::Addon::MapSetting
  include SS::Addon::KanaSetting
  include SS::Addon::FacebookSetting
  include SS::Addon::TwitterSetting
  include SS::Addon::SiteAutoPostSetting
  include SS::Addon::FileSetting
  include SS::Addon::MailSetting
  include SS::Addon::ApproveSetting
  include Opendata::Addon::SiteSetting
  include SS::Addon::EditorSetting

  set_permission_name "cms_sites", :edit
end
