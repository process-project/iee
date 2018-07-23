# frozen_string_literal: true

require 'rails_helper'

describe Patients::Details do
  let(:user) { create(:user) }
  let(:subject) { described_class.new(nil, user) }

  describe '#create_details' do
    let(:basic) do
      [
        %w[patient_id_text year_of_birth_value gender_value],
        %w[a_case 1941 Female],
        %w[a_case this should_be_ignored]
      ]
    end

    let(:real) do
      [
        %w[patient_id_text ds_date_date age_value ds_type_value ds_height_value ds_weight_value],
        ['a_case', '', '77', 'Pre-op', '156', '58'],
        %w[a_case 03/07/2017\ 12:00:00 78 Post-op 156 56]
      ]
    end

    let(:inferred) do
      [
        %w[roottable_patient_id_text ds_type_item com_elvmin_value com_elvmax_value],
        %w[a_case Pre-op 0.46694209 0.258053069]
      ]
    end

    it 'tolerates empty input' do
      allow_any_instance_of(DataSets::Client).
        to receive(:call).
        and_return(nil)

      expect { subject.call }.not_to raise_error
    end

    it 'merges basic, real and inferred data together with proper order' do
      to_call = 'basic'
      allow_any_instance_of(DataSets::Client).
        to receive(:call).
        and_wrap_original do
          case to_call
          when 'basic'
            to_call = 'real'
            basic
          when 'real'
            to_call = 'inferred'
            real
          else inferred
          end
        end

      details = subject.call
      expect(details[:status]).to eq :ok
      expect(details[:payload].size).to eq 4
      expect(details[:payload][0].map { |x| x[:name] }).
        to match_array %w[birth_year gender current_age]
      expect(details[:payload][1].map { |x| x[:name] }).
        to match_array %w[age date height state weight]
      expect(details[:payload][3].map { |x| x[:name] }).
        to match_array %w[state elvmin elvmax]
    end

    it 'shows warning alongside basic and real data when no inferred data is present' do
      to_call = 'basic'
      allow_any_instance_of(DataSets::Client).
        to receive(:call).
        and_wrap_original do
          case to_call
          when 'basic'
            to_call = 'real'
            basic
          when 'real'
            to_call = 'inferred'
            real
          else raise StandardError, I18n.t('errors.patient_details.empty_result')
          end
        end

      details = subject.call
      expect(details[:status]).to eq :warn
      expect(details[:message]).
        to eq 'Empty result set returned from the data set repository of inferred values'
      expect(details[:payload].size).to eq 3
      expect(details[:payload][0].map { |x| x[:name] }).
        to match_array %w[birth_year gender current_age]
      expect(details[:payload][1].map { |x| x[:name] }).
        to match_array %w[age date height state weight]
    end

    it 'shows error when no real data is present' do
      to_call = 'basic'
      allow_any_instance_of(DataSets::Client).
        to receive(:call).
        and_wrap_original do
          case to_call
          when 'basic'
            to_call = 'real'
            basic
          when 'real'
            to_call = 'inferred'
            raise StandardError, I18n.t('errors.patient_details.empty_result')
          else inferred
          end
        end

      details = subject.call
      expect(details[:status]).to eq :error
      expect(details[:message]).
        to eq 'Empty result set returned from the data set repository of real values'
    end
  end
end
