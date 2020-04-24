Pod::Spec.new do |s|


  s.name         = "xDiffCollection"
  s.version      = "1.2.2"
  s.summary      = "xDiffCollection serves as a data storage of hashable objects to easily add, update and delete"

  s.description  = <<-DESC
xDiffCollection operates on the concept of bins. A bin is an array and a filter. Elements tha go in those bins are hashable identifiable and equatable differentiable. 
The filter accepts elements into a bin based on a custom logic provided via a boolean closure.  
xDiffCollection exposes two operations: update and delete. update can also add an element if the element passes the test and the element is not previously there. 
If the element was already there an update operation is performed and the logic in the bin is re-run to decide if this is still the appropriate bin for that updated element. If it is not, the element is deleted from the current bin and moved to a bin where the updated element passes another's bin logic.
                   DESC

  s.license      = { :type => "MIT", :file => "LICENSE" }


  s.author             = { "Swift Gurus" => "alexei.hmelevski@aldogroup.com" }

  # ――― Platform Specifics ――――――――――――――――――――――――――――――――――――――――――――――――――――――― #
  #
  #  If this Pod runs only on iOS or OS X, then specify the platform and
  #  the deployment target. You can optionally include the target after the platform.
  #
  
  s.platform     = :ios, '11.0'
  s.swift_version   = '5.0'
  
  #  When using multiple platforms
  s.ios.deployment_target = '11.0'


  # ――― Source Location ―――――――――――――――――――――――――――――――――――――――――――――――――――――――――― #
  #
  #  Specify the location from where the source should be retrieved.
  #  Supports git, hg, bzr, svn and HTTP.
  #

  s.source           = { :git => 'https://github.com/swift-gurus/xDiffCollection.git', :tag => s.version.to_s }
  s.source_files = 'xDiffCollection/**/*'
  s.dependency 'SwiftyCollection'

end
