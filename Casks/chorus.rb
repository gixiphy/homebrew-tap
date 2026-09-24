cask "chorus" do
  version "1.13.0,120"
  sha256 "d293b619f001c5b500a76b6fbc33b4f3e15e7cb4f224ac79506e34305170699c"

  url "https://github.com/gixiphy/Chorus/releases/download/v#{version.csv.first}/Chorus-#{version.csv.first}-b#{version.csv.second}.zip"
  name "Chorus"
  desc "Menu bar control for displays and audio, synced across Macs on the LAN"
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

  depends_on macos: :tahoe

  app "Chorus.app"
  binary "#{appdir}/Chorus.app/Contents/SharedSupport/chorus"

  # HAL driver 由 app 以管理員權限裝到 /Library；只有真的裝過才需要 sudo 移除並重啟 coreaudiod。
  driver = "/Library/Audio/Plug-Ins/HAL/ChorusAudioDevice.driver"
  uninstall quit:       "com.hermes.Chorus",
            login_item: "Chorus",
            script:     {
              executable:   "/bin/sh",
              args:         ["-c", "[ -d '#{driver}' ] || exit 0; rm -rf '#{driver}' && killall coreaudiod"],
              sudo:         File.directory?(driver),
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
