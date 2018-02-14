# frozen_string_literal: true

class UserAuditor
  class MailNotifier
    def initialize(user_audit)
      @user_audit = user_audit
    end

    def notify
      Notifier.audit_failed(@user_audit).deliver_later
    end
  end

  def initialize(user, notifier = nil)
    @user = user

    fetch_audit_data

    @notifier = if notifier.nil?
                  MailNotifier.new(user.user_audits.last)
                else
                  notifier
                end
  end

  def call
    @notifier.notify unless ok?
  end

  private

  def fetch_audit_data
    @audits_count = @user.user_audits.count
    @a_current = @user.user_audits[@audits_count - 1]
    @b_current = Browser.new(@a_current.user_agent, accept_language: @a_current.accept_language)
    @a_previous = @user.user_audits[@audits_count - 2]
    @b_previous = Browser.new(@a_previous.user_agent, accept_language: @a_previous.accept_language)
  end

  def ok?
    return true if @audits_count < 2

    score = 0
    score += browser_score
    score += language_score
    score += ip_score

    # Score: 5 -> e.g. browser change or IPs country and browser (minor) version changed
    return true if score < 5

    false
  end

  def browser_score
    score = 0

    # Different browser - smelly ;)...
    score += 10 if @b_current.name != @b_previous.name
    # Different major version - looks OK - but bump score
    score += 2 if @b_current.version != @b_previous.version
    # Different minor version - minimum impact (common)
    score += 1 if @b_current.full_version != @b_previous.full_version

    score
  end

  def language_score
    score = 0

    al_current = @b_current.accept_language.first
    al_previous = @b_previous.accept_language.first

    unless al_current.nil? || al_previous.nil?
      # Different browser language - not so common
      score += 3 if al_current.region != al_previous.region
    end

    score
  end

  def ip_score
    score = 0

    ip_cc_current = @a_current.ip_cc
    ip_cc_previous = @a_previous.ip_cc

    unless ip_cc_current.nil? || ip_cc_previous.nil?
      # IP from another country - travel or fraud
      score += 3 if ip_cc_current != ip_cc_previous
    end

    # IP change - very common (dynamic IPs) - low impact
    score += 1 if @a_current.ip != @a_previous.ip

    score
  end
end
