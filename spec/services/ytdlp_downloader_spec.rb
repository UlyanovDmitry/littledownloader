# frozen_string_literal: true

require 'rails_helper'

RSpec.describe YtdlpDownloader do
  let(:url) { 'https://www.youtube.com/watch?v=dQw4w9WgXcQ' }
  let(:download_dir) { 'tmp/test_downloads' }
  subject { described_class.new(url, download_dir: download_dir) }

  before do
    allow(FileUtils).to receive(:mkdir_p)
    allow(subject).to receive(:ensure_bin!).and_return(true)
  end

  describe '#download' do
    it 'calls yt-dlp with correct arguments for video' do
      expected_cmd = [
        'yt-dlp', '--no-color', '--newline',
        '--extractor-args', 'youtube:player_client=web',
        '-o', "#{download_dir}/%(title)s.%(ext)s",
        '--ignore-errors', '--no-mtime',
        '-f', YtdlpDownloader::DEFAULT_FORMAT_SELECTOR,
        '--merge-output-format', YtdlpDownloader::DEFAULT_MERGE_FORMAT,
        '--embed-metadata', '--embed-thumbnail',
        url
      ]

      expect(subject).to receive(:run!).with(expected_cmd).and_return(true)
      subject.download
    end

    it 'calls yt-dlp with correct arguments for audio-only' do
      downloader = described_class.new(url, download_dir: download_dir, audio_only: true)
      allow(downloader).to receive(:ensure_bin!).and_return(true)

      expected_cmd = [
        'yt-dlp', '--no-color', '--newline',
        '--extractor-args', 'youtube:player_client=web',
        '-o', "#{download_dir}/%(title)s.%(ext)s",
        '--ignore-errors', '--no-mtime',
        '-x', '--audio-format', YtdlpDownloader::DEFAULT_AUDIO_FORMAT,
        '--embed-metadata', '--embed-thumbnail',
        url
      ]

      expect(downloader).to receive(:run!).with(expected_cmd).and_return(true)
      downloader.download
    end

    it 'raises DownloadError if command fails' do
      allow(Open3).to receive(:popen2e).and_yield(nil, [], double(value: double(success?: false, exitstatus: 1)))

      expect { subject.download }.to raise_error(YtdlpDownloader::DownloadError, /Command failed/)
    end
  end
end
