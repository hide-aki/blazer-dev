module DemoModel
  extend ActiveSupport::Concern

  included do
    validate :prevent_save
  end

  def prevent_save
    errors.add(:base, "Sorry, not in the demo") if changed?
  end

  def destroy
  end
end

module DemoRunStatement
  def perform(data_source, statement, options = {})
    if statement.include?("pg_") || statement.include?("information_schema")
      statement = "SELECT 1 LIMIT 0" # empty results
    end
    super(data_source, statement, options)
  end
end

if ENV["DEMO"].present?
  [
    Blazer::Query,
    Blazer::Dashboard,
    Blazer::DashboardQuery,
    Blazer::Check
  ].each do |model|
    model.send(:include, DemoModel)
  end

  Blazer::RunStatement.prepend(DemoRunStatement)

  class Blazer::Check
    def update_state(*args)
      # do nothing
    end
  end
end
