class YoutubeTranscriber < Formula
  desc "Trascrivi video YouTube e file audio con Groq AI + OpenAI"
  homepage "https://github.com/ripolissimogit/youtube-transcriber"
  url "https://github.com/ripolissimogit/youtube-transcriber/archive/refs/heads/main.zip"
  version "3.0.0"
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
    bin.install_symlink "transcribe-wrapper" => "trascrivi-url"
    bin.install_symlink "transcribe-wrapper" => "sbobina"
    
    # Prompt for API keys during installation
    puts "\n🔑 Configurazione API Keys"
    puts "1. Groq API (OBBLIGATORIA): https://console.groq.com/keys"
    puts "2. OpenAI API (OPZIONALE): https://platform.openai.com/api-keys"
    print "Inserisci la tua chiave Groq API: "
    groq_key = STDIN.gets.chomp
    print "Inserisci la tua chiave OpenAI (Enter per saltare): "
    openai_key = STDIN.gets.chomp
    
    if !groq_key.empty?
      # Add to shell profiles
      zshrc = File.expand_path("~/.zshrc")
      bash_profile = File.expand_path("~/.bash_profile")
      
      [zshrc, bash_profile].each do |profile|
        if File.exist?(profile)
          content = File.read(profile)
          unless content.include?("GROQ_API_KEY")
            File.open(profile, "a") do |f|
              f.puts "\n# YouTube Transcriber"
              f.puts "export GROQ_API_KEY=\"#{groq_key}\""
              if !openai_key.empty?
                f.puts "export OPENAI_API_KEY=\"#{openai_key}\""
              end
            end
          end
        end
      end
      
      puts "✅ Chiavi API configurate!"
      if !openai_key.empty?
        puts "🤖 OpenAI abilitato per miglioramento trascrizioni"
      end
      puts "Riavvia il terminale o esegui: source ~/.zshrc"
    else
      puts "⚠️ Chiave Groq non inserita. Configurala manualmente:"
      puts "export GROQ_API_KEY='la_tua_chiave'"
      puts "export OPENAI_API_KEY='la_tua_chiave' # opzionale"
    end
  end
  
  def caveats
    <<~EOS
      YouTube Transcriber v3.0 installato con successo!
      
      🎯 COMANDI DISPONIBILI:
        transcribe "https://youtube.com/watch?v=VIDEO_ID"  # Comando originale
        trascrivi "https://youtube.com/watch?v=VIDEO_ID"   # Comando italiano
        yt-transcribe https://youtube.com/watch?v=VIDEO_ID # Senza virgolette!
        yt-trascrivi https://youtube.com/watch?v=VIDEO_ID  # Senza virgolette!
        trascrivi-url https://youtube.com/watch?v=VIDEO_ID # Alias trascrivi
        sbobina https://youtube.com/watch?v=VIDEO_ID       # Alias sbobina
      
      🔧 CONFIGURAZIONE:
        export GROQ_API_KEY="la_tua_chiave_groq"          # OBBLIGATORIA
        export OPENAI_API_KEY="la_tua_chiave_openai"      # OPZIONALE
        
      🆕 NOVITÀ v3.0:
        • Integrazione OpenAI per miglioramento trascrizioni
        • Correzione automatica errori di battitura
        • Divisione in paragrafi logici
        • Sintesi automatica del contenuto
        • Metadati video completi (titolo, canale, data, ecc.)
        • File di output arricchiti con tutte le informazioni
      
      💡 I comandi yt-transcribe, yt-trascrivi, trascrivi-url e sbobina 
         gestiscono automaticamente gli URL YouTube senza bisogno di virgolette!
    EOS
  end
  
  test do
    system "#{bin}/transcribe", "--help"
    system "#{bin}/yt-transcribe", "--help"
  end
end
