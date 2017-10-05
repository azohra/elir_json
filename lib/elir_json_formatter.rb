require 'rspec/core/formatters/base_formatter'
require 'json'

class ElirJsonFormatter < RSpec::Core::Formatters::BaseFormatter
  RSpec::Core::Formatters.register self, :example_passed, :example_pending, :example_failed, :close 

  attr_reader :output_hash

  def initialize(output)
    super
    @output_hash = {}
    @env_final = {}    
  end

  def example_passed(passed)
    process_example(passed.example)
  end

  def example_pending(pending)
    process_example(pending.example)
  end

  def example_failed(failure)
    process_example(failure.example)
  end

  private

  def process_example(example)
    @output_hash = format_example(example)
    output.write @output_hash.to_json
    @output_hash = {}
    @env_final   = {}
  end

  def format_example(example)
    {
      id: example.id,
      description: example.description,
      full_description: example.full_description,
      status: example.execution_result.status.to_s,
      file_path: example.metadata[:file_path],
      line_number: example.metadata[:line_number],
      run_time: example.execution_result.run_time,
      pending_message: example.execution_result.pending_message,
      env: format_envs(ENV['labels'])
    }
  end

  def format_envs(envs)
    return unless ENV['labels']
    envs.to_s.split(/\W+/).each do |k,v|
      @env_final[k.downcase.to_sym] = ENV[k]
    end
    @env_final  
  end
end
