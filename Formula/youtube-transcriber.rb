class YoutubeTranscriber < Formula
  desc "Trascrivi video YouTube e file audio con Groq AI"
  homepage "https://github.com/ripolissimogit/youtube-transcriber"
  url "https://github.com/ripolissimogit/youtube-transcriber/archive/refs/heads/main.zip"
  version "2.3.0"
  sha256 :no_check
  
  depends_on "yt-dlp"
  depends_on "ffmpeg"
  depends_on "python@3.12"
  
  def install
    # Install main script
    bin.install "transcribe"
    bin.install "trascrivi"
    
    # Create global wrapper that handles URLs without quotes
    (bin/"transcribe-wrapper").write <<~EOS
      #!/bin/bash
      
      # Global wrapper for YouTube Transcriber
      TRANSCRIBER_PATH="#{bin}/transcribe"
      
      # If no arguments, pass to transcriber (interactive mode)
      if [ $# -eq 0 ]; then
          exec "$TRANSCRIBER_PATH"
      fi
      
      # If argument contains youtube.com or youtu.be, handle automatically
      if [[ "$1" == *"youtube.com"* ]] || [[ "$1" == *"youtu.be"* ]]; then
          exec "$TRANSCRIBER_PATH" "$1"
      else
          # For local files or other arguments, pass as-is
          exec "$TRANSCRIBER_PATH" "$@"
      fi
    EOS
    
    # Make wrapper executable
    chmod 0755, bin/"transcribe-wrapper"
    
    # Create symlinks for easy access
    bin.install_symlink "transcribe-wrapper" => "yt-transcribe"
    bin.install_symlink "transcribe-wrapper" => "yt-trascrivi"
    
    # Prompt for API key during installation
    puts "\n🔑 Configurazione Groq API Key"
    puts "Ottieni una chiave gratuita da: https://console.groq.com/keys"
    print "Inserisci la tua chiave API Groq (premi Enter per saltare): "
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
      YouTube Transcriber installato con successo!
      
      🎯 COMANDI DISPONIBILI:
        transcribe "https://youtube.com/watch?v=VIDEO_ID"  # Comando originale
        trascrivi "https://youtube.com/watch?v=VIDEO_ID"   # Comando italiano
        yt-transcribe https://youtube.com/watch?v=VIDEO_ID # Senza virgolette!
        yt-trascrivi https://youtube.com/watch?v=VIDEO_ID  # Senza virgolette!
      
      🔧 CONFIGURAZIONE:
        export GROQ_API_KEY="la_tua_chiave_groq"
        
      Ottieni una chiave gratuita da: https://console.groq.com/keys
      
      💡 I comandi yt-transcribe e yt-trascrivi gestiscono automaticamente
         gli URL YouTube senza bisogno di virgolette!
    EOS
  end
  
  test do
    system "#{bin}/transcribe", "--help"
    system "#{bin}/yt-transcribe", "--help"
  end
end
