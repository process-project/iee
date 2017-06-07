# frozen_string_literal: true
require 'rails_helper'

RSpec.describe JwtToken do
  include ActiveSupport::Testing::TimeHelpers

  let(:user) { create(:user) }
  subject { described_class.new(user) }

  it 'includes issuer in token' do
    expect(key_from_token(subject.generate, 'iss')).
      to eq Vapor::Application.config.jwt.issuer
  end

  it 'includes expiration time in token' do
    time_now = Time.zone.now
    allow(Time).to receive(:now).and_return(time_now)

    expect(key_from_token(subject.generate, 'exp')).
      to eq(time_now.to_i + Vapor::Application.config.jwt.expiration_time)
  end

  it 'includes sub in token' do
    expect(key_from_token(subject.generate, 'sub')).
      to eq user.id.to_s
  end

  it 'allows to create long tokens' do
    time_now = Time.zone.now
    allow(Time).to receive(:now).and_return(time_now)

    expect(key_from_token(subject.generate(long_expiration_time), 'exp')).
      to eq(time_now.to_i + long_expiration_time)
  end

  context 'token expired' do
    it 'expired token fails with error' do
      expired_token = subject.generate

      travel((Vapor::Application.config.jwt.expiration_time + 1).seconds)

      expect { User.from_token(expired_token) }.
        to raise_error(JWT::ExpiredSignature)
    end
  end

  private

  def key_from_token(enc_token, key)
    decode_token(enc_token).detect { |el| el.key? key }.try(:[], key)
  end

  def decode_token(enc_token)
    JWT.decode(
      enc_token, Vapor::Application.config.jwt.key, true,
      algorithm: Vapor::Application.config.jwt.key_algorithm
    )
  end

  def long_expiration_time
    2 * Vapor::Application.config.jwt.expiration_time
  end
end
