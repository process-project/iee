# frozen_string_literal: true

class Device < ApplicationRecord
  belongs_to :user
  has_many :ips, dependent: :destroy

  validates :name, presence: true

  default_scope { order(updated_at: :desc) }

  def updated_ip
    ips.first
  end

  def last_ip
    updated_ip.address
  end

  def last_login
    updated_ip.created_at
  end

  def top_n(n_ips)
    ips.first(n_ips).pluck(:address)
  end

  def to_s
    b = Browser.new(name, accept_language: accept_language)

    "#{b.name} #{b.full_version} (#{b.platform.name})"
  end
end
