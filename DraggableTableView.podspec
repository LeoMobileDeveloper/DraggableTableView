
Pod::Spec.new do |s|
  s.name             = 'DraggableTableView'
  s.version          = '0.2.0'
  s.summary          = 'Extension for the UITableView that allows a user to move cells with long press and drop'
  s.description      = <<-DESC
Extension for the UITableView that allows a user to move cells with long press and drop,it is a "Drop to use" library.
                       DESC

  s.homepage         = 'https://github.com/LeoMobileDeveloper/DraggableTableView'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'Leo' => 'leomobiledeveloper@gmail.com' }
  s.source           = { :git => 'https://github.com/LeoMobileDeveloper/DraggableTableView.git', :tag => s.version.to_s }
  s.ios.deployment_target = '8.0'
  s.source_files = 'Classes/**/*'
end
