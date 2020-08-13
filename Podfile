platform :ios, '13.0'
inhibit_all_warnings!
use_frameworks!

def hyper_track
  pod 'HyperTrack', '4.3.0'
  pod 'Branch'
end

target 'Deliveries' do
  hyper_track
end

target 'Delivery' do
  hyper_track
end

target 'Logistics' do
  hyper_track
end

target 'TrackingLive' do
  hyper_track
end

target 'SignIn' do
  pod 'AWSMobileClient', '2.13.2'
end


# Required for SwiftUI Previews to work with frameworks
# https://github.com/CocoaPods/CocoaPods/issues/9275#issuecomment-576766934
class Pod::Target::BuildSettings::AggregateTargetSettings
  alias_method :ld_runpath_search_paths_original, :ld_runpath_search_paths

  def ld_runpath_search_paths
    return ld_runpath_search_paths_original unless configuration_name == "Debug"
    return ld_runpath_search_paths_original + framework_search_paths
  end
end

class Pod::Target::BuildSettings::PodTargetSettings
  alias_method :ld_runpath_search_paths_original, :ld_runpath_search_paths

  def ld_runpath_search_paths
    return (ld_runpath_search_paths_original || []) + framework_search_paths
  end
end
