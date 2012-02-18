require './lib/statsd.rb'

describe Statsd::Client do
  describe '#initialize' do
    it 'should work without arguments' do
      c = Statsd::Client.new
      c.should_not be nil
    end

    it 'should accept a :host keyword argument' do
      host = 'zombo.com'
      c = Statsd::Client.new(:host => host)
      c.host.should match(host)
    end

    it 'should accept a :port keyword argument' do
      port = 1337
      c = Statsd::Client.new(:port => port)
      c.port.should == port
    end

    it 'should accept a :prefix keyword argument' do
      prefix = 'dev'
      c = Statsd::Client.new(:prefix => prefix)
      c.prefix.should match(prefix)
    end
  end

  describe '#timing' do
    let(:c) { Statsd::Client.new }

    it 'should pass the sample rate along' do
      sample = 10
      c.should_receive(:send_stats).with(anything(), sample)
      c.timing('foo', 1, sample)
    end

    it 'should use the right stat name' do
      c.should_receive(:send_stats).with('foo:1|ms', anything())
      c.timing('foo', 1)
    end

    it 'should prefix its stats if it has a prefix' do
      c.should_receive(:send_stats).with('dev.foo:1|ms', anything())
      c.prefix = 'dev'
      c.timing('foo', 1)
    end

    it 'should wrap a block correctly' do
      # Pretend our block took one second
      c.should_receive(:send_stats).with('foo:1000|ms', anything())
      Time.stub_chain(:now, :to_f).and_return(1, 2)

      c.timing('foo') do
        true.should be true
      end
    end

    it 'should return the return value from the block' do
      # Pretend our block took one second
      c.should_receive(:send_stats).with('foo:1000|ms', anything())
      Time.stub_chain(:now, :to_f).and_return(1, 2)

      value = c.timing('foo') { 1337 }
      value.should == 1337
    end
  end

  describe '#increment' do
    let(:c) { Statsd::Client.new }

    it 'should prepend the prefix if it has one' do
      c.prefix = 'dev'
      c.should_receive(:update_counter).with('dev.foo', anything(), anything())
      c.increment('foo')
    end
  end

  describe '#decrement' do
    let(:c) { Statsd::Client.new }

    it 'should prepend the prefix if it has one' do
      c.prefix = 'dev'
      c.should_receive(:update_counter).with('dev.foo', anything(), anything())
      c.decrement('foo')
    end
  end
end