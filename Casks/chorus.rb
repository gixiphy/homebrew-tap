cask "chorus" do
  version "1.11.0,116"
  sha256 "2b22ae89ee131a17f3488ef655e2e83d5650bd9c567a9a4247896e91134988ff"

  url "https://github.com/gixiphy/Chorus/releases/download/v#{version.csv.first}/Chorus-#{version.csv.first}-b#{version.csv.second}.zip"
  name "Chorus"
  desc "Menu bar control for displays and audio across Macs, with AI lighting and EQ advisors"
  homepage "https://github.com/gixiphy/Chorus"

  livecheck do
    url :url
    regex(/^Chorus[._-]v?(\d+(?:\.\d+)+)[._-]b(\d+)\.zip$/i)
    strategy :github_latest do |json, regex|
      json["assets"]&.map do |asset|
        match = asset["name"]&.match(regex)
        next if match.blank?

        "#{match[1]},#{match[2]}"
      end
    end
  end

  depends_on macos: ">= :tahoe"

  app "Chorus.app"
  binary "#{appdir}/Chorus.app/Contents/SharedSupport/chorus"

  uninstall quit:       "com.hermes.Chorus",
            login_item: "Chorus",
            delete:     "/Library/Audio/Plug-Ins/HAL/ChorusAudioDevice.driver",
            script:     {
              executable:   "/usr/bin/killall",
              args:         ["coreaudiod"],
              sudo:         true,
              must_succeed: false,
            }

  zap trash: [
    "~/.config/chorus",
    "~/Library/Application Support/Chorus",
    "~/Library/Logs/Chorus",
    "~/Library/Preferences/com.hermes.Chorus.plist",
  ]

  caveats do
    <<~EOS
      The virtual audio device (HAL driver) is not installed by Homebrew.
      Open Chorus → Settings → "Install driver"; it asks for an administrator password.

      `chorus` CLI is already linked into your PATH by Homebrew — no need to press
      "Install chorus to /usr/local/bin" in Settings.
    EOS
  end
end
