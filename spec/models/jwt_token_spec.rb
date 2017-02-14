# frozen_string_literal: true
require 'rails_helper'

RSpec.describe JwtToken do
  include ActiveSupport::Testing::TimeHelpers

  let(:user) { create(:user) }
  subject { described_class.new(user) }

  it 'includes issuer in token' do
    expect(issuer_from_token(subject.to_s)).
      to eq Vapor::Application.config.jwt.issuer
  end

  it 'includes expiration time in token' do
    time_now = Time.zone.now
    allow(Time).to receive(:now).and_return(time_now)

    expect(expiration_time_from_token(subject.to_s)).
      to eq(time_now.to_i + Vapor::Application.config.jwt.expiration_time)
  end

  context 'token expired' do
    it 'expired token fails with error' do
      expired_token = subject.to_s

      travel((Vapor::Application.config.jwt.expiration_time + 1).seconds)

      expect { User.from_token(expired_token) }.
        to raise_error(JWT::ExpiredSignature)
    end
  end

  private

  def issuer_from_token(enc_token)
    decode_token(enc_token).detect { |el| el.key? 'iss' }.try(:[], 'iss')
  end

  def expiration_time_from_token(enc_token)
    decode_token(enc_token).detect { |el| el.key? 'exp' }.try(:[], 'exp')
  end

  def decode_token(enc_token)
    JWT.decode(
      enc_token, Vapor::Application.config.jwt.key, true,
      algorithm: Vapor::Application.config.jwt.key_algorithm
    )
  end
end
