Pod::Spec.new do |s|

  # ―――  Spec Metadata  ―――――――――――――――――――――――――――――――――――――――――――――――――――――――――― #
  s.name        = "MBDataSource"
  s.version     = "5.1.0"
  s.summary     = "Simplifies the setup of UITableView data sources and cells using type-safe cell configurators."
  s.description = <<-DESC
                    Framework to simplify the setup of UITableView data sources and cells.
                    Separates the model (represented by a generic DataSource) from the representation (TableViewDataSource) by using type-safe cell configurators (TableViewCellConfigurator) to handle the table cell setup in an simple way.
                   DESC
  s.homepage    = "https://github.com/mbuchetics/DataSource"
  s.screenshots = "https://github.com/mbuchetics/DataSource/raw/master/Resources/screenshot.png"

  # ―――  Spec License  ――――――――――――――――――――――――――――――――――――――――――――――――――――――――――― #
  s.license = { :type => "MIT", :file => "LICENSE" }

  # ――― Author Metadata  ――――――――――――――――――――――――――――――――――――――――――――――――――――――――― #
  s.author           = { "Matthias Buchetics" => "mbuchetics@gmail.com" }
  s.social_media_url = "https://twitter.com/mbuchetics"

  # ――― Platform Specifics ――――――――――――――――――――――――――――――――――――――――――――――――――――――― #
  s.platform = :ios, "10.0"

  # ――― Source  --------―――――――――――――――――――――――――――――――――――――――――――――――――――――――――― #
  s.source       = { :git => "https://github.com/mbuchetics/DataSource.git", :tag => "#{s.version}" }
  s.source_files = 'DataSource/*.swift'

  # ――― Project Settings ――――――――――――――――――――――――――――――――――――――――――――――――――――――――― #
  s.requires_arc = true
  s.dependency "Diff", "~> 0.5"

end
