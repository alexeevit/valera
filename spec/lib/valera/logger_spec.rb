require 'valera/logger'

describe Valera::Logger do
  let(:io) { StringIO.new }
  let(:level) { :info }

  subject { described_class.new(io, level) }

  def entries
    io.string.lines.map { |line| JSON.parse(line) }
  end

  it 'writes the event as a JSON line with extra fields' do
    subject.info('reply_sent', duration_ms: 12)

    expect(entries.size).to eq(1)
    expect(entries.first).to include('level' => 'info', 'event' => 'reply_sent', 'duration_ms' => 12)
    expect(entries.first['time']).to match(/\A\d{4}-\d\d-\d\dT\d\d:\d\d:\d\d\.\d{3}Z\z/)
  end

  it 'serializes errors' do
    error = RuntimeError.new('boom')
    error.set_backtrace(['a.rb:1', 'b.rb:2'])

    subject.error('handler_failed', error: error)

    expect(entries.first).to include(
      'level' => 'error',
      'event' => 'handler_failed',
      'error_class' => 'RuntimeError',
      'error_message' => 'boom',
      'backtrace' => "a.rb:1\nb.rb:2",
    )
  end

  it 'handles errors without a backtrace' do
    subject.error('handler_failed', error: RuntimeError.new('boom'))

    expect(entries.first['backtrace']).to eq('')
  end

  context 'log level is info' do
    it 'skips debug entries' do
      subject.debug('noise')
      subject.info('signal')

      expect(entries.map { |entry| entry['event'] }).to eq(['signal'])
    end
  end

  context 'log level is error' do
    let(:level) { 'ERROR' }

    it 'writes only error and fatal entries' do
      subject.info('info')
      subject.warn('warn')
      subject.error('error')
      subject.fatal('fatal')

      expect(entries.map { |entry| entry['event'] }).to eq(%w[error fatal])
    end
  end

  context 'log level is unknown' do
    let(:level) { 'verbose' }

    it 'falls back to info' do
      subject.debug('noise')
      subject.info('signal')

      expect(entries.map { |entry| entry['event'] }).to eq(['signal'])
    end
  end
end
