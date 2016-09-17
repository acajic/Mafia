class TimestampValidator < Apipie::Validator::BaseValidator

  def initialize(param_description, argument)
    super(param_description)
    @type = argument
  end

  def validate(value)
    return value.class == Fixnum
  end

  def self.build(param_description, argument, options, block)
    self.new(param_description, argument) if argument == :Timestamp
  end

  def description
    "Must be #{@type} - a number representing number of seconds since 1970-01-01T00:00:00."
  end

end