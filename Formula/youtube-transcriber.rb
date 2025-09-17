class YoutubeTranscriber < Formula
  desc "Trascrivi video YouTube e file audio con Groq AI"
  homepage "https://github.com/ripolissimogit/youtube-transcriber"
  url "https://github.com/ripolissimogit/youtube-transcriber/archive/refs/heads/main.zip"
  version "1.0.3"
  sha256 "ab34f1c012dad17a62662093e15c6766b2020bff58d1b746ef5cf3de59979eaa"
  
  depends_on "yt-dlp"
  depends_on "ffmpeg"
  depends_on "python@3.12"
  
  def install
    # Install Python dependencies
    system "python3", "-m", "pip", "install", "--break-system-packages", "requests"
    
    # Install the script
    bin.install "transcribe"
    
    # Prompt for API key during installation
    puts "\n🔑 Configurazione Groq API Key"
    puts "Ottieni una chiave gratuita da: https://console.groq.com/keys"
    print "Inserisci la tua chiave API Groq: "
    api_key = STDIN.gets.chomp
    
    if !api_key.empty?
      # Add to shell profiles
      zshrc = File.expand_path("~/.zshrc")
      bash_profile = File.expand_path("~/.bash_profile")
      
      [zshrc, bash_profile].each do |profile|
        if File.exist?(profile)
          content = File.read(profile)
          unless content.include?("GROQ_API_KEY")
            File.open(profile, "a") do |f|
              f.puts "\n# YouTube Transcriber"
              f.puts "export GROQ_API_KEY=\"#{api_key}\""
            end
          end
        end
      end
      
      puts "✅ Chiave API configurata!"
      puts "Riavvia il terminale o esegui: source ~/.zshrc"
    else
      puts "⚠️ Chiave non inserita. Configurala manualmente:"
      puts "export GROQ_API_KEY='la_tua_chiave'"
    end
  end
  
  def caveats
    <<~EOS
      Per usare YouTube Transcriber, configura la tua chiave API Groq:
      
        export GROQ_API_KEY="la_tua_chiave_groq"
      
      Ottieni una chiave gratuita da: https://console.groq.com/keys
      
      Uso:
        transcribe "https://youtube.com/watch?v=VIDEO_ID"
        transcribe "/path/to/audio.mp3"
    EOS
  end
  
  test do
    system "#{bin}/transcribe", "--help"
  end
end
