require 'valera/parser'

describe Valera::Parser do
  subject { described_class.new }

  describe '#parse' do
    it 'returns array of arrays of prepared words splitted by space' do
      expect(subject.parse("Hi! How are you? Hey, hello!")).to eq([%w(Hi !), %w(How are you ?), %w(Hey , hello !)])
    end
  end

  describe '#split_into_words' do
    let(:words) { subject.send(:split_into_words, text) }

    context 'when has an ending punctuation' do
      let(:text) { 'Hello world!' }

      it 'returns words with a separate punctuation' do
        expect(words).to eq(%w(Hello world !))
      end
    end

    context 'when does not have an ending punctuation' do
      let(:text) { 'Hello world' }

      it 'returns words without punctuation' do
        expect(words).to eq(%w(Hello world))
      end
    end

    context 'when has an ending punctuation in the middle' do
      let(:text) { 'Hi! How are you?' }

      it 'returns words with a punctuation' do
        expect(words).to eq(%w(Hi ! How are you ?))
      end
    end

    context 'when has other punctuation' do
      let(:text) { 'Hi, hey, hello' }

      it 'returns words with a separate punctuations' do
        expect(words).to eq(%w(Hi , hey , hello))
      end
    end

    context 'when has no spaces around punctuation' do
      let(:text) { 'Hi,hey,hello!' }

      it 'returns words with a separate punctuations' do
        expect(words).to eq(%w(Hi , hey , hello !))
      end
    end

    context 'when only punctuation' do
      let(:text) { '!' }

      it 'returns a punctuation' do
        expect(words).to eq(%w(!))
      end
    end
  end

  describe '#split_into_sentences' do
    let(:sentences) { subject.send(:split_into_sentences, text) }

    context 'when multiple sentences' do
      let(:text) { 'Hi! How are you?' }

      it 'returns sentences' do
        expect(sentences).to eq(['Hi!', 'How are you?'])
      end
    end

    context 'when a single sentence' do
      let(:text) { 'How are you?' }

      it 'returns the sentence' do
        expect(sentences).to eq(['How are you?'])
      end
    end

    context 'when a single sentence without ending punctuation' do
      let(:text) { 'Hello world' }

      it 'returns the sentence' do
        expect(sentences).to eq(['Hello world'])
      end
    end
  end
end
