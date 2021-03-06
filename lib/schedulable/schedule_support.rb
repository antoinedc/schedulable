module Schedulable
  
  module ScheduleSupport
    
    def to_icecube
      return @schedule
    end
    
    def to_s
      return @schedule.to_s
    end
    
    def method_missing(meth, *args, &block)
      if @schedule
        @schedule.send(meth, *args, &block)
      end
    end
    
    def self.param_names
      [:id, :date, :time, :rule, :until, :count, :interval, days: [], day_of_week: [monday: [], tuesday: [], wednesday: [], thursday: [], friday: [], saturday: [], sunday: []]]
    end
  
    private
    
    def init_schedule()
      
      self.rule||= "singular"
      self.interval||= 1
      
      date = self.date ? self.date.to_time : Time.now
      if self.time
        date = date.change({hour: self.time.hour, min: self.time.min})
      end
      
      @schedule = IceCube::Schedule.new(date)
      
      if self.rule && self.rule != 'singular'
        
        self.interval = self.interval.present? ? self.interval.to_i : 1
        
        rule = IceCube::Rule.send("#{self.rule}", self.interval)
        
        if self.until
          rule.until(self.until)
        end
        
        if self.count && self.count.to_i > 0
          rule.count(self.count.to_i)
        end
      
        if self.days
          days = self.days.reject(&:empty?)
          if self.rule == 'weekly'
            days.each do |day|
              rule.day(day.to_sym)
            end
          elsif self.rule == 'monthly'
            days = {}
            day_of_week.each do |weekday, value|
              days[weekday.to_sym] = value.reject(&:empty?).map { |x| x.to_i }
            end
            rule.day_of_week(days)
          end
        end
        @schedule.add_recurrence_rule(rule)
      end
    end
  end
end