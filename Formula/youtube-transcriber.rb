class YoutubeTranscriber < Formula
  desc "Trascrivi video YouTube e file audio con Groq AI"
  homepage "https://github.com/ripolissimogit/youtube-transcriber"
  url "https://github.com/ripolissimogit/youtube-transcriber/archive/refs/heads/main.zip"
  version "1.0.0"
  sha256 :no_check
  
  depends_on "yt-dlp"
  depends_on "ffmpeg"
  depends_on "python@3.12"
  
  def install
    # Install Python dependencies
    system "pip3", "install", "requests"
    
    # Install the script
    bin.install "transcribe"
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
