require 'spec_helper'

module Spacebunny
  describe DeviceKeyOrClientAndSecretRequired do

    pending 'ApikeyRequired' do
      it 'should raise an ApikeyRequired exception' do
        # expect(raise Spacebunny::ApikeyRequired)
        #     .to raise_exception
        #     #(Spacebunny::ApikeyRequired, /valid Api Key/)
      end

      context 'without message param' do
        it 'should raise the exception with no message' do
          #expect(Spacebunny::ApikeyRequired.new).to_not include()
        end
      end
    end
  end
end
