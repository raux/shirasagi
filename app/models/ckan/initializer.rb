module Ckan
  class Initializer
    Cms::Node.plugin "ckan/page"
    Cms::Part.plugin "ckan/status"
    Cms::Part.plugin "ckan/page"
  end
end
