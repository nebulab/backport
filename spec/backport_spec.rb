# frozen_string_literal: true

RSpec.describe Backport do
  subject { described_class }

  describe '.register_check' do
    context 'when the check has a proc value' do
      it 'registers the check' do
        expect do
          subject.register_check(:test_check, -> { true })
        end.not_to raise_error
      end
    end

    context 'when the check has a boolean value' do
      it 'registers the check' do
        expect do
          subject.register_check(:test_check, true)
        end.not_to raise_error
      end
    end

    context 'when the check has a block' do
      it 'registers the check' do
        expect do
          subject.register_check(:test_check) do
            true
          end
        end.not_to raise_error
      end
    end

    context 'when the check has no value and no block' do
      it 'raises an ArgumentError' do
        expect do
          subject.register_check(:test_check)
        end.to raise_error(ArgumentError)
      end
    end

    context 'when the check has both a value and a block' do
      it 'raises an ArgumentError' do
        expect do
          subject.register_check(:test_check, -> { true }) do
            true
          end
        end.to raise_error(ArgumentError)
      end
    end
  end

  describe '.notify' do
    context 'with a block check' do
      before do
        subject.register_check(:test_check) do
          check_result
        end
      end

      context 'when the related checks returns true' do
        let(:check_result) { true }

        it 'notifies the deprecation' do
          expect(ActiveSupport::Deprecation).to receive(:warn)

          subject.notify('deprecation message', :test_check)
        end
      end

      context 'when the related check returns false' do
        let(:check_result) { false }

        it 'does not return the deprecation' do
          expect(ActiveSupport::Deprecation).not_to receive(:warn)

          subject.notify('deprecation message', :test_check)
        end
      end
    end

    context 'with a proc check' do
      before do
        subject.register_check(:test_check, -> { check_result })
      end

      context 'when the related checks returns true' do
        let(:check_result) { true }

        it 'notifies the deprecation' do
          expect(ActiveSupport::Deprecation).to receive(:warn)

          subject.notify('deprecation message', :test_check)
        end
      end

      context 'when the related check returns false' do
        let(:check_result) { false }

        it 'does not return the deprecation' do
          expect(ActiveSupport::Deprecation).not_to receive(:warn)

          subject.notify('deprecation message', :test_check)
        end
      end
    end

    context 'with a static check' do
      before do
        subject.register_check(:test_check, check_result)
      end

      context 'when the related checks returns true' do
        let(:check_result) { true }

        it 'notifies the deprecation' do
          expect(ActiveSupport::Deprecation).to receive(:warn)

          subject.notify('deprecation message', :test_check)
        end
      end

      context 'when the related check returns false' do
        let(:check_result) { false }

        it 'does not return the deprecation' do
          expect(ActiveSupport::Deprecation).not_to receive(:warn)

          subject.notify('deprecation message', :test_check)
        end
      end
    end
  end

  describe '#notify!' do
    before do
      subject.register_check(:test_check, check_result)
    end

    context 'when the related checks returns true' do
      let(:check_result) { true }

      it 'raises a deprecation error' do
        expect do
          subject.notify!('deprecation message', :test_check)
        end.to raise_error(ActiveSupport::DeprecationException)
      end
    end

    context 'when the related check returns false' do
      let(:check_result) { false }

      it 'does not raise any errors' do
        expect do
          subject.notify!('deprecation message', :test_check)
        end.not_to raise_error
      end
    end
  end
end
