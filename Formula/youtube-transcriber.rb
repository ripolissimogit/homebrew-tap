class YoutubeTranscriber < Formula
  desc "Trascrivi video YouTube e file audio con Groq AI + OpenAI (entrambi obbligatori)"
  homepage "https://github.com/ripolissimogit/youtube-transcriber"
  url "https://github.com/ripolissimogit/youtube-transcriber/archive/refs/heads/main.zip"
  version "3.1.0"
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
    
    # Prompt for BOTH API keys during installation (MANDATORY)
    puts "\n🔑 Configurazione API Keys (ENTRAMBE OBBLIGATORIE)"
    puts "1. Groq API: https://console.groq.com/keys"
    puts "2. OpenAI API: https://platform.openai.com/api-keys"
    print "Inserisci la tua chiave Groq API: "
    groq_key = STDIN.gets.chomp
    print "Inserisci la tua chiave OpenAI API: "
    openai_key = STDIN.gets.chomp
    
    if !groq_key.empty? && !openai_key.empty?
      # Add to shell profiles
      zshrc = File.expand_path("~/.zshrc")
      bash_profile = File.expand_path("~/.bash_profile")
      
      [zshrc, bash_profile].each do |profile|
        if File.exist?(profile)
          content = File.read(profile)
          unless content.include?("GROQ_API_KEY")
            File.open(profile, "a") do |f|
              f.puts "\n# YouTube Transcriber v3.1"
              f.puts "export GROQ_API_KEY=\"#{groq_key}\""
              f.puts "export OPENAI_API_KEY=\"#{openai_key}\""
            end
          end
        end
      end
      
      puts "✅ Entrambe le chiavi API configurate!"
      puts "Riavvia il terminale o esegui: source ~/.zshrc"
    else
      puts "⚠️ ATTENZIONE: Entrambe le chiavi sono obbligatorie!"
      puts "Configurale manualmente:"
      puts "export GROQ_API_KEY='la_tua_chiave_groq'"
      puts "export OPENAI_API_KEY='la_tua_chiave_openai'"
    end
  end
  
  def caveats
    <<~EOS
      YouTube Transcriber v3.1 installato con successo!
      
      🎯 COMANDI DISPONIBILI:
        transcribe "https://youtube.com/watch?v=VIDEO_ID"  # Comando originale
        trascrivi "https://youtube.com/watch?v=VIDEO_ID"   # Comando italiano
        yt-transcribe https://youtube.com/watch?v=VIDEO_ID # Senza virgolette!
        yt-trascrivi https://youtube.com/watch?v=VIDEO_ID  # Senza virgolette!
        trascrivi-url https://youtube.com/watch?v=VIDEO_ID # Alias trascrivi
        sbobina https://youtube.com/watch?v=VIDEO_ID       # Alias sbobina
      
      🔧 CONFIGURAZIONE (ENTRAMBE OBBLIGATORIE):
        export GROQ_API_KEY="la_tua_chiave_groq"
        export OPENAI_API_KEY="la_tua_chiave_openai"
        
      🆕 FLUSSO v3.1 (TUTTO AUTOMATICO):
        1. 🎤 Trascrizione audio (Groq Whisper)
        2. 🤖 Correzione errori formali (OpenAI)
        3. 📋 Generazione sintesi automatica
        4. 📊 Recupero metadati video completi
        5. 💾 Salvataggio automatico file .txt
      
      📄 OUTPUT FINALE:
        • Metadati video (titolo, canale, data, link)
        • Sintesi automatica del contenuto
        • Trascrizione migliorata e formattata
        • Salvataggio automatico in file .txt
      
      💡 I comandi yt-transcribe, yt-trascrivi, trascrivi-url e sbobina 
         gestiscono automaticamente gli URL YouTube senza bisogno di virgolette!
    EOS
  end
  
  test do
    system "#{bin}/transcribe", "--help"
    system "#{bin}/yt-transcribe", "--help"
  end
end
