require 'rails_helper'

describe DataFileSynchronizer do
  let(:user_no_proxy) { build(:user, proxy: nil) }
  let(:user_with_phony_proxy) { build(:user, proxy: 'proxy') }
  let(:expired_proxy) do
    File.open(Rails.application.secrets[:test_expired_proxy_path]).read
  end
  let(:user_with_expired_proxy) { build(:user, proxy: expired_proxy) }
  let(:patient) { create(:patient) }

  let(:connection) { double('faraday connection') }

  it 'does nothing for wrong input' do
    expect(connection).not_to receive(:get)
    call(nil, nil)
    call(build(:patient, case_number: nil), nil)
    call(build(:patient), user_no_proxy)
  end

  it 'reports problems in logger' do
    expect(Rails.logger).to receive(:warn).
      with(I18n.t('data_file_synchronizer.no_proxy', user: user_no_proxy.name)).
      and_call_original
    call(build(:patient), user_no_proxy)
  end

  it 'reports problems in Sentry' do
    pending 'Sentry reporting still not implemented; issue #32'
    fail
  end

  it 'reports problem with provided user proxy', proxy: true do
    expect(Rails.logger).to receive(:info).
      with(/The certificate has expired/).
      and_call_original
    call(patient, user_with_expired_proxy)
  end

  context 'when provided with correct input', proxy: true do
    let(:test_proxy) do
      File.open(Rails.application.secrets[:test_proxy_path]).read
    end
    let(:user) { build(:user, proxy: test_proxy) }
    let(:test_patient) { create(:patient, case_number: '1234') }

    it 'handles network errors gracefully' do
      expect(Rails.logger).to receive(:warn).
        with(I18n.t('data_file_synchronizer.invalid_response',
                    user: user_with_phony_proxy.name,
                    patient: patient.case_number)).
        and_call_original
      expect do
        call(patient, user_with_phony_proxy,
             storage_url: 'http://total.rubbish')
      end.not_to change{ DataFile.count }
    end

    it 'correctly reads test proxy' do
      expect(user.proxy).to be_present
    end

    it 'calls file storage and creates new related data_files' do
      expect{ call(test_patient, user) }.to change{ DataFile.count }.by(2)
      expect(DataFile.all.map(&:data_type)).
        to match_array ['fluid_virtual_model', 'ventricle_virtual_model']
    end

    it 'only creates data_files not yet present' do
      create(:data_file, name: 'structural_vent.dat',
                         data_type: 'ventricle_virtual_model',
                         patient: test_patient)
      expect{ call(test_patient, user) }.to change{ DataFile.count }.by(1)
      expect(DataFile.all.map(&:data_type)).
        to match_array ['fluid_virtual_model', 'ventricle_virtual_model']
    end

    it 'destroys data_files which are no longer stored in File Storage' do
      create(:data_file, data_type: 'blood_flow_result', patient: test_patient)
      create(:data_file, name: 'structural_vent.dat',
             data_type: 'ventricle_virtual_model',
             patient: test_patient)
      create(:data_file, name: 'fluidFlow.cas',
             data_type: 'fluid_virtual_model',
             patient: test_patient)
      expect(test_patient.reload.after_blood_flow_simulation?).to be_truthy
      expect{ call(test_patient, user) }.to change{ DataFile.count }.by(-1)
      expect(DataFile.all.map(&:data_type)).
        to match_array ['fluid_virtual_model', 'ventricle_virtual_model']
      expect(test_patient.reload.virtual_model_ready?).to be_truthy
    end
  end

  def call(patient, user, options = {})
    DataFileSynchronizer.new(patient, user, options).call
  end
end
