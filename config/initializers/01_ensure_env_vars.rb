required_env_vars = %w[
  REQUEST_BRT_BUSES_INTERVAL_SECONDS
]

required_env_vars.each do |env_var|
  unless ENV.has_key?(env_var) && !ENV[env_var].blank?
    raise <<~EOL
      Missing or empty environment variable: #{env_var}
      Please ensure this variable is set in your environment.
    EOL
  end
end
