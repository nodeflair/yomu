require_relative '../helper.rb'

describe Yomu do
  let(:data) { File.read 'test/samples/sample.pages' }

  describe '.read' do
    it 'reads text' do
      text = Yomu.read :text, data

      assert_includes text, 'The quick brown fox jumped over the lazy cat.'
    end

    it 'reads metadata' do
      metadata = Yomu.read :metadata, data

      assert_equal 'application/vnd.apple.pages', metadata['Content-Type']
    end
  end

  describe '.new' do
    it 'requires parameters' do
      assert_raises ArgumentError do
        Yomu.new
      end
    end

    it 'accepts a root path' do
      assert_silent do
        yomu = Yomu.new 'test/samples/sample.pages'

        assert_block { yomu.path? }
        assert_block { !yomu.uri? }
        assert_block { !yomu.stream? }
      end
    end

    it 'accepts a relative path' do
      assert_silent do
        yomu = Yomu.new 'test/samples/sample.pages'

        assert_block { yomu.path? }
        assert_block { !yomu.uri? }
        assert_block { !yomu.stream? }
      end
    end

    it 'accepts a path with spaces' do
      assert_silent do
        yomu = Yomu.new 'test/samples/sample filename with spaces.pages'

        assert_block { yomu.path? }
        assert_block { !yomu.uri? }
        assert_block { !yomu.stream? }
      end
    end

    it 'accepts a URI' do
      assert_silent do
        yomu = Yomu.new 'http://svn.apache.org/repos/asf/poi/trunk/test-data/document/sample.docx'

        assert_block { yomu.uri? }
        assert_block { !yomu.path? }
        assert_block { !yomu.stream? }
      end
    end

    it 'accepts a stream or object that can be read' do
      assert_silent do
        File.open 'test/samples/sample.pages', 'r' do |file|
          yomu = Yomu.new file

        assert_block { yomu.stream? }
        assert_block { !yomu.path? }
        assert_block { !yomu.uri? }
        end
      end
    end

    it 'does not accept a path to a missing file' do
      assert_raises Errno::ENOENT do
        Yomu.new 'test/sample/missing.pages'
      end
    end

    it 'does not accept other objects' do
      [nil, 1, 1.1].each do |object|
        assert_raises TypeError do
          Yomu.new object
        end
      end
    end
  end

  describe 'initialized with a given path' do
    let(:yomu) { Yomu.new 'test/samples/sample.pages' }

    describe '#text' do
      it 'reads text' do
        assert_includes yomu.text, 'The quick brown fox jumped over the lazy cat.'
      end
    end

    describe '#metadata' do
      it 'reads metadata' do
        assert_equal 'application/vnd.apple.pages', yomu.metadata['Content-Type']
      end
    end
  end

  describe 'initialized with a given URI' do
    let(:yomu) { Yomu.new 'http://svn.apache.org/repos/asf/poi/trunk/test-data/document/sample.docx' }

    describe '#text' do
      it 'reads text' do
        assert_includes yomu.text, 'Lorem ipsum dolor sit amet, consectetuer adipiscing elit.'
      end
    end

    describe '#metadata' do
      it 'reads metadata' do
        assert_equal 'application/vnd.openxmlformats-officedocument.wordprocessingml.document', yomu.metadata['Content-Type']
      end
    end
  end

  describe 'initialized with a given stream' do
    let(:yomu) { Yomu.new File.open('test/samples/sample.pages', 'rb') }

    describe '#text' do
      it 'reads text' do
        assert_includes yomu.text, 'The quick brown fox jumped over the lazy cat.'
      end
    end

    describe '#metadata' do
      it 'reads metadata' do
        assert_equal 'application/vnd.apple.pages', yomu.metadata['Content-Type']
      end
    end
  end
end