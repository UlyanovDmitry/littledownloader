# frozen_string_literal: true

require 'rails_helper'

RSpec.describe YtdlpDownloader do
  let(:url) { 'https://example.com/videos/watch?v=dQw4w' }
  let(:download_dir) { 'tmp/test_downloads' }
  subject { described_class.new(url, download_dir: download_dir) }

  before do
    allow(FileUtils).to receive(:mkdir_p)
    allow(FileUtils).to receive(:mv)
    allow(FileUtils).to receive(:rm_rf)
    allow(subject).to receive(:ensure_bin!).and_return(true)
    allow(SecureRandom).to receive(:hex).and_return('12345678')
  end

  describe '#download' do
    let(:tmp_dir) { File.join(Dir.tmpdir, 'ytdlp_12345678') }

    it 'calls yt-dlp with correct arguments for video and moves file' do
      expected_cmd = [
        'yt-dlp', '--no-color', '--newline',
        '--progress',
        '--print', 'after_move:filepath',
        '--extractor-args', 'youtube:player_client=web,mweb,android,ios',
        '-o', "#{tmp_dir}/%(title)s.%(ext)s",
        '--ignore-errors', '--no-mtime',
        '-f', YtdlpDownloader::DEFAULT_FORMAT_SELECTOR,
        '--merge-output-format', YtdlpDownloader::DEFAULT_MERGE_FORMAT,
        '--embed-metadata', '--embed-thumbnail',
        url
      ]

      result_path = "#{tmp_dir}/video.mp4"
      final_path = "#{download_dir}/video.mp4"

      expect(subject).to receive(:run!) do |cmd|
        expect(cmd).to eq(expected_cmd)
        result_path
      end
      expect(File).to receive(:exist?).with(result_path).and_return(true)
      expect(File).to receive(:exist?).with(final_path).and_return(false)
      expect(FileUtils).to receive(:mv).with(result_path, final_path)

      expect(subject.download).to eq(final_path)
    end

    it 'calls yt-dlp with correct arguments for audio-only and moves file' do
      downloader = described_class.new(url, download_dir: download_dir, audio_only: true)
      allow(downloader).to receive(:ensure_bin!).and_return(true)

      expected_cmd = [
        'yt-dlp', '--no-color', '--newline',
        '--progress',
        '--print', 'after_move:filepath',
        '--extractor-args', 'youtube:player_client=web,mweb,android,ios',
        '-o', "#{tmp_dir}/%(title)s.%(ext)s",
        '--ignore-errors', '--no-mtime',
        '-x', '--audio-format', YtdlpDownloader::DEFAULT_AUDIO_FORMAT,
        '--embed-metadata', '--embed-thumbnail',
        url
      ]

      result_path = "#{tmp_dir}/audio.mp3"
      final_path = "#{download_dir}/audio.mp3"

      expect(downloader).to receive(:run!) do |cmd|
        expect(cmd).to eq(expected_cmd)
        result_path
      end
      expect(File).to receive(:exist?).with(result_path).and_return(true)
      expect(File).to receive(:exist?).with(final_path).and_return(false)
      expect(FileUtils).to receive(:mv).with(result_path, final_path)

      expect(downloader.download).to eq(final_path)
    end

    it 'renames file with sequential suffix when target exists' do
      result_path = "#{tmp_dir}/video.mp4"
      final_path = "#{download_dir}/video.mp4"
      final_path_1 = "#{download_dir}/video (1).mp4"

      expect(subject).to receive(:run!).and_return(result_path)
      allow(File).to receive(:exist?) do |path|
        case path
        when result_path
          true
        when final_path
          true
        when final_path_1
          false
        else
          false
        end
      end

      expect(FileUtils).to receive(:mv).with(result_path, final_path_1)

      expect(subject.download).to eq(final_path_1)
    end

    it 'raises DownloadError if command fails' do
      allow(Open3).to receive(:popen2e).and_yield(nil, [], double(value: double(success?: false, exitstatus: 1)))

      expect { subject.download }.to raise_error(YtdlpDownloader::DownloadError, /Command failed/)
    end
  end
end
