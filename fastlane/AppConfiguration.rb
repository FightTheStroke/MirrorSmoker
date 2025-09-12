# App Configuration for SIMPLE/FULL versions
# This file defines the configuration differences between versions

class AppConfiguration
  def self.simple_version_config
    {
      app_identifier: "com.mirror-labs.MirrorSmokerStopper",
      app_name: "Mirror Smoker",
      primary_category: "MEDICAL",
      secondary_category: "HEALTH_AND_FITNESS",
      metadata_path: "fastlane/metadata/simple",
      keywords: "quit smoking, cessation, health, motivation, tracking, basic stats",
      subtitle: "Simple Smoking Cessation Tracker",
      promotional_text: "Track your progress with essential features - clean, simple, effective.",
      marketing_url: "https://fighthestroke.org/mirrorsmokersimple",
      support_url: "https://fighthestroke.org/support",
      privacy_url: "https://fighthestroke.org/privacy"
    }
  end
  
  def self.full_version_config
    {
      app_identifier: "com.mirror-labs.MirrorSmokerStopper.pro",
      app_name: "Mirror Smoker Pro", 
      primary_category: "MEDICAL",
      secondary_category: "HEALTH_AND_FITNESS",
      metadata_path: "fastlane/metadata/full",
      keywords: "quit smoking, AI coach, cessation, health, analytics, heart rate, personalized, coaching",
      subtitle: "AI-Powered Smoking Cessation Coach",
      promotional_text: "Advanced AI coaching, heart rate monitoring, and personalized insights for your quit journey.",
      marketing_url: "https://fighthestroke.org/mirrorsmokerpro",
      support_url: "https://fighthestroke.org/support",
      privacy_url: "https://fighthestroke.org/privacy"
    }
  end
  
  def self.config_for(version_type)
    case version_type.to_s.downcase
    when 'simple'
      simple_version_config
    when 'full'
      full_version_config
    else
      raise "Invalid version type: #{version_type}. Use 'simple' or 'full'"
    end
  end
end