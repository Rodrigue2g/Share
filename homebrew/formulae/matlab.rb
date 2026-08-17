cask 'matlab' do
    arch arm: "AppleSilicon", intel: "IntelProcessor"
    
    version 'R2024a'
    sha256 arm: "a1121db42da488829281b5f05f65dabf65ef5f68216b1d4968fef26c3d7a4b77",
           intel: "18df69045fd82091a7bd7adeb837d0423dcbf49d6695f8e750a05fc9f3045a8f"
           
    url "https://ch.mathworks.com/downloads/web_downloads/get_product_component?filename=matlab_#{version}_macOS#{archn}.dmg.zip&type=installer&release=#{version}&base_code=INST&platform=mac#{arch == 'AppleSilicon' ? 'a' : 'i'}64"
    
    #https://ch.mathworks.com/downloads/web_downloads/get_product_component?filename=matlab_R2024a_macOSAppleSilicon.dmg.zip&type=installer&release=R2024a&base_code=INST&platform=maci64
    #https://ch.mathworks.com/downloads/web_downloads/get_product_component?filename=matlab_R2024a_macOSAppleSilicon.dmg.zip&type=installer&release=R2024a&base_code=INST&platform=maca64
    
    name 'MATLAB'
    desc 'MATLAB_R2024b from MathWorks'
    homepage 'https://www.mathworks.com/products/matlab.html'
    
    livecheck do
       url "https://www.mathworks.com/downloads/web_downloads"
       regex(/MATLAB\s*R(\d+(?:\.\d+)+)\s*for\s*macOS/i)
    end
    
    auto_updates true
    depends_on macos: ">= :catalina"

    app 'MATLAB_#{version}.app'
  
    zap trash: [
      "~/Library/Application Support/MathWorks/MATLAB",
      "~/Library/Caches/com.mathworks.MATLAB",
      "~/Library/Preferences/com.mathworks.MATLAB.plist",
      "~/Library/Preferences/MathWorks",
      "~/Library/Logs/MathWorks",
      "~/Library/Saved Application State/com.mathworks.MATLAB.savedState",
      "~/Documents/MATLAB",
      "~/Library/Application Support/CrashReporter/MATLAB_*",
      "/Library/Application Support/MathWorks"
    ]
end

