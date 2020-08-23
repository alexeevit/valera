require 'valera/parser'

describe Valera::Parser do
  subject { described_class.new }

  describe '#parse' do
    it 'returns array of prepared words splitted by space' do
      expect(subject.parse("Hi! How are you?")).to eq(%w(Hi How are you))
    end
  end

  describe '#is_word?' do
    it 'is true if it contains only latin letters' do
      expect(subject.send(:is_word?, 'hello')).to be_truthy
    end

    it 'is true if it contains only cyrrillic letters' do
      expect(subject.send(:is_word?, 'привет')).to be_truthy
    end

    it 'is true if it contains only digits' do
      expect(subject.send(:is_word?, '007')).to be_truthy
    end

    it 'is true if it contains latin, cyrrillic letters and digits' do
      expect(subject.send(:is_word?, 'Dжаzz01')).to be_truthy
    end

    it 'is true if it contains dash' do
      expect(subject.send(:is_word?, 'Мамин-Сибиряк')).to be_truthy
    end

    it 'is true if it contains percent' do
      expect(subject.send(:is_word?, '10%')).to be_truthy
    end

    it 'is false if it contains other characters' do
      expect(subject.send(:is_word?, '?')).to be_falsey
    end
  end

  describe '#prepare_word' do
    it 'removes spaces' do
      expect(subject.send(:prepare_word, '   henlo ')).to eq('henlo')
    end

    it 'removes special characters' do
      expect(subject.send(:prepare_word, 'henlo.,"\'?!;:*')).to eq('henlo')
    end
  end
end
