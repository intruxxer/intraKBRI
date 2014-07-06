class RecapWorker
  include Sidekiq::Worker
  sidekiq_options :queue => :top_priority

  def perform(name, count)
    put "Hallo, #{name} for #{count}x."  
  end

  # === x.days.ago is from gem "activesupport" === #
  # === gem "chronic" is also possible if we want === #

  # === TODAY === #

  def calculate_verified_today
    set_stat_value
    visa = Journal.where(action: 'Verified', model: 'Visa', :created_at => Date.today).order_by(:created_at.desc)
    passport = Journal.where(action: 'Verified', model: 'Passport', :created_at => Date.today).order_by(:created_at.desc)
    stat_value.update(today_verified_visa: visa.count, today_verified_passport: passport.count)
  end

  def calculate_approved_today
    set_stat_value
    visa = Journal.where(action: 'Approved', model: 'Visa', :created_at => Date.today).order_by(:created_at.desc)
    passport = Journal.where(action: 'Approved', model: 'Passport', :created_at => Date.today).order_by(:created_at.desc)
    stat_value.update(today_approved_visa: visa.count, today_approved_passport: passport.count)
  end

  def calculate_printed_today
    set_stat_value
    visa = Journal.where(action: 'Printed', model: 'Visa', :created_at => Date.today).order_by(:created_at.desc)
    passport = Journal.where(action: 'Printed', model: 'Passport', :created_at => Date.today).order_by(:created_at.desc)
    stat_value.update(today_printed_visa: visa.count, today_printed_passport: passport.count)
  end

  # === WEEK === #

  def calculate_verified_week
    set_stat_value
    visa = Journal.where(action: 'Verified', model: 'Visa', :created_at.gte => 7.days.ago).order_by(:created_at.desc)
    passport = Journal.where(action: 'Verified', model: 'Passport', :created_at.gte => 7.days.ago).order_by(:created_at.desc)
    stat_value.update(week_verified_visa: visa.count, week_verified_passport: passport.count)
  end

  def calculate_approved_week
    set_stat_value
    visa = Journal.where(action: 'Approved', model: 'Visa', :created_at.gte => 7.days.ago).order_by(:created_at.desc)
    passport = Journal.where(action: 'Approved', model: 'Passport', :created_at.gte => 7.days.ago).order_by(:created_at.desc)
    stat_value.update(week_approved_visa: visa.count, week_approved_passport: passport.count)
  end

  def calculate_printed_week
    set_stat_value
    visa = Journal.where(action: 'Printed', model: 'Visa', :created_at.gte => 7.days.ago).order_by(:created_at.desc)
    passport = Journal.where(action: 'Printed', model: 'Passport', :created_at.gte => 7.days.ago).order_by(:created_at.desc)
    stat_value.update(week_printed_visa: visa.count, week_printed_passport: passport.count)
  end

  # === MONTH === #

  def calculate_verified_month
    set_stat_value
    visa = Journal.where(action: 'Verified', model: 'Visa', :created_at.gte => 1.month.ago).order_by(:created_at.desc)
    passport = Journal.where(action: 'Verified', model: 'Passport', :created_at.gte => 1.month.ago).order_by(:created_at.desc)
    stat_value.update(month_verified_visa: visa.count, month_verified_passport: passport.count)
  end

  def calculate_approved_month
    set_stat_value
    visa = Journal.where(action: 'Approved', model: 'Visa', :created_at.gte => 1.month.ago).order_by(:created_at.desc)
    passport = Journal.where(action: 'Approved', model: 'Passport', :created_at.gte => 1.month.ago).order_by(:created_at.desc)
    stat_value.update(month_approved_visa: visa.count, month_approved_passport: passport.count)
  end

  def calculate_printed_month
    set_stat_value
    visa = Journal.where(action: 'Printed', model: 'Visa', :created_at.gte => 1.month.ago).order_by(:created_at.desc)
    passport = Journal.where(action: 'Printed', model: 'Passport', :created_at.gte => 1.month.ago).order_by(:created_at.desc)
    stat_value.update(month_printed_visa: visa.count, month_printed_passport: passport.count)
  end
  
  # === end of file === #
  def redis
    @redis ||= Redis.new
  end
  
  private
  def set_stat_value
    stat_value = Statistic.first
  end

end
