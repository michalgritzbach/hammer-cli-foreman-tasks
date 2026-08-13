module HammerCLIForemanTasks
  module CommandExtensions
    class RecurringLogic < HammerCLI::CommandExtensions
      before_print do |data|
        records(data).each { |record| format_record(record) }
      end

      output do |definition|
        definition.insert(:after, :cron_line) do
          field :action, _('Action'), nil, hide_blank: true
          field :last_occurrence, _('Last occurrence'), Fields::Date, hide_blank: true
          field :next_occurrence, _('Next occurrence'), Fields::Date, hide_blank: true
        end
        definition.insert(:after, :iteration) do
          field :iteration_limit, _('Iteration limit')
        end
        definition.insert(:replace, :end_time) do
          field :repeat_until, _('Repeat until')
        end
      end

      # The info command hands over a single recurring logic, the list command a
      # whole collection wrapped in `results`. Both are formatted the same way.
      def self.records(data)
        data.is_a?(Hash) && data['results'].is_a?(Array) ? data['results'] : [data]
      end

      # The recurring_logics API already computes the action, the occurrences and
      # the limits (see the `base` rabl view). The extension only normalizes them:
      # the API spells the occurrences with a single "r", so they are copied to
      # the corrected keys and rendered as dates, while blank limits show
      # "Unlimited". The action, occurrences and purpose are nilled when empty so
      # their `hide_blank` fields skip the line entirely in the info output.
      # Working off these fields keeps the list and the info command consistent,
      # as the list output has no `tasks` to recompute them from.
      def self.format_record(data)
        data['action'] = nil if data['action'].to_s.empty?
        data['last_occurrence'] = data['last_occurence']
        data['next_occurrence'] = data['next_occurence']
        data['iteration_limit'] = format_recurring_logic_limit(data['max_iteration'])
        data['repeat_until'] = format_recurring_logic_limit(data['end_time'])
        data['purpose'] = nil if data['purpose'].to_s.empty?
      end

      def self.format_recurring_logic_limit(thing)
        thing || _('Unlimited')
      end
    end
  end
end
