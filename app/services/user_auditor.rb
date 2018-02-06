# frozen_string_literal: true

class UserAuditor
  def initialize(user)
    @user = user
  end

  def call
    notify unless ok?
  end

  private

  def ok?
    audits_count = @user.user_audits.count

    return true if audits_count < 2

    score = 0

    # Browser checks
    a_current = @user.user_audits[audits_count - 1]
    b_current = Browser.new(a_current.user_agent, accept_language: a_current.accept_language)
    a_previous = @user.user_audits[audits_count - 2]
    b_previous = Browser.new(a_previous.user_agent, accept_language: a_previous.accept_language)

    # Different browser - smelly ;)...
    score += 10 if (b_current.name != b_previous.name)
    # Different major version - looks OK - but bump score
    score += 2 if (b_current.version != b_previous.version)
    # Different minor version - minimum impact (common)
    score += 1 if (b_current.full_version  != b_previous.full_version)

    al_current = b_current.accept_language.first
    al_previous = b_previous.accept_language.first

    unless al_current.nil? or al_previous.nil?
      # Different browser language - not so common
      score += 3 if (al_current.region != al_previous.region)
    end

    # IP check
    ip_cc_current = a_current.ip_cc
    ip_cc_previous = a_previous.ip_cc

    unless ip_cc_current.nil? or ip_cc_previous.nil?
      # IP from another country - travel or fraud
      score += 3 if (ip_cc_current != ip_cc_previous)
    end

    # IP change - very common (dynamic IPs) - low impact
    score += 1 if (a_current.ip != a_previous.ip)

    # Score: 5 -> e.g. browser change or IPs country and browser (minor) version changed
    return true if score < 5

    false
  end

  def notify

  end

end
